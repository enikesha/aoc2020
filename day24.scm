;;; guile day24.scm < day24_input.txt
(use-modules (ice-9 rdelim))

(define (trav route pos)
  (if (string-null? route) pos
      (case (string-ref route 0)
        ((#\e) (trav (string-drop route 1) (+ pos 1)))
        ((#\w) (trav (string-drop route 1) (+ pos -1)))
        ((#\n) (if (eqv? #\e (string-ref route 1))
                   (trav (string-drop route 2) (+ pos 0+i))
                   (trav (string-drop route 2) (+ pos -1+i))))
        ((#\s) (if (eqv? #\e (string-ref route 1))
                   (trav (string-drop route 2) (+ pos 1-i))
                   (trav (string-drop route 2) (+ pos 0-i)))))))

(define (flip tiles)
  (let ((route (read-line)))
    (if (eof-object? route) tiles
        (let ((pos (trav route 0)))
          (hashv-set! tiles pos (not (hashv-ref tiles pos)))
          (flip tiles)))))

(define (black-count tiles)
  (hash-fold (lambda (k v p) (if v (1+ p) p)) 0 tiles))

(define tiles (flip (make-hash-table)))

(display (black-count tiles))
(newline)

(define (black-neighs tiles pos)
  (+ (if (hashv-ref tiles (+ pos 1)) 1 0)
     (if (hashv-ref tiles (+ pos -1)) 1 0)
     (if (hashv-ref tiles (+ pos 0+i)) 1 0)
     (if (hashv-ref tiles (+ pos -1+i)) 1 0)
     (if (hashv-ref tiles (+ pos 1-i)) 1 0)
     (if (hashv-ref tiles (+ pos 0-i)) 1 0)))

(define (tile-day! pos old new)
  (let ((black (black-neighs old pos))
        (tile (hashv-ref old pos)))
    (hashv-set! new pos
                (if tile
                    (or (eqv? black 1) (eqv? black 2))
                    (eqv? black 2)))))

(define (day tiles next)
  (hash-for-each
   (lambda (pos state)
     (tile-day! pos tiles next)
     (tile-day! (+ pos 1) tiles next)
     (tile-day! (+ pos -1) tiles next)
     (tile-day! (+ pos 0+i) tiles next)
     (tile-day! (+ pos -1+i) tiles next)
     (tile-day! (+ pos 1-i) tiles next)
     (tile-day! (+ pos 0-i) tiles next))
   tiles)
  next)

(define (days tiles next count)
  (if (zero? count) tiles
      (days (day tiles next) tiles (1- count))))

(display (black-count (days tiles (make-hash-table) 100)))
(newline)
