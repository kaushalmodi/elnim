import sequtils

proc dollar[T](s: T): string =
  result = $s

proc mapconcat*[T](s: openArray[T]; sep = " "; op: proc(x: T): string = dollar): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  for i, x in s:
    result.add(op(x))
    if i < s.high:
      result.add(sep)

proc member*[T](el: T; s: openArray[T]): bool =
  ## Return ``true`` if ``el`` is an element in ``s``.
  ## This proc is like ``find`` but with args in reverse order, and
  ## returns a bool instead.
  result = false
  if s.find(el) >= 0:
    result = true

when isMainModule:
  let
    s1 = @["abc", "def", "ghi"]
    s2 = ["abc", "def", "ghi"]
    s3 = [1, 2, 3]
    s4: seq[string] = @[]

  doAssert s1.mapconcat() == "abc def ghi"
  doAssert s2.mapconcat() == "abc def ghi"
  doAssert s3.mapconcat() == "1 2 3"
  doAssert s3.mapconcat("\n", proc(x: int): string = "Ha: " & $x) == "Ha: 1\nHa: 2\nHa: 3"
  doAssert s4.mapconcat() == ""

  doAssert "abc".member(s1) == true
  doAssert "abc".member(s2) == true
  doAssert "a".member(s2) == false
  doAssert 1.member(s3) == true
  doAssert 100.member(s3) == false
  doAssert "".member(s4) == false
  doAssert "a".member(s4) == false

  echo "\nTests passed!"
