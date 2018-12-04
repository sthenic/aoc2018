import nre
import strutils
import sequtils
import tables
import hashes
import math


type
   Date = object
      year, month, day: int

   Time = object
      hour, minute: int

   Timestamp = object
      date: Date
      time: Time

   Observation = string

   Observations = OrderedTable[Timestamp, Observation]

   SleepTable = object
      guards: seq[int]
      table: OrderedTable[Date, SleepEntry]

   SleepEntry = object
      guard_id: int
      sleeping: array[0..59, int]
      sleep_time: int

   ActionKind = enum
      Invalid
      FellAsleep
      WokeUp

   Action = object
      time: Time
      kind: ActionKind


proc hash(x: Timestamp): Hash =
   result = x.date.year.hash !& x.date.month.hash !& x.date.day.hash !&
            x.time.hour.hash !& x.time.minute.hash
   result = !$result


proc hash(x: Date): Hash =
   result = x.year.hash !& x.month.hash !& x.day.hash
   result = !$result


proc init_observations(initial_size: int = 64): Observations =
   init_ordered_table[Timestamp, Observation](initial_size)


proc init_sleep_table(initial_size: int = 64): SleepTable =
   result.table = init_ordered_table[Date, SleepEntry](initial_size)


proc parse_observations(filename: string): Observations =
   let lines = read_file(filename).strip().split_lines()
   result = init_observations(next_power_of_two(len(lines)))

   for l in lines:
      let c = match(l, re"\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] (.*)$").get.captures.to_seq()
      let cint = map(c[0..4], parse_int)

      let timestamp =
         Timestamp(date: Date(year: cint[0], month: cint[1], day: cint[2]),
                   time: Time(hour: cint[3], minute: cint[4]))

      result[timestamp] = c[5]


proc `-`(x, y: Timestamp): Timestamp =
   result.date.year = x.date.year - y.date.year
   result.date.month = x.date.month - y.date.month
   result.date.day = x.date.day - y.date.day
   result.time.hour = x.time.hour - y.time.hour
   result.time.minute = x.time.minute - y.time.minute


proc sort_observations(o: var Observations) =
   proc cmp(x, y: tuple[ts: Timestamp, ob: Observation]): int =
      let diff = x.ts - y.ts
      if diff.date.year != 0:
         result = diff.date.year
      elif diff.date.month != 0:
         result = diff.date.month
      elif diff.date.day != 0:
         result = diff.date.day
      elif diff.time.hour != 0:
         result = diff.time.hour
      elif diff.time.minute != 0:
         result = diff.time.minute
      else:
         result = 0

   sort(o, cmp)


type Guard = object
   id: int
   last_action: Action


proc mark_sleep_duration(e: var SleepEntry, start, stop: Time) =
   for i in start.minute..<stop.minute:
      e.sleeping[i] = 1
   inc(e.sleep_time, stop.minute - start.minute)


proc get_sleep_table(observations: Observations): SleepTable =
   result = init_sleep_table(next_power_of_two(len(observations)))
   var guard: Guard
   # Traverse the list of ordered observations one day at a time.
   for ts, ob in pairs(observations):
      let m = match(ob, re"Guard #(\d+).*$")
      if is_some(m):
         # Changing of the guards!
         let id = parse_int(m.get.captures.to_seq[0])
         guard.id = id
         if id notin result.guards:
            add(result.guards, id)
      elif ob == "wakes up":
         mark_sleep_duration(result.table[ts.date], guard.last_action.time,
                             ts.time)
         guard.last_action = Action(time: ts.time, kind: WokeUp)
      elif ob == "falls asleep":
         discard has_key_or_put(result.table, ts.date,
                                SleepEntry(guard_id: guard.id))
         guard.last_action = Action(time: ts.time, kind: FellAsleep)
      else:
         raise new_exception(ValueError, "Unexpected observation '" & ob & "'.")


proc get_guard_sleep_duration(sleep_table: SleepTable, guard_id: int): int =
   for date, entry in pairs(sleep_table.table):
      if entry.guard_id == guard_id:
         inc(result, entry.sleep_time)


proc get_guard_most_likely_minute(sleep_table: SleepTable,
                                  guard_id: int): range[0..59] =
   var count: array[0..59, int]

   for date, entry in pairs(sleep_table.table):
      if entry.guard_id == guard_id:
         for i in 0..<len(entry.sleeping):
            inc(count[i], entry.sleeping[i])

   var max: tuple[idx, val: int]
   for idx, val in pairs(count):
      if max.val < val:
         max.val = val
         max.idx = idx

   result = max.idx


proc get_longest_sleeping_guard(sleep_table: SleepTable): int =
   var max: tuple[id, val: int]
   for id in sleep_table.guards:
      let d = get_guard_sleep_duration(sleep_table, id)
      if max.val < d:
         max.val = d
         max.id = id

   result = max.id


when is_main_module:
   var obs = parse_observations("input.txt")
   sort_observations(obs)
   let sleep_table = get_sleep_table(obs)
   let id = get_longest_sleeping_guard(sleep_table)
   let minute = get_guard_most_likely_minute(sleep_table, id)

   echo "Product is ", id * minute, "\n"

