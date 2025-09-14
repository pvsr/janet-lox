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

(defn evaluate [expr]
  (match expr
    [:literal value] value
    [:grouping expr] (evaluate expr)
    [:unary op right] (unary-op op (evaluate right))
    [:binary left op right] (bin-op (evaluate left) op (evaluate right))
    [:logical left op right] (case ((op :token) 0)
                               :or (if-let [left (evaluate left)] left (evaluate right))
                               :and (if-let [left (evaluate left)] (evaluate right) left))
    (errorf "Unknown expression type %q" (expr 0))))

(var execute nil)

(defn- execute-block [stmts]
  (each stmt stmts (execute stmt)))

(varfn execute [stmt]
  (match stmt
    [:print expr] (printf "%q" (evaluate expr))
    [:expr expr] (xprintf (dyn :expr-out stderr) "%Q" (evaluate expr))
    # [:return word value] (throw return)
    [:if cond then else] (do
                           (cond
                             (evaluate cond) (execute then)
                             (not (nil? else)) (execute else)))
    [:while cond body] (while (evaluate cond) (execute body))
    [:block stmts] (execute-block stmts)
    (errorf "Unknown statement type %q" (stmt 0))))

(defn interpret [stmts]
  # TODO error handling
  (each stmt stmts (try (execute stmt)
                     ([e] (eprint e)))))
