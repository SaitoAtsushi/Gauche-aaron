#!/usr/bin/env gosh

(use util.match)
(use aaron.parser)
(use aaron.ast-node)
(use aaron.vm)

(define (usage)
  (display "Usage: aaron-asm file\n")
  (exit))

(define (main args)
  (let1 argc (length args)
    (when (< 2 argc) (error "too many command line arguments"))
    (when (= 1 argc) (usage))
    (guard (e ((<aaron-parse-error> e)
               (display (~ e 'message) (standard-error-port))))
      (let ((filename (list-ref args 1))
            (machine (make-machine)))
        (write
         (run machine 
              (call-with-input-file filename parse-aaron)))))))
