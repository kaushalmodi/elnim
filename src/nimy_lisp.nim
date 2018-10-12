import sequtils

proc dollar[T](s: T): string =
  result = $s

proc mapconcat*[T](s: openArray[T]; sep = " "; op: proc(x: T): string = dollar): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  runnableExamples:
    doAssert @["abc", "def", "ghi"].mapconcat() == "abc def ghi"
    doAssert ["abc", "def", "ghi"].mapconcat() == "abc def ghi"
    doAssert [1, 2, 3].mapconcat() == "1 2 3"
    doAssert [1, 2, 3].mapconcat("\n", proc(x: int): string = "Ha: " & $x) == "Ha: 1\nHa: 2\nHa: 3"
    doAssert seq[string](@[]).mapconcat() == ""

  for i, x in s:
    result.add(op(x))
    if i < s.high:
      result.add(sep)

proc member*[T](el: T; s: openArray[T]): bool =
  ## Return ``true`` if ``el`` is an element in ``s``.
  ## This proc is like ``find`` but with args in reverse order, and
  ## returns a bool instead.
  runnableExamples:
    doAssert "abc".member(@["abc", "def", "ghi"]) == true
    doAssert "abc".member(["abc", "def", "ghi"]) == true
    doAssert "a".member(["abc", "def", "ghi"]) == false
    doAssert 1.member([1, 2, 3]) == true
    doAssert 100.member([1, 2, 3]) == false
    doAssert "".member(seq[string](@[])) == false
    doAssert "a".member(seq[string](@[])) == false

  result = false
  if s.find(el) >= 0:
    result = true
