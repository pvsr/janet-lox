(import ./scanner)
(import ./parser)
(import ./interpreter)

(defn process [contents]
  (-> contents
      scanner/scan
      parser/make-parser
      :parse
      interpreter/interpret))

(defn run-repl [process]
  (os/sigaction :int nil)
  (print "janet-lox interpreter 0.0.1")
  (loop [res :iterate (getline "> ")
         :let [line (string res)]
         :unless (= res :cancel)
         :until (= line "")]
    (try (process line) ([err] (printf "error: %s" err)))))

(defn main [_ &opt path & args]
  (unless (empty? args) (error "expected 0 or 1 args"))
  (if (nil? path)

    (with-dyns [:expr-out stderr] (run-repl process))
    (process (slurp path))))
