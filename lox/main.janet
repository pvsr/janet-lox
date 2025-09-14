(import ./scanner)
(import ./parser)
(import ./interpreter)
(import ./repl)

(defn process [contents]
  (-> contents
      scanner/scan
      parser/make-parser
      :parse
      interpreter/interpret))

(defn main [_ &opt path & args]
  (unless (empty? args) (error "expected 0 or 1 args"))
  (if (nil? path)
    (repl/run process)
    (with-dyns [:expr-out @""] (process (slurp path)))))
