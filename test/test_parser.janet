(use judge)
(use ../lox/scanner)
(use ../lox/parser)

(defn parse [tokens] (:parse (make-parser tokens)))

(test (parse @[{:token [:num 1]}
               {:token [:plus]}
               {:token [:num 2]}
               {:token [:semicolon]}])
      @[[:expr
         [:binary
          [:literal 1]
          {:token [:plus]}
          [:literal 2]]]])
(test (parse @[{:token [:print]}
               {:token [:num 1]}
               {:token [:plus]}
               {:token [:num 2]}
               {:token [:semicolon]}])
      @[[:print
         [:binary
          [:literal 1]
          {:token [:plus]}
          [:literal 2]]]])

(test (parse @[{:token [:if]}
               {:token [:left-paren]}
               {:token [:true]}
               {:token [:right-paren]}
               {:token [:print]}
               {:token [:nil]}
               {:token [:semicolon]}])
      @[[:if
         [:literal true]
         [:print [:literal nil]]
         nil]])

(test (parse @[{:token [:if]}
               {:token [:left-paren]}
               {:token [:true]}
               {:token [:right-paren]}
               {:token [:print]}
               {:token [:true]}
               {:token [:semicolon]}
               {:token [:else]}
               {:token [:print]}
               {:token [:false]}
               {:token [:semicolon]}])
      @[[:if
         [:literal true]
         [:print [:literal true]]
         [:print [:literal false]]]])

(defn scan-parse [input] (parse (scan input)))

(test (scan-parse "var three;")
  @[[:var
     {:line 1 :token [:ident "three"]}
     nil]])
(test (scan-parse "var three = 1 + 2; print three;")
      @[[:var {:line 1 :token [:ident "three"]}
         [:binary
          [:literal 1]
          {:line 1 :token [:plus]}
          [:literal 2]]]
        [:print [:variable {:line 1 :token [:ident "three"]}]]])
