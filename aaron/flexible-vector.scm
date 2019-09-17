
(define-module aaron.flexible-vector
  (export <flexible-vector>
          make-flexible-vector))

(select-module aaron.flexible-vector)

(define-class <flexible-vector> ()
  ((raw-vector :init-form (make-vector 10 0))))

(define (make-flexible-vector)
  (make <flexible-vector>))

(define-method ref ((fv <flexible-vector>) (index <integer>))
  (let* ((rv (slot-ref fv 'raw-vector))
         (rt-size (vector-length rv)))
    (if (or (>= index rt-size) (< index 0))
        0
        (vector-ref rv index))))

(define-method (setter ref) ((fv <flexible-vector>) (index <integer>) obj)
  (let* ((rv (slot-ref fv 'raw-vector))
         (rt-size (vector-length rv)))
    (if (< index rt-size)
        (vector-set! rv index obj)
        (let ((new-table (make-vector (* index 2))))
          (vector-copy! new-table 0 rv)
          (vector-fill! new-table 0 rt-size (* index 2))
          (vector-set! new-table index obj)
          (set! (slot-ref fv 'raw-vector) new-table)))))

(define-method write-object ((obj <flexible-vector>) (port <port>))
  (write (slot-ref obj 'raw-vector) port))
