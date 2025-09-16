(declare-project
  :name "lox"
  :description ```Implementation of the Lox programming language from Crafting Interpreters```
  :license "MIT"
  :author ```Peter Rice```
  :dependencies @["spork"]
  :version "0.0.1")

(declare-executable
  :name "lox"
  :entry "lox/main.janet"
  :install true)
