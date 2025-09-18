(use judge)
(use ../lox/main)

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
  fun add(y) { return x + 100; }
  print add(2);
`) `
  6
  7
  52
  102
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

(test-error (process "none = nil;") "Undefined variable 'none'.")
(test-error (process "print none;") "Undefined variable 'none'.")
(test-error (process "add(1);") "Undefined variable 'add'.")
(test-error (process "fun one() { return 1; } print one(1);") "Expected 0 arguments but got 1.")
(test-error (process "fun add(x) { return x + 1; } print add();") "Expected 1 arguments but got 0.")
(test-error (process "fun add(x) { return x + 1; } print add(1, 2);") "Expected 1 arguments but got 2.")
(test-error (process "var x = 1; x();") "Can only call functions and classes.")
