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

(defn- declare-var [name]
  (setdyn name @[]))

(defn- set-var [name val]
  (if-let [ref (dyn name)]
    (do (array/clear ref) (array/push ref val))
    (errorf "Undefined variable '%s'." name)))

(defn- get-var [name]
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
    [:assign {:token [:ident name]} value] (set-var name (evaluate value))
    [:variable {:token [:ident name]}] (get-var name)
    [ty] (errorf "Unknown expression type %s" ty)
    (errorf "Invalid expression %q" expr)))

(var execute nil)

(defn- execute-block [stmts]
  # open new scope
  (with-dyns []
    (each stmt stmts (execute stmt))))

(varfn execute [stmt]
  (match stmt
    [:print expr] (printf "%s" (match (evaluate expr)
                                 nil "nil"
                                 val (string val)))
    [:expr expr] (xprintf (dyn :expr-out @"") "%Q" (evaluate expr))
    # [:return word value] (throw return)
    [:if cond then else] (do
                           (cond
                             (evaluate cond) (execute then)
                             (not (nil? else)) (execute else)))
    [:while cond body] (while (evaluate cond) (execute body))
    [:block stmts] (execute-block stmts)
    [:var {:token [:ident name]} init] (let [val (and init (evaluate init))]
                                         (declare-var name)
                                         (when init (set-var name val)))
    [ty] (errorf "Unknown statement type %s" ty)
    (errorf "Invalid statement %q" stmt)))

(defn interpret [stmts]
  (setdyn :locals @{})
  # TODO error handling
  (each stmt stmts (execute stmt)))
