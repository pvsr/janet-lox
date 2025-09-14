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
