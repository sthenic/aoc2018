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


proc assemble(a: AssemblyInstruction): string =
   var completed_steps: set[char]

   while not (completed_steps == a.steps):
      var step_to_complete = '\xFF'
      # Find which step to complete.
      for s, prereqs in pairs(a.prereqs):
         if s in completed_steps:
            continue
         if prereqs <= completed_steps:
            if s < step_to_complete:
               step_to_complete = s

      if step_to_complete == '\xFF':
         raise new_exception(ValueError, "Invalid step")

      # Complete the assembly step.
      incl(completed_steps, step_to_complete)
      add(result, step_to_complete)


when is_main_module:
   echo "Assembly order is ", assemble(get_instruction("input.txt")), ".\n"
