;;;
;;; This module is obsoleted.
;;;

(define-module l10n.ja.number
  (use l10n.ja.kansuji)
  (export
   (rename parse-kansuji parse-japanese-number)
   (rename parse-kansuji-string parse-japanese-number-string)
   (rename construct-kansuji construct-japanese-number)
   (rename construct-kansuji-string construct-japanese-number-string)
   (rename kansuji-start japanese-number-start)
   ))
(select-module l10n.ja.number)
