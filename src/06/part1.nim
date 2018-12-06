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


proc shortest_distance_grid(grid: DistanceGrid): Grid =
   result.grid = init_table[Coord, int]()
   result.max = grid.max
   result.nof_pts = grid.nof_pts

   for c, dist in pairs(grid.grid):
      var dmin = high(int)
      var id = 0
      for i, d in pairs(dist):
         if d == dmin:
            id = -1
         elif d < dmin:
            id = i
            dmin = d
      result.grid[c] = id


proc get_edge_points(grid: Grid): seq[int] =
   # Walk around the edges of the grid, adding any ID we encounter to the result
   # sequence.
   for x in countup(0, grid.max.x):
      if grid.grid[(x, 0)] notin result:
         add(result, grid.grid[(x, 0)])

   for x in countup(0, grid.max.x):
      if grid.grid[(x, grid.max.y)] notin result:
         add(result, grid.grid[(x, grid.max.y)])

   for y in countup(0, grid.max.y):
      if grid.grid[(0, y)] notin result:
         add(result, grid.grid[(0, y)])

   for y in countup(0, grid.max.y):
      if grid.grid[(grid.max.x, y)] notin result:
         add(result, grid.grid[(grid.max.x, y)])


proc get_largest_area(grid: Grid, edge_pts: seq[int]): int =
   var area = new_seq[int](grid.nof_pts)
   for id in values(grid.grid):
      if id > 0:
         inc(area[id])

   for i, a in pairs(area):
      if i notin edge_pts:
         if a > result:
            result = a


when is_main_module:
   let grid = shortest_distance_grid(create_distance_grid("input.txt"))
   let edge_points = get_edge_points(grid)
   echo "The largest bounded area is ", get_largest_area(grid, edge_points), "."
