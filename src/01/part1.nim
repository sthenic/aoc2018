import strutils


proc get_frequency(filename: string): int =
   for l in lines("input.txt"):
      result += parse_int(l)


when isMainModule:
   echo "Resulting frequency: ", get_frequency("input.txt"), "\n"
