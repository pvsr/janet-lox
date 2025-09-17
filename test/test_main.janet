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
(test-error (process "none = nil;") "Undefined variable 'none'.")
(test-error (process "print none;") "Undefined variable 'none'.")
