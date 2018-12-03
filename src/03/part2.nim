import nre
import strutils
import sequtils

type
   Claim = object
      id: int
      left, right: int # X coordinates
      top, bottom: int # Y coordinates


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


proc is_overlapping(x, y: Claim): bool =
   ## Returns true if the claims ``x`` and ``y`` overlap.
   result = not (y.left > x.right or
                 y.right < x.left or
                 y.top > x.bottom or
                 y.bottom < x.top)


proc get_intact_claim_id(filename: string): int =
   ## Return the ID of the claim that doesn't overlap with any other claim.
   let lines = read_file(filename).strip().split_lines()
   let claims = map(lines, parse_claim)

   # Check each claim against every other claim. This could obviously be
   # improved.
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
   echo "The ID of the intact claim is ",
        get_intact_claim_id("input.txt"), ".\n"
