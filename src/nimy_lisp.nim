## :Author: Kaushal Modi
## :License: MIT
##
## Introduction
## ============
## This module implements few Emacs-Lisp equivalent procs.
##
## Source
## ======
## `Repo link <https://github.com/kaushalmodi/nimy_lisp>`_

import macros, sequtils
export sequtils

proc dollar[T](s: T): string =
  result = $s

proc mapconcat*[T](s: openArray[T]; sep = " "; op: proc(x: T): string = dollar): string =
  ## Concatenate elements of ``s`` after applying ``op`` to each element.
  ## Separate each element using ``sep``.
  ##
  ## The signature of this proc differs from its equivalent ``mapconcat`` in Emacs,
  ## - so that we can do ``s.mapconcat()`` in Nim.
  ## - Also it is more common for a user to change the ``sep`` parameter
  ##   than the ``op`` parameter, so move ``op`` to the last position.
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

proc isValid*[T](x: T): bool =
  when T is bool:
    result = x
  elif T is SomeNumber:
    result = true
  elif T is array | seq:
    result = if x.len > 0: true else: false
  elif (T is proc):
    result = not x.isNil
  elif T is ptr | pointer | ref:
    result = not x.isNil
  else:
    # currently not supported
    when defined(debugIfLet):
      echo "Invalid type: ", $(name(T))
    result = false

macro if_let*(stmts: untyped): untyped =
  ## Macro similar to Emacs Lisp's `when-let` macro.
  ## Takes a set of assignments and checks if all of those
  ## are valid (in elisp if they are `nil`) by calling `isValid`
  ## on the values being assigned. If all are valid, the body
  ## after `op:` will be evaluated, otherwise nothing happens.
  ## Note: compile with `-d:debugIfLet` to see its resulting
  ## code.
  ##
  ## ..code-block:
  ##   if_let:
  ##     a = 5
  ##     b = a * 5
  ##     c = proc(a, b: int): int = a + b
  ##     op:
  ##       echo "Output is: ", c(a, b)
  ##
  ##   # which will be rewritten to:
  ##   let
  ##     a = 5
  ##     b = a * 5
  ##     c = proc(a, b: int): int = a + b
  ##   if [isValid(a), isValid(b), isValid(c)].allIt(it):
  ##     echo "Output is: ", c(a, b)
  var letStmts = nnkLetSection.newTree()
  var opStmts = newStmtList()
  var elseStmts = newStmtList()

  # check if we have a `false` branch:
  let haveFalse = if eqIdent(stmts[^1][0], "elsedo"): true else: false
  if not haveFalse:
    # in this case just add a `discard` to the `elseStmts`
    elseStmts.add quote do:
      discard

  # iterate over all given statements. If we find an
  # assignment, add
  for stmt in stmts:
    case stmt.kind
    of nnkAsgn:
      # convert each assignment to a `nnkIdentDefs`, so it's valid within
      # a `nnkLetSection`
      letStmts.add nnkIdentDefs.newTree(
        stmt[0],
        newEmptyNode(),
        stmt[1]
      )
    of nnkCall:
      if eqIdent(stmt[0], "op"):
        # add stmts for `true` branch
        opStmts.add stmt[1]
        if not haveFalse:
          # afterwards nothing expected, so break
          break
      elif eqIdent(stmt[0], "elsedo"):
        # add stmts for `false` branch
        elseStmts.add stmt[1]
        # afterwards nothing expected, so break
        break
    else:
      error("Unexpected node of kind " & $stmt.kind & " found. Content:\n" & stmt.repr)

  # now call `isValid` on all RHS of the assignments
  var asgnWith: seq[NimNode]
  for asgn in letStmts:
    asgnWith.add nnkCall.newTree(ident"isValid", asgn[2])

  # generate the if statement with the call to `allIt` and the
  # body of the `op:`
  let inCheck = quote do:
    if `asgnWith`.allIt(it):
      `opStmts`
    else:
      `elseStmts`

  # assign everything to the result statements
  result = newStmtList()
  result.add letStmts
  result.add inCheck
  when defined(debugIfLet):
    echo result.repr
