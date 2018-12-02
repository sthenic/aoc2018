import tables
import strutils
import sequtils

type BoxCount = tuple
   two, three: int


proc inc(x: var BoxCount, y: BoxCount) =
   inc(x.two, y.two)
   inc(x.three, y.three)


proc parse_box_id(id: string): BoxCount =
   let letter_freq = to_count_table(id)

   for val in values(letter_freq):
      if val == 2:
         result.two = 1
      elif val == 3:
         result.three = 1


proc get_checksum(filename: string): int =
   let lines = read_file(filename).strip().split_lines()
   let counts = map(lines, parse_box_id)

   var total_box_count: BoxCount
   for c in counts:
      inc(total_box_count, c)

   result = total_box_count.two * total_box_count.three


when is_main_module:
   echo "The checksum is ", get_checksum("input.txt"), ".\n"
