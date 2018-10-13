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

