# Package

version       = "0.1.0"
author        = "Kaushal Modi"
description   = "Emacs-Lisp equivalent procs and templates in Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.0"

import ospaths # for `/`
let
  pkgName = "nimy_lisp"
  srcFile = "src" / (pkgName & ".nim")
  genDocCmd = "nim doc " & srcFile
  htmlFile = "src" / (pkgName & ".html")

task test, "Run tests via 'nim doc' and runnableExamples":
  exec(genDocCmd)

task deploy, "Deploy doc html to public/index.html":
  let
    deployDir = "public"
    deployHtmlFile = deployDir / "index.html"
  if not fileExists(htmlFile):
    exec(genDocCmd)
  mkDir(deployDir)
  cpFile(htmlFile, deployHtmlFile)
  # Delete the line trying to load dochack.js because that script
  # doesn't exist.
  exec("sed -i '/dochack/d' " & deployHtmlFile)
  # Hack to remove the search box as it doesn't work.
  exec(r"sed -i 's|^\s*div#searchInputDiv {|\0 display: none;|' " & deployHtmlFile)
