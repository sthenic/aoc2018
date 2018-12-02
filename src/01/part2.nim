import sets
import strutils
import sequtils


proc find_repeated_frequency(filename: string): int =
   var seen_freqs = init_set[int](262144)
   var found = false
   let lines = read_file(filename).strip().split_lines()
   let ops = map(lines, parseInt)

   while not found:
      for o in ops:
         result += o
         if result notin seen_freqs:
            incl(seen_freqs, result)
         else:
            found = true
            break


when is_main_module:
   echo "Repeated frequency: ", find_repeated_frequency("input.txt"), "\n"
