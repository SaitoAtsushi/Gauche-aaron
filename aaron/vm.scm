(define-module aaron.vm
  (use aaron.flexible-vector)
  (use aaron.ast-node)
  (export run make-machine))

(select-module aaron.vm)

(define-class <machine> ()
  ((pc :init-form 0)
   (registers :init-form (make-flexible-vector))))

(define (make-machine)
  (make <machine>))

(define-method ref ((fv <flexible-vector>) (n <immidiate>))
  (slot-ref n 'value))

(define-method ref ((fv <flexible-vector>) (n <register>))
  (ref fv (slot-ref n 'index)))

(define-method (setter ref) ((fv <flexible-vector>) (n <register>) i)
  (let1 rn (slot-ref n 'index)
    (when (>= rn 0) (set! (ref fv rn) i))))

(define-method ref ((fv <flexible-vector>) (n <pointer>))
  (ref fv (ref fv (slot-ref n 'index))))

(define-method (setter ref) ((fv <flexible-vector>) (n <pointer>) i)
  (set! (ref fv (ref fv (slot-ref n 'index))) i))

(define-method ref ((m <machine>) (n <operand>))
  (ref (slot-ref m 'registers) n))

(define-method (setter ref) ((m <machine>) (n <operand>) i)
  (set! (ref (slot-ref m 'registers) n) i))

(define-method ref ((m <machine>) (n <program-counter>))
  (slot-ref m 'pc))

(define-method run ((m <machine>) (c <incr>))
  (inc! (ref (slot-ref m 'registers)
             (slot-ref c 'index))
        (ref m (slot-ref c 'value)))
  #f)

(define-method run ((m <machine>) (c <decr>))
  (let ((i (slot-ref c 'index))
        (v (slot-ref c 'value)))
    (if (>= (ref m i) (ref m v))
        (dec! (ref (slot-ref m 'registers) i)
              (ref m v))
        (set! (ref m 'pc) (ref m (ref c 'address)))))
  #f)

(define-method run ((m <machine>) (c <save>))
  (set! (ref m (ref c 'index)) (ref m (ref c 'value)))
  #f)

(define-method run ((m <machine>) (c <halt>))
  (ref (slot-ref m 'registers) 0))

(define-method run ((m <machine>) (cs <vector>))
  (do ()
      ((let1 pc (slot-ref m 'pc)
         (inc! (slot-ref m 'pc))     
         (run m (ref cs pc)))
       (ref (slot-ref m 'registers) 0))))
