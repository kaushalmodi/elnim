import sequtils

proc dollar[T](s: T): string =
  result = $s

proc mapconcat*[T](s: openArray[T]; op: proc(x: T): string = dollar; sep = " "): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  for x in s:
    result.add op(x) & sep

when isMainModule:
  let
    s1 = @["abc", "def", "ghi"]
    s2 = ["abc", "def", "ghi"]
    s3 = [1, 2, 3]
  echo s1.mapconcat()
  echo s2.mapconcat()
  echo s3.mapconcat()
  echo s3.mapconcat(proc(x: int): string = "Ha: " & $x, sep = "\n")
