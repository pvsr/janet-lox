(defn install [manifest &]
  (bundle/add manifest "lox")
  (bundle/add-bin manifest "bin/lox"))
