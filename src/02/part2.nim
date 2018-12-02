import tables
import strutils
import sequtils


proc get_hamming_distance(x, y: string): tuple[dist, pos: int] =
   ## Calculate the hamming distance between two input strings of equal length.
   ## Returns a tuple where ``dist`` is the hamming distance and ``pos`` is the
   ## last position where the strings differ.
   for i in 0..<len(x):
      if x[i] != y[i]:
         inc(result.dist)
         result.pos = i


proc get_common_letters(filename: string): string =
   let lines = read_file(filename).strip().split_lines()

   for i in 0..<len(lines):
      for j in i+1..<len(lines):
         let h = get_hamming_distance(lines[i], lines[j])
         if h.dist == 1:
            # Slice the string, excluding the character not included in either
            # string.
            return lines[i][0..h.pos-1] & lines[i][h.pos+1..^1]


when is_main_module:
   echo "The set of common letters is '", get_common_letters("input.txt"), "'.\n"
