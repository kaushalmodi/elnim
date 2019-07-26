## :Author: Kaushal Modi
## :License: MIT
##
## Introduction
## ============
## This module implements few Emacs-Lisp equivalent procs.
##
## Source
## ======
## `Repo link <https://github.com/kaushalmodi/elnim>`_

import macros, sequtils
export sequtils

when defined(debugIfLet):
  import typetraits

proc equal[T](x, y: T): bool =
  ## Generic proc to check if inputs ``x`` and ``y`` are equal.
  ##
  ## This proc is used in ``assoc`` and ``delete``.
  result = x == y

proc dollar[T](s: T): string =
  ## Generic proc to stringify input ``s``.
  ##
  ## This proc is used in ``mapconcat``.
  result = $s

proc car*[T](s: openArray[T]): T =
  ## Return the first element of ``s``.
  ##
  ## If ``s`` has zero elements, throw an error. Unlike Emacs-Lisp,
  ## Nim cannot return a true "nil" value in this case.
  runnableExamples:
    doAssert @["abc", "def", "ghi"].car() == "abc"
    doAssert [1, 2, 3].car() == 1
    try:
      discard seq[string](@[]).car()
    except AssertionError:
      echo "Illegal: 'car' was provided a zero-length seq/array."

  doAssert s.len > 0
  return s[0]

proc cdr*[T](s: openArray[T]): seq[T] =
  ## Return a sequence of all elements excluding the first element of ``s``.
  ##
  ## If ``s`` has one or less elements, an empty sequence of type
  ## **T** is returned.
  runnableExamples:
    doAssert @["abc", "def", "ghi"].cdr() == @["def", "ghi"]
    doAssert [1, 2, 3].cdr() == @[2, 3]
    doAssert [1].cdr() == seq[int](@[])
    doAssert @["a"].cdr() == seq[string](@[])
    doAssert seq[string](@[]).cdr() == seq[string](@[]) # zero length seq
    doAssert array[0, int]([]).cdr() == seq[int](@[]) # zero length array

  if s.len <= 0:
    return
  else:
    return s[1 .. s.high]

proc assoc*[T](alist: openArray[seq[T]]; key: T; testproc: proc(x,
    y: T): bool = equal): seq[T] =
  ## Return the first nested sequence whose first element matches with
  ## ``key`` using the ``testproc`` proc (which defaults to ``equal``).
  ##
  ## Input ``alist`` is an array or sequence of sequences of type
  ## ``seq[T]``.
  ##
  ## The ``alist`` and ``key`` arguments are swapped compared to its
  ## Emacs-Lisp version so that we can conveniently do
  ## ``alist.assoc(key)``.
  runnableExamples:
    doAssert @[@["a", "b"], @["c", "d"]].assoc("a") == @["a", "b"]
    doAssert [@[1.11, 2.11, 3.11], @[4.11, 5.11, 6.11], @[4.11, 40.11,
        400.11]].assoc(4.11) == @[4.11, 5.11, 6.11]
    doAssert [@[1, 2, 3], @[], @[4, 40, 400]].assoc(10) == seq[int](@[]) # alist containing a zero-length seq
    doAssert seq[seq[string]](@[]).assoc("a") == seq[string](@[]) # zero length alist

  for s in alist:
    if s.len == 0:
      continue # car cannot accept seqs of zero length
    if testproc(s.car(), key):
      return s

proc delete*[T](s: openArray[T]; el: T; testproc: proc(x,
    y: T): bool = equal): seq[T] =
  ## Return a sequence containing all elements from ``s`` that do not
  ## match with ``el``. The match is done using the ``testproc`` proc
  ## (which defaults to ``equal``).
  runnableExamples:
    doAssert @[123, 456, 789, 123].delete(123) == @[456, 789]
    doAssert ["123", "456", "789", "123"].delete("456") == @["123", "789", "123"]
    doAssert seq[string](@[]).delete("a") == seq[string](@[])

  for sElem in s:
    if not testproc(sElem, el):
      result.add(sElem)

proc mapconcat*[T](s: openArray[T]; sep = " "; op: proc(
    x: T): string = dollar): string =
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
  ## Return ``true`` if ``x`` represents something like a *non-nil*
  ## value in Emacs-Lisp.
  ##
  ## **Note**: Compile with ``-d:debugIfLet`` to print if ``x`` is of
  ## unsupported type.
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
    # Types currently not supported.
    when defined(debugIfLet):
      echo "Invalid type: ", $(name(T))
    result = false

macro ifLet*(letExpr: untyped; trueCond: untyped;
    falseCond: untyped = newEmptyNode()): untyped =
  ## Macro similar to Emacs Lisp's ``if-let*`` macro.
  ## Takes a set of assignments ``letExpr`` and checks if all of those
  ## are valid (in elisp, "validity" is checked by non-nil-ness) by
  ## calling ``isValid`` on the values being assigned. If all are
  ## valid, the body after ``do:`` will be evaluated, otherwise the body
  ## after ``else:`` is evaluate.
  ##
  ## **Note**: Compile with ``-d:debugIfLet`` to see its resulting code.
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
      # add it. Convert each assignment to a ``nnkIdentDefs``, so it's
      # valid within a ``nnkLetSection``.
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

  # ``newEmptyNode()`` isn't really the best solution as an optional
  # arg. Need to check for ``nnkCall`` and the symbol identifier.
  var elseStmts = newStmtList()
  if falseCond.kind == nnkCall and eqIdent(falseCond[0], "newEmptyNode"):
    elseStmts = quote do:
      discard
  else:
    # Get content of ``else:`` branch.
    elseStmts = falseCond[0]

  # Now call ``isValid`` on all RHS of the assignments.
  var asgnWith: seq[NimNode]
  for asgn in letStmts:
    asgnWith.add nnkCall.newTree(ident"isValid", asgn[0])

  # Generate the if statement with the call to ``allIt`` and the body
  # of the ``do:``. If all ifLet expessions are not valid, execute the
  # body of ``else:``.
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
