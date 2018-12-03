import nre
import strutils
import sequtils

type
   Claim = object
      id: int
      left, right: int # X coordinates
      top, bottom: int # Y coordinates

   Fabric = array[0..1000, array[0..1000, int]]


proc parse_claim(claim: string): Claim =
   ## Parse a claim from a string.
   let captures = nre.match(claim,
                            re"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)").get.captures
   let num = map(captures.to_seq(), parse_int)
   result.id = num[0]
   result.left = num[1]
   result.right = num[1] + num[3] - 1
   result.top = num[2]
   result.bottom = num[2] + num[4] - 1


proc mark_fabric(fabric: var Fabric, claim: Claim): int =
   ## Mark the claim in the fabric. Returns the number of square inches that
   ## uniquely overlaps with another claim.
   for x in countup(claim.left, claim.right):
      for y in countup(claim.top, claim.bottom):
         if fabric[x][y] == 1:
            inc(result)
         inc(fabric[x][y])


proc get_total_overlapping_area(filename: string): int =
   ## Mark the fabric with the claims defined in the input file and return the
   ## number of square inches marked by two or more claims.
   let lines = read_file(filename).strip().split_lines()
   let claims = map(lines, parse_claim)
   var fabric: Fabric

   for c in claims:
      inc(result, mark_fabric(fabric, c))


when is_main_module:
   echo "Area with overlapping claims is ",
        get_total_overlapping_area("input.txt"), " square inches.\n"
