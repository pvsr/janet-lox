(use judge)
(use ../lox/interpreter)

(test (evaluate [:literal false]) false)
(test (evaluate [:unary {:token [:minus]} [:literal 1]]) -1)
(test (evaluate [:unary {:token [:bang]} [:literal false]]) true)
(test (evaluate [:unary {:token [:bang]} [:literal 1]]) false)

(def add [:binary [:literal 1] {:token [:plus]} [:literal 2]])
(def concat [:binary [:literal "1"] {:token [:plus]} [:literal "2"]])
(test (evaluate add) 3)
(test (evaluate [:binary add {:token [:plus]} [:literal 2]]) 5)
(test (evaluate concat) "12")
(test (evaluate [:binary [:literal 1] {:token [:minus]} [:literal 2]]) -1)

(test-error (evaluate [:unary {:token [:minus]} [:literal ""]])
            "Operand must be number")
(test-error (evaluate [:binary [:literal 1] {:token [:plus]} [:literal "2"]])
            "Operands must be two numbers or two strings")
(test-error (evaluate [:binary [:literal "1"] {:token [:plus]} [:literal 2]])
            "Operands must be two numbers or two strings")
(test-error (evaluate [:binary [:literal true] {:token [:plus]} [:literal true]])
            "Operands must be two numbers or two strings")
(test-error (evaluate [:binary [:literal ""] {:token [:minus]} [:literal 2]])
            "Operands must be numbers")
(test-error (evaluate [:binary [:literal 1] {:token [:minus]} [:literal ""]])
            "Operands must be numbers")
(test-error (evaluate [:binary [:literal 1] {:token [:pow]} [:literal 2]])
            "Unknown operator :pow")

(test (evaluate [:binary [:literal 1] {:token [:greater]} [:literal 2]]) false)
(test (evaluate [:binary [:literal 2] {:token [:greater-eq]} [:literal 2]]) true)
(test (evaluate [:binary [:literal "12"] {:token [:eq-eq]} concat]) true)
(test (evaluate [:binary [:literal 1] {:token [:eq-eq]} [:literal 1]]) true)
(test (evaluate [:binary [:literal 1] {:token [:eq-eq]} [:literal 2]]) false)
(test (evaluate [:binary [:literal 1] {:token [:eq-eq]} [:literal "1"]]) false)

(def nan [:binary [:literal 0] {:token [:slash]} [:literal 0]])
(test (evaluate [:binary nan {:token [:eq-eq]} nan]) false)
(test (evaluate [:binary [:literal 1] {:token [:bang-eq]} [:literal 1]]) false)
(test (evaluate [:binary [:literal 1] {:token [:bang-eq]} [:literal 2]]) true)
(test (evaluate [:logical [:literal false] {:token [:and]} [:literal true]]) false)
(test (evaluate [:logical [:literal false] {:token [:or]} [:literal true]]) true)
(test (evaluate [:logical [:literal false] {:token [:or]} [:literal false]]) false)

(test-stdout (execute [:print [:literal nil]]) `
  nil
`)
(test-stdout (execute [:print [:literal true]]) `
  true
`)
(test-stdout (execute [:print [:literal 1]]) `
  1
`)
(test-stdout (execute [:print [:literal 1.1]]) `
  1.1
`)
(test-stdout (execute [:print [:literal "one"]]) `
  "one"
`)
(test-stdout (execute [:if [:literal true] [:print [:literal 1]] nil]) `
  1
`)
(test-stdout (execute [:if [:literal true] [:print [:literal 1]] [:print [:literal 2]]]) `
  1
`)
# TODO judge fails on empty stdout
# (test-stdout (execute [:if [:literal false] [:print [:literal 1]] nil]) "")
(test-stdout (execute [:if [:literal false] [:print [:literal 1]] [:print [:literal 2]]]) `
  2
`)
