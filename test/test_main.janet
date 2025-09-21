(use judge)
(import ../lox/main)

(defn- process [& args]
  (with-dyns [] (main/process ;args)))

(test-stdout (process "print 2 * (1 + 2);") `
  6
`)
(test-stdout (process "if (true) print 1; else print 2;") `
  1
`)
(test-stdout (process "if (false) print 1; else print 2;") `
  2
`)

(test-stdout (process "var three = 1 + 2; print three;") `
  3
`)
(test-stdout (process "var three; three = 1 + 2; print three;") `
  3
`)
(test-stdout (process "var none = nil; print none;") `
  nil
`)
(test-stdout (process `
  var n = 1 + 2;
  {
    print n;
    n = n * 10;
    var n = -1;
    n = n * 10;
    print n;
  }
  n = n * 10;
  print n;
  `) `
  3
  -10
  300
`)
(test-stdout (process "fun one() { return 1; } print one();") `
  1
`)
(test-stdout (process `
  var y = 5;
  fun add(x) { return x + y; }
  print add(1);
  print add(2);
  y = 50;
  print add(2);
  fun add(x) { return x + 100; }
  print add(2);
`) `
  6
  7
  52
  102
`)
(test-stdout (process `
  var y = 5;
  var z = 10;
  fun add(x, y) {
    print x + y + z;
    var z = -1;
    print x + y + z;
  }
  add(1, 1);
  add(1, 1);
  print y;
`) `
  12
  1
  12
  1
  5
`)
(test-stdout (process `
  fun p() {
    print 1;
    return;
    print 2;
  }
  p();
`) `
  1
`)
(test-stdout (process `
  var a = "global";
  {
    fun showA() {
      print a;
    }

    showA();
    var a = "block";
    showA();
  }
  print a;
`) `
  global
  global
  global
`)

(test-error (process `
  fun out() {
    print x;
  }
  var x = 5;
  out();
`) "Undefined variable 'x'.")
(test-error (process "print x;") "Undefined variable 'x'.")
(test-error (process "none = nil;") "Undefined variable 'none'.")
(test-error (process "print none;") "Undefined variable 'none'.")
(test-error (process "add(1);") "Undefined variable 'add'.")
(test-error (process "fun one() { return 1; } print one(1);") "Expected 0 arguments but got 1.")
(test-error (process "fun add(x) { return x + 1; } print add();") "Expected 1 arguments but got 0.")
(test-error (process "fun add(x) { return x + 1; } print add(1, 2);") "Expected 1 arguments but got 2.")
(test-error (process "var x = 1; x();") "Can only call functions and classes.")
