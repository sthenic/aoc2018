import strutils
import hashes
import tables
import strscans
import math
import sequtils

type
   Coord = tuple
      x, y: int

   DistanceGrid = object
      grid: Table[Coord, seq[int]]
      max: Coord
      nof_pts: int

   Grid = object
      max: Coord
      grid: Table[Coord, int]
      nof_pts: int


proc hash(c: Coord): Hash =
   result = c.x !& c.y
   result = !$ result


proc create_distance_grid(filename: string): DistanceGrid =
   # Each line defines a point on the grid.
   let lines = read_file(filename).strip().split_lines()
   var max: Coord
   var points: seq[Coord]
   var x, y: int
   for i, l in pairs(lines):
      if scanf(l, "$i, $i", x, y):
         add(points, (x, y))
         if x^2 + y^2 > max.x^2 + max.y^2:
            max = (x, y)
      else:
         raise new_exception(ValueError, "Unexpected coordinate format.")

   # Create the grid.
   result.grid = init_table[Coord, seq[int]]()
   result.max = max
   result.nof_pts = len(points)
   for x in countup(0, max.x):
      for y in countup(0, max.y):
         var dist: seq[int]
         for p in points:
            # Compute taxi cab distance for point p to the current coordinate.
            add(dist, abs(x - p.x) + abs(y - p.y))
         result.grid[(x, y)] = dist


proc sum_grid(grid: DistanceGrid): Grid =
   result.grid = init_table[Coord, int]()
   result.max = grid.max
   result.nof_pts = grid.nof_pts

   for c, dist in pairs(grid.grid):
      result.grid[c] = sum(dist)


proc get_region_within(grid: Grid, maximum_distance: int): int =
   for dtot in values(grid.grid):
      if dtot < maximum_distance:
         inc(result)


when is_main_module:
   let maximum_distance = 10000
   let grid = sum_grid(create_distance_grid("input.txt"))
   echo "The size of the region within distance ", maximum_distance, " to ",
        "all locations is ", get_region_within(grid, 10000), "."
