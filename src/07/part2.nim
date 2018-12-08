import strutils
import tables
import strscans
import sets


type AssemblyInstruction = object
   prereqs: Table[char, set[char]] # Prerequisites
   steps: set[char]


proc get_instruction(filename: string): AssemblyInstruction =
   result.prereqs = init_table[char, set[char]]()
   let lines = read_file(filename).strip().split_lines()

   var x, y: string
   var left, right: set[char]
   for l in lines:
      if scanf(l, "Step $w must be finished before step $w can begin.", x, y):
         if has_key(result.prereqs, y[0]):
            incl(result.prereqs[y[0]], x[0])
         else:
            result.prereqs[y[0]] = {x[0]}

         incl(left, x[0])
         incl(right, y[0])
      else:
         raise new_exception(ValueError, "Malformed input.")

   result.steps = left + right
   for c in left - right:
      result.prereqs[c] = {}


proc get_effort(step: char): int = int(step) - int('A') + 61


proc get_step_to_complete(a: AssemblyInstruction,
                          completed_steps: set[char],
                          steps_in_progress: set[char]): char =
   result = '\xFF'
   # Find which step to complete.
   for s, prereqs in pairs(a.prereqs):
      if s in completed_steps or s in steps_in_progress:
         continue
      if prereqs <= completed_steps:
         if s < result:
            result = s

   if result == '\xFF':
      result = '\0'


proc assemble_parallel(a: AssemblyInstruction, nof_workers: int): int =
   var completed_steps: set[char]
   var steps_in_progress: set[char]

   type Worker = object
      step: char
      time_remaining: int

   var workers = new_seq[Worker](nof_workers)
   while not (completed_steps == a.steps):
      # Task any free worker with completing an available step.
      for w in mitems(workers):
         let step_to_complete = get_step_to_complete(a, completed_steps,
                                                     steps_in_progress)
         if w.time_remaining == 0 and step_to_complete != '\0':
            # echo "Assigning step ", step_to_complete, "to worker ", w
            incl(steps_in_progress, step_to_complete)
            w.step = step_to_complete
            w.time_remaining = get_effort(step_to_complete)

      # Step time.
      inc(result)
      for w in mitems(workers):
         if w.step != '\0':
            dec(w.time_remaining)
            if w.time_remaining == 0:
               incl(completed_steps, w.step)
               # add(result, w.step)
               w.step = '\0'


when is_main_module:
   let instruction = get_instruction("input.txt")
   echo "Parallel assembly order is ", assemble_parallel(instruction, 5), ".\n"
