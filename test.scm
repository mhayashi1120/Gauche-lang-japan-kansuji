;;;
;;; Test gauche_text_japan_number
;;;

(use gauche.test)

(test-start "l10n.ja.number")
(use l10n.ja.number)
(test-module 'l10n.ja.number)

;; The following is a dummy test code.
;; Replace it for your tests.

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
