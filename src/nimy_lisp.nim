import sequtils

proc dollar[T](s: T): string =
  result = $s

proc mapconcat*[T](s: openArray[T]; sep = " "; op: proc(x: T): string = dollar): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  for x in s:
    result.add op(x) & sep

when isMainModule:
  import strformat
  let
    s1 = @["abc", "def", "ghi"]
    s2 = ["abc", "def", "ghi"]
    s3 = [1, 2, 3]
  echo fmt"`{s1.mapconcat()}'"
  echo fmt"`{s2.mapconcat()}'"
  echo fmt"`{s3.mapconcat()}'"
  let foo = s3.mapconcat("\n", proc(x: int): string = "Ha: " & $x)
  echo fmt"`{foo}'"
