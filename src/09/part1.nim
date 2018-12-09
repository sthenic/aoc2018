import strscans
import strutils


type
   Marble = ref object
      value: int
      prev: Marble
      next: Marble

   Game = object
      curr_marble: Marble
      curr_player: int
      score: seq[int]
      nof_players: int
      end_marble_value: int
      last_marble_value: int


proc init_board(filename: string): Game =
   let setup = read_file(filename).strip()

   var x, y = 0
   if scanf(setup, "$i players; last marble is worth $i points", x, y):
      result.nof_players = x
      result.end_marble_value = y

   # Create first marble.
   let marble = Marble(value: 0)
   marble.next = marble
   marble.prev = marble

   result.curr_marble = marble
   result.score = new_seq[int](result.nof_players)


proc get_marble(m: Marble, relpos: int): Marble =
   result = m
   if relpos < 0:
      for i in countdown(0, relpos+1):
         result = result.prev
   else:
      for i in countup(0, relpos-1):
         result = result.next


proc get_value(game: Game, relpos: int): int =
   get_marble(game.curr_marble, relpos).value


proc insert_marble(game: Game, relpos, value: int): Marble =
   let marble_after = get_marble(game.curr_marble, relpos)
   let marble_before = marble_after.prev

   # Insert marble
   result = Marble(value: value, prev: marble_before, next: marble_after)
   marble_before.next = result
   marble_after.prev = result


proc remove_marble(game: Game, relpos: int): Marble =
   let target_marble = get_marble(game.curr_marble, relpos)

   target_marble.prev.next = target_marble.next
   target_marble.next.prev = target_marble.prev

   result = target_marble.next


proc place_marble(game: var Game): bool =
   let next_value = game.last_marble_value + 1
   var points = 0

   if (next_value mod 23) == 0:
      inc(points, next_value)
      inc(points, get_value(game, -7))
      game.curr_marble = remove_marble(game, -7)
   else:
      game.curr_marble = insert_marble(game, 2, next_value)

   inc(game.score[game.curr_player], points)
   game.curr_player = (game.curr_player + 1) mod game.nof_players
   game.last_marble_value = next_value

   result = game.curr_marble.value != game.end_marble_value


when is_main_module:
   var game = init_board("input.txt")
   while place_marble(game):
      discard
   echo "Winning score is ", max(game.score), ".\n"

