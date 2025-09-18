This is a Janet implementation of the Lox programming language, from [_Crafting Interpreters_](https://www.craftinginterpreters.com/) by Robert Nystrom.
It's loosely based on `jlox`, the Java tree-walking interpreter from the book,
but takes advantage of Janet features to simplify the code when possible.

Notably:

 - The scanner is a [parsing expression grammar](https://janet-lang.org/docs/peg.html)
 - Scoping is built on top of [dynamic bindings](https://janet-lang.org/docs/fibers/dynamic_bindings.html)
 - The repl uses Janet's `getline`, which wraps [linenoise](https://github.com/antirez/linenoise/)
 - While Janet has support for object-oriented programming, most of the code is written in a more functional style.
For instance the visitor pattern is replaced by pattern matching

## Progress
 - [x] Scanning
 - [x] Representing Code
 - [x] Parsing Expressions
 - [x] Evaluating Expressions
 - [x] Statements and State
 - [x] Control Flow
 - [x] Functions
 - [ ] Resolving and Binding
 - [ ] Classes
 - [ ] Inheritance
