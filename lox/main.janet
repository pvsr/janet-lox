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

    (with-dyns [:expr-out stderr] (repl/run process))
    (process (slurp path))))
