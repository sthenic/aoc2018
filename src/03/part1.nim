import nre
import strutils
import sequtils
import tables
import math

type
   Coordinate = tuple
      x, y: int

   Claim = object
      id: int
      top_left, bottom_right: Coordinate

   Fabric = CountTable[Coordinate]


proc parse_claim(claim: string): Claim =
   ## Parse a claim from a string.
   let captures = nre.match(claim, re"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)").get.captures
   let num = map(captures.to_seq(), parse_int)
   result.id = num[0]
   result.top_left = (num[1], num[2])
   result.bottom_right = (num[1] + num[3] - 1, num[2] + num[4] - 1)


proc mark_fabric(fabric: var Fabric, claim: Claim) =
   for x in countup(claim.top_left.x, claim.bottom_right.x):
      for y in countup(claim.top_left.y, claim.bottom_right.y):
         inc(fabric, (x, y))


proc get_total_overlapping_area(filename: string): int =
   let lines = read_file(filename).strip().split_lines()
   let claims = map(lines, parse_claim)
   var fabric = init_count_table[Coordinate](2 ^ 20)

   for c in claims:
      mark_fabric(fabric, c)

   for val in values(fabric):
      if val > 1:
         inc(result)


when is_main_module:
   echo "Area with overlapping claims is ",
        get_total_overlapping_area("input.txt"), " square inches.\n"
