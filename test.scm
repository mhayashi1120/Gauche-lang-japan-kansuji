;;;
;;; Test gauche_text_japan_number
;;;

(use gauche.test)

(test-start "gauche_text_japan_number")
(use gauche_text_japan_number)
(test-module 'gauche_text_japan_number)

;; The following is a dummy test code.
;; Replace it for your tests.
(test* "test-gauche_text_japan_number" "gauche_text_japan_number is working"
       (test-gauche_text_japan_number))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
