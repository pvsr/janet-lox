(use judge)
(use ../lox/scanner)

(test (scan "1 + 2")
      @[{:line 1 :token [:num 1]}
        {:line 1 :token [:plus]}
        {:line 1 :token [:num 2]}])
(test (scan "true or false")
      @[{:line 1 :token [:true]}
        {:line 1 :token [:or]}
        {:line 1 :token [:false]}])
(test (scan "print 2 * (1 + 2)")
      @[{:line 1 :token [:print]}
        {:line 1 :token [:num 2]}
        {:line 1 :token [:star]}
        {:line 1 :token [:left-paren]}
        {:line 1 :token [:num 1]}
        {:line 1 :token [:plus]}
        {:line 1 :token [:num 2]}
        {:line 1 :token [:right-paren]}])
(test (scan "if (true) print nil;")
      @[{:line 1 :token [:if]}
        {:line 1 :token [:left-paren]}
        {:line 1 :token [:true]}
        {:line 1 :token [:right-paren]}
        {:line 1 :token [:print]}
        {:line 1 :token [:nil]}
        {:line 1 :token [:semicolon]}])
(test (scan "if (true) { print nil; }")
      @[{:line 1 :token [:if]}
        {:line 1 :token [:left-paren]}
        {:line 1 :token [:true]}
        {:line 1 :token [:right-paren]}
        {:line 1 :token [:left-brace]}
        {:line 1 :token [:print]}
        {:line 1 :token [:nil]}
        {:line 1 :token [:semicolon]}
        {:line 1 :token [:right-brace]}])
