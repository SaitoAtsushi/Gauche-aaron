;;;
;;; Test aaron
;;;

(use gauche.test)

(test-start "aaron")
(use aaron.ast-node)
(use aaron.flexible-vector)
(use aaron.parser)
(use aaron.vm)

(test-module 'aaron.ast-node)
(test-module 'aaron.flexible-vector)
(test-module 'aaron.parser)
(test-module 'aaron.vm)

(let1 machine (make-machine)
  (test* "factorial" 120
         (run machine (call-with-input-file "testcase1.asm" parse-aaron))))

(let1 machine (make-machine)
  (test* "sum of squares" 55
         (run machine (call-with-input-file "testcase2.asm" parse-aaron))))

(test-end :exit-on-failure #t)
