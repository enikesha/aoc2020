;; sbcl --load day8.lisp --eval '(day8)' < test.txt

(defun get-input (stream)
  (loop for line = (read-line stream nil nil) while line
     collect (cons (intern (string-upcase (subseq line 0 3)) (find-package :keyword))
                   (parse-integer line :start 4))))

(defun execute (program)
  (loop with pc = 0 with acc = 0 with been
     for code = (elt program pc) then (elt program pc)
     when (find pc been) do (return (values acc :loop))
     do (push pc been)
     do (case (car code)
          (:acc (incf acc (cdr code)))
          (:jmp (incf pc (1- (cdr code)))))
     do (incf pc)
     when (>= pc (length program)) do (return (values acc :end))))

(defun day8 (&optional (stream *standard-input*))
  (print (execute (get-input stream))) (terpri))

(defun day8-2 (&optional (stream *standard-input*))
  (print
   (loop with program = (get-input stream) with map = '(:jmp :nop :nop :jmp)
      for code in program for instr = (car code)
      unless (eql instr :acc)
      do (progn
           (setf (car code) (getf map (car code)))
           (multiple-value-bind (acc type) (execute program)
             (when (eql type :end)
               (return acc)))
           (setf (car code) (getf map (car code)))))
   (terpri)))
