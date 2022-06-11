;;;
;;; Test gauche_text_japan_number
;;;

(use gauche.test)
(use compat.chibi-test)

(test-start "lang.ja.kansuji")

(use lang.ja.kansuji)
(test-module 'lang.ja.kansuji)

(define (inverse=? n)
  (let1 text (construct-kansuji-string n)
    (test* #"~|text|" n (parse-kansuji-string text))
    ))


(chibi-test
 (test-group
  "parse 漢数字"
  (test 0 (parse-kansuji-string "零"))
  (test 1 (parse-kansuji-string "一"))
  (test 2 (parse-kansuji-string "弍"))
  (test 5 (parse-kansuji-string "五"))
  (test 10 (parse-kansuji-string "十"))
  (test 20 (parse-kansuji-string "二十"))
  (test 100 (parse-kansuji-string "百"))
  (test 500 (parse-kansuji-string "五百"))
  (test 1000 (parse-kansuji-string "千"))
  (test 1000 (parse-kansuji-string "一千"))
  (test 1003 (parse-kansuji-string "一千三"))
  (test 8003 (parse-kansuji-string "八千三"))
  (test 10000000 (parse-kansuji-string "一千万"))
  (test 1234 (parse-kansuji-string "千二百三十四"))
  (test 5000 (parse-kansuji-string "五千"))
  (test 58000 (parse-kansuji-string "五万八千"))
  (test 71256543 (parse-kansuji-string "七千百二十五万六千五百四十三"))
  (test 765200000000000000000000000000000000000000000000000000000000000000050032
        (parse-kansuji-string "七千六百五十二無量大数五万三十二"))
  (test 372/1000 (parse-kansuji-string "三分七厘二毛"))

  (test-error (parse-kansuji-string "五万三十二千無量大数"))
  (test-error (parse-kansuji-string "七厘三分"))
  (test-error (parse-kansuji-string "八万七千八億"))
  (test-error (parse-kansuji-string "八万五万"))
  (test-error (parse-kansuji-string "五万八万"))
  (test-error (parse-kansuji-string "八万五億"))

  ;; TODO should be error? currently just return 0
  ;; (test-error (parse-kansuji-string "零割五分"))
  )

 (test-group
  "construction 漢数字"
  (test "零" (construct-kansuji-string 0))

  (test "一千二百三十四" (construct-kansuji-string 1234))
  (test "八千七百六十五" (construct-kansuji-string 8765))
  (test "一億二千三百四十五万六千七百八十九" (construct-kansuji-string 123456789))
  (test "一千二百三十四万五千六百七十八" (construct-kansuji-string 12345678))
  (test "一億一千百十一万一千百十一" (construct-kansuji-string 111111111))
  (test "八千百三十無量大数二百三十八不可思議三千四百八十七那由他一千八百三十八阿僧祇三千八百三十八恒河沙二千九百十三極三百四載三千四百五十九正四千三百九十四澗三千九百八溝三百九十穣四千八百二十𥝱三千四百九十八垓二千九十四京八千二百九十兆三千四百三十三億四千九百一万三千百八十四" (construct-kansuji-string 813002383487183838382913030434594394390803904820349820948290343349013184))
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

 (parse-kansuji-string "1,234")
 (test-group
  "parse Arabic 漢数字"
  (test 0 (parse-kansuji-string "0"))
  (test 5678 (parse-kansuji-string "5,678"))
  (test 1234 (parse-kansuji-string "1,234"))
  (test 12340000 (parse-kansuji-string "1,234万"))
  (test 12340000 (parse-kansuji-string "1,234 万"))
  (test 567812340321 (parse-kansuji-string "5,678 億1,234 万 321"))
  (test 567812340321 (parse-kansuji-string "5,678億1,234万321"))
  (test 567812340321 (parse-kansuji-string "5,678 億 1,234 万 321"))
  )

 (test-group
  "Construct Arabic 漢数字"
  (test "0" (construct-kansuji-string 0 :type 'arabic))
  (test "1,234" (construct-kansuji-string 1234 :type 'arabic))
  (test "1,234 万" (construct-kansuji-string 12340000 :type 'arabic))
  (test "1,234 億 3,456" (construct-kansuji-string 123400003456 :type 'arabic))
  (test "1,234 兆 3,456 万" (construct-kansuji-string 1234000034560000 :type 'arabic))
  (test "1,234 万 5,678" (construct-kansuji-string 12345678 :type 'arabic))
  (test "12 億 3,456 万 7,890" (construct-kansuji-string 1234567890 :type 'arabic))
  (test "8,765 万 4,321" (construct-kansuji-string 87654321 :type 'arabic))
  (test "765 万 4,321" (construct-kansuji-string 7654321 :type 'arabic))
  (test "65 万 4,321" (construct-kansuji-string 654321 :type 'arabic))
  (test "9 億 8,765 万 4,321" (construct-kansuji-string 987654321 :type 'arabic))
  (test "8,130 無量大数 238 不可思議 3,487 那由他 1,838 阿僧祇 3,838 恒河沙 2,913 極 304 載 3,459 正 4,394 澗 3,908 溝 390 穣 4,820 𥝱 3,498 垓 2,094 京 8,290 兆 3,433 億 4,901 万 3,184" (construct-kansuji-string 813002383487183838382913030434594394390803904820349820948290343349013184 :type 'arabic))
  )

 (test-group
  "Overflow test"
  (let1 max-value (string->number (make-string 72 #\9))
    ;; Just pass 
    (test #t (boolean (construct-kansuji-string max-value)))
    ;; overflow
    (test-error (construct-kansuji-string (+ max-value 1)))
    )
  )
 ;; TODO
 ;; - invalid input test

 )

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
