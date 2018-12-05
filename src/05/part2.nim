import strutils

const UNITS = {'a'..'z'}

proc remove_all(s: string, u: char): string =
   for c in s:
      if c != u and int(c) != int(u) - 32:
         add(result, c)

proc reduce(s: var string): bool =
   for i in 0..<len(s)-1:
      if abs(int(s[i]) - int(s[i+1])) == 32:
         s = s[0..i-1] & s[i+2..^1]
         return true
   return false

when is_main_module:
   var polymer = read_file("input.txt").strip()

   var min = len(polymer)
   for u in UNITS:
      var s = remove_all(polymer, u)
      while reduce(s):
         discard
      if len(s) < min:
         min = len(s)

   echo min
