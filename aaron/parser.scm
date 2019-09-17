
(define-module aaron.parser
  (use parser.peg)
  (use util.match)
  (use gauche.sequence)
  (use aaron.ast-node)
  (export parse-aaron
          parse-aaron-string
          <aaron-parse-error>))

(select-module aaron.parser)

(define-condition-type <aaron-parse-error> <error> #f
  (position)
  (objects))

(define identifier
  ($lift (compose string->symbol rope->string)
         ($->rope ($one-of #[a-zA-Z]) ($many ($one-of #[a-zA-Z0-9])))))

(define space
  ($one-of #[ \t]))

(define separator
  ($seq ($many space) ($char #\,) ($many space)))

(define comment
  ($seq ($many space)
        ($optional ($try ($seq ($char #\;) ($many ($one-of #[^\x0a;])))))
        ($char #\newline)))

(define number
  ($lift string->number
         ($->string
          ($or
           ($try
            ($->rope
             ($try ($optional ($char #\-)))
             ($one-of #[1-9])
             ($many ($one-of #[0-9]))))
           ($char #\0)))))

(define index
  ($or ($try ($lift make-register number))
       ($lift make-pointer
              ($between ($seq ($char #\[) ($many space))
                        number
                        ($seq ($many space) ($char #\]))))))

(define value
  ($or
   ($try
    ($lift make-pointer
           ($between ($seq ($string "[[") ($many space))
                     number
                     ($seq ($many space) ($string "]]")))))
   ($try ($lift make-immidiate number))
   ($try
    ($lift make-register
           ($between ($seq ($char #\[) ($many space))
                     number
                     ($seq ($many space) ($char #\])))))
   ($seq
    ($do (i identifier)
         (if (eq? i 'pc)
             ($return (make-program-counter))
             ($fail "unable to appear identifier other than pc as value"))))))

(define address
  ($or 
   ($try ($lift make-immidiate number))
   ($try ($lift make-register
                ($between ($seq ($char #\[) ($many space))
                          number
                          ($seq ($many space) ($char #\])))))
   ($do (i identifier)
        ($return
         (if (eq? i 'pc)
             (make-program-counter)
             i)))))

(define incr_command
  ($do
   (($string "incr"))
   (($many1 space))
   (i index)
   (v ($optional ($try ($seq separator value)) (make-immidiate 1)))
   ($return (list 'incr i v))))

(define decr_command
  ($do
   (($string "decr"))
   (($many1 space))
   (i index)
   separator
   (a address)
   (v ($optional ($try ($seq separator value)) (make-immidiate 1)))
   ($return (list 'decr i a v))))

(define save_command
  ($do
   (($string "save"))
   (($many1 space))
   (i index)
   separator
   (v value)
   ($return (list 'save i v))))

(define halt_command
  ($seq
   ($string "halt")
   ($return (list 'halt))))

(define command
  ($or
   ($try incr_command)
   ($try decr_command)
   ($try save_command)
   ($try halt_command)))

(define line
  ($lazy
   ($or
    ($try
     ($do (label ($try ($optional identifier #f)))
          (($many1 space))
          (c command)
          comment
          (if (eq? label 'pc)
              ($fail "unable to use `pc` as label name")
              ($return (cons label c)))))
    ($try
     ($seq comment line)))))

(define program
  ($followed-by ($many line) ($seq ($many comment) ($eos))))

(define (collect-labels st)
  (rlet1 ht (make-hash-table 'eq?)
    (for-each-with-index
     (lambda(i c)
       (when (car c)
         (when (hash-table-get ht (car c) #f)
           (error <aaron-parse-error>
                  :position #f :objects (car c)
                  :message  #"*** ERROR: duplicated label `~(car c)`"))
         (hash-table-put! ht (car c) i)))
     st)))

(define (erase-labels st)
  (let1 labels (collect-labels st)
    (map
     (lambda(c)
       (match c
         ((_ 'decr index address value)
          (if (symbol? address)
              (if-let1 n (hash-table-get labels address #f)
                (make-decr index (make-immidiate n) value)
                (error <aaron-parse-error>
                       :position #f :objects address
                       :message  #"*** ERROR: unknown label name `~|address|`"))
              (make-decr index address value)))
         ((_ 'incr index value)
          (make-incr index value))
         ((_ 'save index value)
          (make-save index value))
         ((_ 'halt)
          (make-halt))))
     st)))

(define (parse-aaron :optional (port (current-input-port)))
  (guard (e ((<parse-error> e)
             (error <aaron-parse-error>
                    :position (~ e 'position) :objects (~ e 'objects)
                    :message (~ e 'message))))
    (list->vector
     (erase-labels
      (peg-parse-port program port)))))

(define (parse-aaron-string str)
  (call-with-input-string str (cut parse-aaron <>)))
