;;;
;;; Test gauche_text_japan_number
;;;

(use gauche.test)
(use compat.chibi-test)

(test-start "l10n.ja.kansuji")

;; TODO old one
(use l10n.ja.number)
(test-module 'l10n.ja.number)

(use l10n.ja.kansuji)
(test-module 'l10n.ja.kansuji)

(define (inverse=? n)
  (let1 text (construct-japanese-number-string n)
    (test* #"~|text|" n (parse-japanese-number-string text))
    ))


(chibi-test
 (test-group
  "parse 漢数字"
  (test 0 (parse-japanese-number-string "零"))
  (test 1 (parse-japanese-number-string "一"))
  (test 2 (parse-japanese-number-string "弍"))
  (test 5 (parse-japanese-number-string "五"))
  (test 10 (parse-japanese-number-string "十"))
  (test 20 (parse-japanese-number-string "二十"))
  (test 100 (parse-japanese-number-string "百"))
  (test 500 (parse-japanese-number-string "五百"))
  (test 1000 (parse-japanese-number-string "千"))
  (test 1000 (parse-japanese-number-string "一千"))
  (test 1003 (parse-japanese-number-string "一千三"))
  (test 8003 (parse-japanese-number-string "八千三"))
  (test 10000000 (parse-japanese-number-string "一千万"))
  (test 1234 (parse-japanese-number-string "千二百三十四"))
  (test 5000 (parse-japanese-number-string "五千"))
  (test 58000 (parse-japanese-number-string "五万八千"))
  (test 71256543 (parse-japanese-number-string "七千百二十五万六千五百四十三"))
  (test 765200000000000000000000000000000000000000000000000000000000000000050032
        (parse-japanese-number-string "七千六百五十二無量大数五万三十二"))
  (test 372/1000 (parse-japanese-number-string "三分七厘二毛"))

  (test-error (parse-japanese-number-string "五万三十二千無量大数"))
  (test-error (parse-japanese-number-string "七厘三分"))
  (test-error (parse-japanese-number-string "八万七千八億"))
  (test-error (parse-japanese-number-string "八万五万"))
  (test-error (parse-japanese-number-string "五万八万"))
  (test-error (parse-japanese-number-string "八万五億"))

  ;; TODO should be error? currently just return 0
  ;; (test-error (parse-japanese-number-string "零割五分"))
  )

 (test-group
  "construction 漢数字"
  (test "零" (construct-japanese-number-string 0))

  (test "一千二百三十四" (construct-japanese-number-string 1234))
  (test "八千七百六十五" (construct-japanese-number-string 8765))
  (test "一億二千三百四十五万六千七百八十九" (construct-japanese-number-string 123456789))
  (test "一千二百三十四万五千六百七十八" (construct-japanese-number-string 12345678))
  (test "一億一千百十一万一千百十一" (construct-japanese-number-string 111111111))
  (test "八千百三十無量大数二百三十八不可思議三千四百八十七那由他一千八百三十八阿僧祇三千八百三十八恒河沙二千九百十三極三百四載三千四百五十九正四千三百九十四澗三千九百八溝三百九十穣四千八百二十𥝱三千四百九十八垓二千九十四京八千二百九十兆三千四百三十三億四千九百一万三千百八十四" (construct-japanese-number-string 813002383487183838382913030434594394390803904820349820948290343349013184))
  )

 (test-group
  "Inverse 漢数字"
  (inverse=? 0)
  (inverse=? 1)
  (inverse=? 12345678901230)
  (inverse=? 1234567890123)
  (inverse=? 876543210)
  (inverse=? 87654321054321)
  )

 ;; TODO
 ;; - overflow test
 ;; - invalid input test

 )

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
