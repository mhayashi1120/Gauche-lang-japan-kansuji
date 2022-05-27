;;;
;;; Test gauche_text_japan_number
;;;

(use gauche.test)

(test-start "gauche_text_japan_number")
(use text.japan.number)
(test-module 'text.japan.number)

;; The following is a dummy test code.
;; Replace it for your tests.

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
