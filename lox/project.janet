(declare-project
  :name "lox"
  :description ```lox```
  :license "MIT"
  :author ```Peter Rice```
  :dependencies @["spork" "judge"]
  :version "0.0.1")

(declare-binscript
  :main "bin/lox"
  :hardcode-syspath true
  :is-janet true)

(declare-executable
  :name "lox"
  :entry "./lox.janet")
