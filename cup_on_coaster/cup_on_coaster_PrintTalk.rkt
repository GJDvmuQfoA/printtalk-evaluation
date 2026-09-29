(shape: coaster (dia h)
 (script: (cylinder #:diameter dia #:height h))
 (constraints: (assert: (= h 3))))

(shape: cup (dia h vol inner-dia inner-h)
 (script:
  (cylinder #:diameter dia #:height h)
  (cut: (cylinder #:diameter inner-dia #:height inner-h
                  #:z (/ (- h inner-h) 2))))
 (constraints:
  (assert: (= inner-dia (- dia 4)))
  (assert: (= inner-h (- h 2)))
  (assert: (= vol (* (/ inner-dia 2) (/ inner-dia 2) pi inner-h)))))

(shape: cup-on-coaster (h vol)
 (script:
  (named: cp (cup #:h h #:vol vol))
  (named: cr (coaster)))
 (constraints:
  (assert: (= cr.dia (+ cp.dia 20)))
  (assert: (= (+ cr.z (/ cr.h 2)) (- cp.z (/ cp.h 2))))))

(print: (cup-on-coaster #:h 70 #:vol 200000) "cup_on_coaster.stl")   