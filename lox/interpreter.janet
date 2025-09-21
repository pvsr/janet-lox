(defn- unary-op [op right]
  (match ((op :token) 0)
    :minus (if (number? right) (- right) (error "Operand must be number"))
    :bang (not right)
    token (errorf "Unknown operator %q" token)))

(defn- strings [op]
  |(if (and (string? $0) (string? $1))
     (op $0 $1)
     (error "Operands must be strings")))

(defn- numbers [op]
  |(if (and (number? $0) (number? $1))
     (op $0 $1)
     (error "Operands must be numbers")))

(defn- bin-op [left op right]
  ((match ((op :token) 0)
     :plus (cond
             (and (number? left) (number? right)) +
             (and (string? left) (string? right)) string
             (error "Operands must be two numbers or two strings"))
     :minus (numbers -)
     :star (numbers *)
     :slash (numbers /)
     :eq-eq =
     :bang-eq not=
     :greater (numbers >)
     :greater-eq (numbers >=)
     :less (numbers <)
     :less-eq (numbers <=)
     token (errorf "Unknown operator %q" token))
    left right))

(defn- declare-var [{:token [_ name]}]
  (setdyn name @[]))

(defn- define-var [{:token [_ name]} val]
  (setdyn name @[val]))

(defn- set-var [{:token [_ name]} val]
  (if-let [ref (dyn name)]
    (do (array/clear ref) (array/push ref val))
    (errorf "Undefined variable '%s'." name)))

(defn- get-var [{:token [_ name]}]
  (if-let [@[val] (dyn name)]
    val
    (errorf "Undefined variable '%s'." name)))

(defn evaluate [expr]
  (match expr
    [:literal value] value
    [:grouping expr] (evaluate expr)
    [:unary op right] (unary-op op (evaluate right))
    [:binary left op right] (bin-op (evaluate left) op (evaluate right))
    [:logical left op right] (case ((op :token) 0)
                               :or (if-let [left (evaluate left)] left (evaluate right))
                               :and (if-let [left (evaluate left)] (evaluate right) left))
    [:assign name value] (set-var name (evaluate value))
    [:variable name] (get-var name)
    [:call callee paren args] (do
                                (def callee (evaluate callee))
                                (unless (has-key? callee :fun)
                                  (error "Can only call functions and classes."))
                                (def {:fun callee :arity arity} callee)
                                (unless (= arity (length args))
                                  (errorf "Expected %d arguments but got %d." arity (length args)))
                                (callee ;(map evaluate args)))
    [ty] (errorf "Unknown expression type %s" ty)
    (errorf "Invalid expression %q" expr)))

(var execute nil)

(defn- execute-block [stmts]
  (each stmt stmts (execute stmt)))

(varfn execute [stmt]
  (match stmt
    [:print expr] (printf "%s" (match (evaluate expr)
                                 nil "nil"
                                 val (string val)))
    [:expr expr] (let [val (evaluate expr)]
                   (if-let [out (dyn :expr-out)] (xprintf out "%Q" val)))
    [:return word val] (yield (when val (evaluate val)))
    [:if cond then else] (do
                           (cond
                             (evaluate cond) (execute then)
                             (not (nil? else)) (execute else)))
    [:while cond body] (while (evaluate cond) (execute body))
    [:block stmts] (with-dyns [] (execute-block stmts))
    [:var name init] (let [val (and init (evaluate init))]
                       (declare-var name)
                       (when init (set-var name val)))
    [:fun name params body]
    (let [arity (length params)
          env (table/clone (curenv))
          call (fn [args]
                 (loop [i :range [arity]
                        :let [name (params i) arg (args i)]]
                   (define-var name arg))
                 (execute-block body))
          fun (fn [& args]
                (def f (fiber/new call
                                  :y # catch yield
                                  (table/clone env)))
                (resume f args)
                (fiber/last-value f))]
      (define-var name {:fun fun :arity arity}))
    [ty] (errorf "Unknown statement type %s" ty)
    (errorf "Invalid statement %q" stmt)))

(defn- define-fun [name arity fun]
  (setdyn name @[{:arity arity :fun fun}]))

(defn interpret [stmts]
  (define-fun "clock" 0 |(os/clock :realtime :int))
  (define-fun "toString" 1 string)
  # TODO error handling
  (each stmt stmts (execute stmt)))
