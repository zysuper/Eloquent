(switch-exception-check)

; DEFMACRO
(set-symbol-macro!
 'defmacro
 (lambda (var pars . body)
   `(set-symbol-macro! ',var (lambda ,pars ,@body))))

; AND2
(defmacro and2 (e1 e2)
  `(if ,e1
       ,e2
     #f))

; DEFINE
(defmacro define (name pars . body)
  (set-symbol-value! name '())
  `(begin
    (set! ,name
          (name-lambda ,name ,pars ,@body))
    (set-function-name! ,name ',name)))

; WHILE
(defmacro while (test . body)
  (let ((start (gensym))
        (end (gensym)))
    `(tagbody
      ,start
       (if ,test
           (begin
            ,@body
            (goto ,start))
         (goto ,end))
      ,end
       '())))

; Type Predicates
(define eof? (x)
  (eq? 'teof (type-name (type-of x))))

(define fixnum? (n)
  (eq? 'fixnum (type-name (type-of n))))

(define float? (n)
  (eq? 'float (type-name (type-of n))))

; List Operations
(define first (list)
  (head list))

(define null? (obj)
  (eq? obj '()))

(define rest (list)
  (tail list))

(define map (list fn)
  (if (null? list)
      '()
    (cons (fn (first list))
          (map (rest list) fn))))

(define remove (x list)
  (cond ((null? list) '())
        ((eql? x (first list))
         (remove x (rest list)))
        (else
         (cons (first list)
               (remove x (rest list))))))

(define reduce (list fn)
  (cond ((null? list)
         (signal "Parameter `list' can't be an empty list."))
        ((null? (rest list)) (first list))
        (else
         (fn (first list) (reduce (rest list) fn)))))

; Arithmetic Operations
;; +
(define bin+ (n m)
  (cond ((and2 (fixnum? n) (fixnum? m)) (fx+ n m))
        ((and2 (fixnum? n) (float? m)) (fp+ (fx->fp n) m))
        ((and2 (float? n) (fixnum? m)) (fp+ n (fx->fp m)))
        (else (fp+ n m))))

(define + ns
  (cond ((null? ns) 0)
        (else (reduce ns bin+))))

;; -
(define bin- (n m)
  (cond ((and2 (fixnum? n) (fixnum? m)) (fx- n m))
        ((and2 (fixnum? n) (float? m)) (fp- (fx->fp n) m))
        ((and2 (float? n) (fixnum? m)) (fp- n (fx->fp m)))
        (else (fp- n m))))

(define - (n . ns)
  (cond ((null? ns) (bin- 0 n))
        (else (bin- n (reduce ns bin+)))))

;; *
(define bin* (n m)
  (cond ((and2 (fixnum? n) (fixnum? m)) (fx* n m))
        ((and2 (fixnum? n) (float? m)) (fp* (fx->fp n) m))
        ((and2 (float? n) (fixnum? m)) (fp* n (fx->fp m)))
        (else (fp* n m))))

(define * ns
  (cond ((null? ns) 1)
        (else (reduce ns bin*))))

;; /
(define bin/ (n m)
  (cond ((and2 (fixnum? n) (fixnum? m)) (fx/ n m))
        ((and2 (fixnum? n) (float? m)) (fp/ (fx->fp n) m))
        ((and2 (float? n) (fixnum? m)) (fp/ n (fx->fp m)))
        (else (fp/ n m))))

(define / (n . ns)
  (cond ((null? ns) (bin/ 1 n))
        (else (bin/ n (reduce ns bin*)))))

(define < (n m)
  (cond ((> n m) #f)
        ((= n m) #f)
        (else #t)))

(define gcd (n m)
  (if (= m 0)
      n
    (gcd m (mod n m))))

; I/O
;; Output
(define print (x)
  (write-object x *standard-output*)
  (write-char #\newline *standard-output*)
  #t)

; Unix CLI Tools
;; cat
(define cat (file)
  (let ((c (read-char file)))
    (if (eof? c)
        #t
      (begin
        (write-char c *standard-output*)
        (cat file)))))

(define wc (file)
  (var aux
   (name-lambda aux (file n)
     (let ((c (read-char file)))
       (if (eof? c)
           n
         (aux file (+ n 1))))))
  (aux file 0))

; Test
(define while-macro (test . body)
  (let ((start (gensym))
        (end (gensym)))
    `(tagbody
      ,start
       (if ,test
           (begin ,@body)
         (goto ,end))
      ,end
       '())))
