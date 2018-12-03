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


proc is_overlapping(x, y: Claim): bool =
   ## Returns true if the claims ``x`` and ``y`` overlap.
   if y.top_left.x > x.bottom_right.x:
      return false
   elif y.bottom_right.x < x.top_left.x:
      return false
   elif y.top_left.y > x.bottom_right.y:
      return false
   elif y.bottom_right.y < x.top_left.y:
      return false
   else:
      return true


proc get_intact_claim_id(filename: string): int =
   let lines = read_file(filename).strip().split_lines()
   let claims = map(lines, parse_claim)

   # Mark the fabric just as before.
   for i in 0..<len(claims):
      var overlap = false
      for j in 0..<len(claims):
         if i == j:
            continue
         if is_overlapping(claims[i], claims[j]):
            overlap = true
            break
      if not overlap:
         return claims[i].id


when is_main_module:
   echo "The ID of the intact claim is ", get_intact_claim_id("input.txt"), ".\n"
