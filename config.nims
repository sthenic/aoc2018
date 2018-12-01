import ospaths

task build, "Compile and run.":
   if paramCount() < 2:
      echo "Missing day as argument."
      quit(-1)

   let day = paramStr(2)
   withDir("src" / day):
      exec("nim c -d:release --passC:-flto --passL:-s --gc:markAndSweep part1")
      exec("nim c -d:release --passC:-flto --passL:-s --gc:markAndSweep part2")
      echo "---- Day ", day, ", part 1 ----"
      exec("./part1")
      echo "---- Day ", day, ", part 2 ----"
      exec("./part2")

   setCommand "nop"
