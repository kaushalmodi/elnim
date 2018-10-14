import nimy_lisp
import unittest

suite "[when-let]":

  test "[when-let] simple assignments":
    var res = ""
    when_let:
      n = 5
      m = n * 5
      op:
        res = "Hallo! " & $n & " and " & $m
    check res == "Hallo! 5 and 25"

  test "[when-let] assignment with procedure":
    var res = ""
    when_let:
      a = 5
      b = a * 5
      c = proc(x, y: int): int = x + y
      op:
        res = "Output is: " & $c(a, b)
    check res == "Output is: 30"

  test "[when-let] multiple line body":
    var res = ""
    when_let:
      a = 5
      b = a * 5
      op:
        let y = a * b
        proc test(x: int): float =
          result = x.float
        res = "y as float / 10.0 = " & $(test(y) / 10.0)
    check res == "y as float / 10.0 = 12.5"

  test "[when-let] false by bool":
    var res = ""
    when_let:
      a = 5
      b = a * 5
      c = false
      op:
        res = "Hallo! " & $a & " and " & $b
    check res == ""

  test "[when-let] false from proc call":
    proc callFalse(x: int): bool =
      result = if x < 10: false else: true
    var res = ""
    when_let:
      a = 5
      b = a * 5
      c = callFalse(a)
      op:
        res = "a is smaller 10!"
    check res == ""

  test "[when-let] assigning a seq":
    var res: seq[int] = @[]
    when_let:
      a = @[1, 2, 3]
      b = 5
      op:
        for x in a:
          res.add x * b
    check res == @[5, 10, 15]

  test "[when-let] false from emtpy seq":
    proc emptySeq(x: int): seq[int] =
      for i in 0 ..< x:
        result.add i
    var res = ""
    when_let:
      a = 0
      b = emptySeq(a)
      op:
        res = "Seq is empty!"
    check res == ""

  test "[when-let] non nil ref object":
    var obj = new int
    obj[] = 5
    var res = 0
    when_let:
      a = obj
      b = 5
      op:
        res = obj[] + b
    check res == 10

  test "[when-let] false due to nil pointer":
    var somePtr: pointer = nil
    var res = ""
    when_let:
      a = 5
      b = a * 5
      c = somePtr
      op:
        res = "Pointer is nil: " & $(c.isNil)
    check res == ""
