# Package

version       = "0.1.0"
author        = "Kaushal Modi"
description   = "Emacs-Lisp equivalent procs and templates in Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.1"

import ospaths # for `/`
let
  pkgName = "nimy_lisp"
  srcFile = "src" / (pkgName & ".nim")

task test, "Run tests in nimy_lisp.nim":
  exec("nim doc " & srcFile)
