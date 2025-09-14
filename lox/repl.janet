(import spork/stream)

(defn- inpput-prompt []
  (prin "> ")
  (:flush stdout))

(defn run [process]
  (var buf @"")
  (os/sigaction :int |(do (buffer/clear buf) (print) (inpput-prompt)) true)
  (with [input (os/open "/dev/stdin" :r)]
    (forever
      (inpput-prompt)
      (prompt :a)
      (forever (match (string (:read input 1))
                 "" (when (empty? buf) (set buf nil) (break))
                 "\n" (break)
                 c (buffer/push-string buf c)))
      (when (nil? buf) (break))
      (try (process buf) ([err] (printf "error: %s" err)))
      (buffer/clear buf))))
