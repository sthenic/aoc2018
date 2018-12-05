import strutils

proc reduce(s: var string): bool =
   for i in 0..<len(s)-1:
      if abs(int(s[i]) - int(s[i+1])) == 32:
         s = s[0..i-1] & s[i+2..^1]
         return true
   return false

when is_main_module:
   var polymer = read_file("input.txt").strip()
   while reduce(polymer):
      discard

   echo len(polymer)
