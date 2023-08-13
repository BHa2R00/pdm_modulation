
(defun bias-error (x e)
  (let ((d (abs(* x e)))
		(r (list)))
	(do ((k 0 (+ k 1)))
	  ((> k d))
	  (push (- x k) r)
	  (push (+ x k) r)
	  )
	(setf r (remove-duplicates r :test 'equalp))
	r))

(defun gcd2-with-error (x y e f)
  (let ((l1 (bias-error x e))
		(l2 (bias-error y e))
		(g 1))
	(map 'list
		 (lambda (i1)
		   (map 'list
				(lambda (i2)
				  (let ((k (gcd i1 i2)))
					(if (apply f (list k g))
					  (setf g k))
					))
				l2))
		 l1)
	g))

(defun gcd-with-error (x e f)
  (let ((g nil))
	(dotimes (k (length x))
	  (dotimes (j (length x))
		(if (not(equalp j k))
		  (let*((n1 (nth k x))
				(n2 (nth j x))
				(n3 (gcd2-with-error n1 n2 e f)))
			(if (or
				  (not g)
				  (< n3 g)
				  )
			  (setf g n3))))))
	g))

(format t "NEC protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	9000 ;nec lead length
	4500 ;nec lead distance
	560 ;nec bit0
	1690 ;nec bit1
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "Toshiba protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	4500 ;tc9012 lead length
	4500 ;tc9012 lead distance
	560 ;tc9012 bit0
	1690 ;tc9012 bit1
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "JVC protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	8400 ;jvc lead length
	4200 ;jvc lead distance
	526 ;nec bit
	1570 ;nec bit1
	524 ;nec bit0
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "RC5 protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	889 ;rc5 phase 0
	889 ;rc5 phase 1
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "RC6 protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	2600 ;rc6 lead length
	889 ;rc6 lead distance
	444 ;rc6 phase 0
	444 ;rc6 phase 1
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "SONY protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	2400 ;sony lead length
	600 ;sony lead distance
	1200 ;sony bit length
	600 ;sony bit distance
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "RC-MM protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	417 ;rc-mm lead length
	278 ;rc-mm lead distance
	167 ;rc-mm bit length
	28 ;rc-mm cycle bit distance
	) 
  0.05 ;max error 5%
  '>
  ))

(format t "RCA protocol bck period = ~s us~%" 
(gcd-with-error 
  '(
	4000 ;rca lead length
	4000 ;rca lead distance
	500 ;rca bit length
	2000 ;rca bit1 distance
	1000 ;rca bit0 distance
	) 
  0.05 ;max error 5%
  '>
  ))
