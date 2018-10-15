import nimy_lisp
import unittest

suite "[if-let]":

  test "[if-let] simple assignments":
    var res = ""
    if_let:
      n = 5
      m = n * 5
    do:
      res = "Hallo! " & $n & " and " & $m
    check res == "Hallo! 5 and 25"

  test "[if-let] assignment with procedure":
    var res = ""
    if_let:
      a = 5
      b = a * 5
      c = proc(x, y: int): int = x + y
    do:
      res = "Output is: " & $c(a, b)
    check res == "Output is: 30"

  test "[if-let] multiple line body":
    var res = ""
    if_let:
      a = 5
      b = a * 5
    do:
      let y = a * b
      proc test(x: int): float =
        result = x.float
      res = "y as float / 10.0 = " & $(test(y) / 10.0)
    check res == "y as float / 10.0 = 12.5"

  test "[if-let] false by bool":
    var res = ""
    if_let:
      a = 5
      b = a * 5
      c = false
    do:
      res = "Hallo! " & $a & " and " & $b
    check res == ""

  test "[if-let] false from proc call":
    proc callFalse(x: int): bool =
      result = if x < 10: false else: true
    var res = ""
    if_let:
      a = 5
      b = a * 5
      c = callFalse(a)
    do:
      res = "a is smaller 10!"
    check res == ""

  test "[if-let] assigning a seq":
    var res: seq[int] = @[]
    if_let:
      a = @[1, 2, 3]
      b = 5
    do:
      for x in a:
        res.add x * b
    check res == @[5, 10, 15]

  test "[if-let] false from emtpy seq":
    proc emptySeq(x: int): seq[int] =
      for i in 0 ..< x:
        result.add i
    var res = ""
    if_let:
      a = 0
      b = emptySeq(a)
    do:
      res = "Seq is empty!"
    check res == ""

  test "[if-let] non nil ref object":
    var obj = new int
    obj[] = 5
    var res = 0
    if_let:
      a = obj
      b = 5
    do:
      res = obj[] + b
    check res == 10

  test "[if-let] false due to nil pointer":
    var somePtr: pointer = nil
    var res = ""
    if_let:
      a = 5
      b = a * 5
      c = somePtr
    do:
      res = "Pointer is nil: " & $(c.isNil)
    check res == ""

  test "[if-let] assignment with else":
    var res = ""
    if_let:
      a = 5
      b = true
    do:
      res = "Output: " & $a
    else:
      res = "It was false!"
    check res == "Output: 5"

  test "[if-let] false assignment with else":
    var res = ""
    if_let:
      a = 5
      b = false
    do:
      res = "Output: " & $a
    else:
      res = "It was false!"
    check res == "It was false!"

  test "[if-let] false from empty seq":
    var res = ""
    if_let:
      a: seq[string] = @[]
      b = 2
    do:
      res = "b = " & $b
    else:
      res = "empty seq"
    check res == "empty seq"

  test "[if-let] two if_let after another":
    var res = 0
    if_let:
      a = 5
      b = 10
    do:
      res = a + b

    if_let:
      a = 1
      b = 2
    do:
      res += a + b

    check res == 18
