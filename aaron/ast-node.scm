(define-module aaron.ast-node
  (use gauche.mop.singleton)
  (export make-immidiate
          make-register
          make-pointer
          make-program-counter
          make-save
          make-incr
          make-decr
          make-halt
          <operand>
          <immidiate> <register> <pointer> <program-counter>
          <incr> <decr> <save> <halt>
          ))

(select-module aaron.ast-node)

(define-class <operand> () ())

(define-class <immidiate> (<operand>)
  ((value :init-keyword :value)))

(define-method write-object ((i <immidiate>) out)
  (format out "#<i~a>" (ref i 'value)))

(define (make-immidiate value)
  (make <immidiate> :value value))

(define-class <register> (<operand>)
  ((index :init-keyword :index)))

(define-method write-object ((r <register>) out)
  (format out "#<r~a>" (ref r 'index)))

(define (make-register index)
  (make <register> :index index))

(define-class <pointer> (<operand>)
  ((index :init-keyword :index)))

(define-method write-object ((p <pointer>) out)
  (format out "#<p~a>" (ref p 'index)))

(define (make-pointer index)
  (make <pointer> :index index))

(define-class <program-counter> (<operand>) ())

(define-method write-object ((pc <program-counter>) out)
  (format out "#<pc>"))

(define (make-program-counter)
  (make <program-counter>))

(define-class <command> () ())

(define-class <incr> (<command>)
  ((index :init-keyword :index)
   (value :init-keyword :value)))

(define-method write-object ((c <incr>) out)
  (format out "#<incr ~a ~a>" (ref c 'index) (ref c 'value)))

(define (make-incr index value)
  (make <incr> :index index :value value))

(define-class <decr> (<command>)
  ((index :init-keyword :index)
   (address :init-keyword :address)
   (value :init-keyword :value)))

(define-method write-object ((c <decr>) out)
  (format out "#<decr ~a ~a ~a>"
          (ref c 'index)
          (ref c 'address)
          (ref c 'value)))

(define (make-decr index address value)
  (make <decr> :index index :address address :value value))

(define-class <save> (<command>)
  ((index :init-keyword :index)
   (value :init-keyword :value)))

(define-method write-object ((c <save>) out)
  (format out "#<save ~a ~a>" (ref c 'index) (ref c 'value)))

(define (make-save index value)
  (make <save> :index index :value value))

(define-class <halt> (<command>)
  ()
  :metaclass <singleton-meta>)

(define-method write-object ((c <halt>) out)
  (format out "#<halt>"))

(define (make-halt)
  (make <halt>))
