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

macro ifLet*(letExpr: untyped, trueCond: untyped, falseCond: untyped = newEmptyNode()): untyped =
  ## Macro similar to Emacs Lisp's ``if-let*`` macro.
  ## Takes a set of assignments ``letExpr`` and checks if all of those
  ## are valid (in elisp, "validity" is checked by non-nil-ness) by
  ## calling ``isValid`` on the values being assigned. If all are
  ## valid, the body after ``do:`` will be evaluated, otherwise the body
  ## after ``else:`` is evaluate.
  ##
  ## Note: Compile with `-d:debugIfLet` to see its resulting code.
  ##
  ## .. code-block::
  ##    :test:
  ##    ifLet:
  ##      a = 5
  ##      b = a * 5
  ##      c = proc(a, b: int): int = a + b
  ##    do:
  ##      echo "Output is: ", c(a, b)
  ##    else:
  ##      echo "Either a or b had an invalid value."
  ##
  ## This macro rewrites the above code to:
  ##
  ## .. code-block::
  ##    block:
  ##      let
  ##        a = 5
  ##        b = a * 5
  ##        c = proc (a, b: int): int =
  ##          a + b
  ##      if [isValid(a), isValid(b), isValid(c)].allIt(it):
  ##        echo "Output is: ", c(a, b)
  ##      else:
  ##        echo "Either a or b had an invalid value."

  var letStmts = nnkLetSection.newTree()
  for e in letExpr:
    case e.kind
    of nnkAsgn:
      # Iterate over all given statements. If we find an assignment,
      # add it. Convert each assignment to a `nnkIdentDefs`, so it's
      # valid within a `nnkLetSection`.
      letStmts.add nnkIdentDefs.newTree(
        e[0],
        newEmptyNode(),
        e[1])
    of nnkCall:
      # If we find a tree like the following, extract the assign
      # statements from those.
      #
      # Call
      #   Ident "a"              # need this
      #   StmtList
      #     Asgn                 # and this
      #       BracketExpr
      #         Ident "seq"
      #         Ident "string"
      #       Prefix
      #         Ident "@"
      #         Bracket
      let
        letIdent = e[0]
        asgn = e[1][0]
      letStmts.add nnkIdentDefs.newTree(
        letIdent,
        asgn[0],
        asgn[1])
    else:
      error("Unexpected node of kind " & $e.kind & " found. Content:\n" & e.repr)

  # `newEmptyNode()` isn't really the best solution as an optional
  # arg. Need to check for `nnkCall` and the symbol identifier.
  var elseStmts = newStmtList()
  if falseCond.kind == nnkCall and eqIdent(falseCond[0], "newEmptyNode"):
    elseStmts = quote do:
      discard
  else:
    # Get content of `else:` branch.
    elseStmts = falseCond[0]

  # Now call `isValid` on all RHS of the assignments.
  var asgnWith: seq[NimNode]
  for asgn in letStmts:
    asgnWith.add nnkCall.newTree(ident"isValid", asgn[0])

  # Generate the if statement with the call to `allIt` and the body of
  # the `do:`. If all ifLet expessions are not valid, execute the body
  # of `else:`.
  let inCheck = quote do:
    if `asgnWith`.allIt(it):
      `trueCond`
    else:
      `elseStmts`

  # Assign everything to the result statements.
  result = newStmtList()
  result.add letStmts
  result.add inCheck
  result = quote do:
    block:
      `result`
  when defined(debugIfLet):
    echo result.repr & "\n\n"
