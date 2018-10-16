import elnim
import unittest

suite "[ifLet]":

  test "[ifLet] simple assignments":
    var res = ""
    ifLet:
      n = 5
      m = n * 5
    do:
      res = "Hallo! " & $n & " and " & $m
    check res == "Hallo! 5 and 25"

  test "[ifLet] assignment with procedure":
    var res = ""
    ifLet:
      a = 5
      b = a * 5
      c = proc(x, y: int): int = x + y
    do:
      res = "Output is: " & $c(a, b)
    check res == "Output is: 30"

  test "[ifLet] multiple line body":
    var res = ""
    ifLet:
      a = 5
      b = a * 5
    do:
      let y = a * b
      proc test(x: int): float =
        result = x.float
      res = "y as float / 10.0 = " & $(test(y) / 10.0)
    check res == "y as float / 10.0 = 12.5"

  test "[ifLet] false by bool":
    var res = ""
    ifLet:
      a = 5
      b = a * 5
      c = false
    do:
      res = "Hallo! " & $a & " and " & $b
    check res == ""

  test "[ifLet] false from proc call":
    proc callFalse(x: int): bool =
      result = if x < 10: false else: true
    var res = ""
    ifLet:
      a = 5
      b = a * 5
      c = callFalse(a)
    do:
      res = "a is smaller 10!"
    check res == ""

  test "[ifLet] assigning a seq":
    var res: seq[int] = @[]
    ifLet:
      a = @[1, 2, 3]
      b = 5
    do:
      for x in a:
        res.add x * b
    check res == @[5, 10, 15]

  test "[ifLet] false from emtpy seq":
    proc emptySeq(x: int): seq[int] =
      for i in 0 ..< x:
        result.add i
    var res = ""
    ifLet:
      a = 0
      b = emptySeq(a)
    do:
      res = "Seq is empty!"
    check res == ""

  test "[ifLet] non nil ref object":
    var obj = new int
    obj[] = 5
    var res = 0
    ifLet:
      a = obj
      b = 5
    do:
      res = obj[] + b
    check res == 10

  test "[ifLet] false due to nil pointer":
    var somePtr: pointer = nil
    var res = ""
    ifLet:
      a = 5
      b = a * 5
      c = somePtr
    do:
      res = "Pointer is nil: " & $(c.isNil)
    check res == ""

  test "[ifLet] assignment with else":
    var res = ""
    ifLet:
      a = 5
      b = true
    do:
      res = "Output: " & $a
    else:
      res = "It was false!"
    check res == "Output: 5"

  test "[ifLet] false assignment with else":
    var res = ""
    ifLet:
      a = 5
      b = false
    do:
      res = "Output: " & $a
    else:
      res = "It was false!"
    check res == "It was false!"

  test "[ifLet] false from empty seq":
    var res = ""
    ifLet:
      a: seq[string] = @[]
      b = 2
    do:
      res = "b = " & $b
    else:
      res = "empty seq"
    check res == "empty seq"

  test "[ifLet] two ifLet after another":
    var res = 0
    ifLet:
      a = 5
      b = 10
    do:
      res = a + b

    ifLet:
      a = 1
      b = 2
    do:
      res += a + b

    check res == 18
