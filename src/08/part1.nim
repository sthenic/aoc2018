import strutils


proc get_number(s: var string, n: var int): bool =
   var pos = 0
   var number = ""
   # Get digits.
   while pos < len(s) and s[pos] in {'0'..'9'}:
      add(number, s[pos])
      inc(pos)
   # Remove whitespace.
   while pos < len(s) and s[pos] in {' '}:
      inc(pos)

   s = s[pos..^1]
   if len(number) > 0:
      n = parse_int(number)
      result = true
   else:
      result = false


proc sum_metadata(s: var string): int =
   var nof_children, nof_entries: int
   if not get_number(s, nof_children) or not get_number(s, nof_entries):
      return -1

   # Handle subtrees.
   for i in 0..<nof_children:
      inc(result, sum_metadata(s))

   # Handle metadata.
   for i in 0..<nof_entries:
      var e = 0
      if get_number(s, e):
         inc(result, e)


when is_main_module:
   var s = read_file("input.txt").strip()
   echo "The sum of all metadata entries is: ", sum_metadata(s), ".\n"
