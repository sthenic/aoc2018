import strutils


proc get_frequency(filename: string): int =
   for l in lines(filename):
      result += parse_int(l)


when is_main_module:
   echo "Resulting frequency: ", get_frequency("input.txt"), "\n"
