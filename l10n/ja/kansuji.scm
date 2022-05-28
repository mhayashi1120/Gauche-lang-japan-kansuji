(define-module l10n.ja.kansuji
  (use util.match)
  (use parser.peg)
  (export
   parse-kansuji parse-kansuji-string
   construct-kansuji construct-kansuji-string
   kansuji-start
   ))
(select-module l10n.ja.kansuji)

;;;
;;; Basics
;;;

;; # 基本的なルール
;; - O 百万 X 一百万
;; - O 百   X 一百
;; - O 千 O 一千
;; - X 万 O 一万
;; - X 億 O 一億
;; - O 百兆二十億 X 二十億百兆
;; - 現代の生活で 42.195 などを漢数字で表すことはない、はずだよね？
;; - O 三分二厘 X 一万三分
;; - 後続に単位がつく場合がある。(e.g. 百兆円) 非対応文字にあたってもエラーしないでそこで返却する。
;; - 後続単位が意図せずに漢数字の単位と一致してしまった場合はどうしようもない。処理不可能。 (-> TODO 例示)
;; - "万" "億" といった 10^(4*n) の単位を BLOCK とする。
;; - 万未満の数字パーツを SINGLE とする。

;; ## 小数について
;;
;; ref: https://ja.wikipedia.org/wiki/%E5%88%86_(%E6%95%B0)#%E7%99%BE%E5%88%86%E3%81%AE%E4%B8%80%E3%82%92%E6%84%8F%E5%91%B3%E3%81%99%E3%82%8B%E3%81%A8%E3%81%AE%E8%AA%A4%E8%A7%A3
;; ref: https://kanjibunka.com/kanji-faq/history/q0057/
;;
;; > ただ、気を付けていただきたいのは、この表にはおなじみの「割」が抜けている点です。
;; > ややこしいのですが、この表は、実際の数字を表す場合の表で、割合を表すときには、
;; > 10分の１に「割」が割って入って、後は１桁ずつ繰り下がるそうです。
;;
;; ref: https://ja.wikipedia.org/wiki/%E5%88%86_(%E6%95%B0)#.E3.81.9D.E3.81.AE.E4.BB.96.E3.81.AE.E8.A1.A8.E7.8F.BE.E3.83.BB.E4.BD.BF.E7.94.A8
;;
;; > 「七分咲き」、「五分五分」、「九分九厘」、「腹八分（腹八分目）」、「盗人にも三分の理」、「七分袖」
;;
;; ほんとだ…
;; -> つまり… **「割」** に後続する場合のみ 1/100 にする、とか。打率の低い (1 割未満) バッターとかは…？ 零割五分、とか？

;; ## Note:
;; ref: https://ja.wikipedia.org/wiki/%E5%91%BD%E6%95%B0%E6%B3%95
;; ref: https://www.benricho.org/kanji/kansuji.html

;; # TODO
;; - 漢数字の負値について
;; - flonum について 有理数だけにする？小数点以下の値について知識が足りないので後まわし。
;; - "割" について。零割五分などの扱い。

;;;
;;; # Parser
;;;

;; ## Syntax
;;
;; JNUMBER := JNUMBER0 | JNUMBER-SINGULAR | JNUMBER-PLURAL
;; JNUMBER0 := 漢数字(0)
;; JNUMBER-SINGULAR := 漢数字(1)
;; JNUMBER-POSITIVE := 漢数字(1-9)
;; JNUMBER-PLURAL := 漢数字(2-9)

;; LESS-SINGLE$ := $LESS-SINGLE(previous-unit) (less than previous-unit)

;; SINGLE4-UNIT1 := 千
;; SINGLE4-UNIT := SINGLE4-STANDALONE-UNIT
;; SINGLE4-STANDALONE-UNIT := 千 | 十 | 百
;; SINGLE4 := JNUMBER-PLURAL SINGLE4-UNIT | JNUMBER-SINGULAR SINGLE4-UNIT1 | \
;;         SINGLE4-STANDALONE-UNIT | JNUMBER-POSITIVE
;; SINGLE := SINGLE4 ( LESS-SINGLE$ )*

;; LESS-BLOCK$ := $LESS-BLOCK(previous-unit) (less than previous-unit)

;; BLOCK4-UNIT := 万 | 億 | (10^4*n)...
;; BLOCK4 := SINGLE BLOCK4-UNIT | SINGLE
;; BLOCK := BLOCK4 ( LESS-BLOCK$ )*

;; LESS-FRACTION$ := $LESS-FRACTION(previous-unit) (less than previous-unit)

;; FRACTION-UNIT := 分 | 厘 | 10^(-1*n)...
;; FRACTION-PART := JNUMBER FRACTION-UNIT
;; FRACTION := FRACTION-PART ( LESS-FRACTION$ )*

;; 漢数字 := FRACTION | BLOCK | JNUMBER0

;; ## Definitions

(define $s $string)
(define ($try-or . ps)
  (apply $or (map $try ps)))

;; ## NOTE:
;; `singular`: 要するに 1

;; (VALUE PROPERTIES SYMBOLS)
(define-constant *basics*
  '(
    (0 (number zero) ("零"))
    (1 (number positive singular) ("一" "壱" "壹" "壹" "弌"))
    (2 (number positive plural) ("二" "弐" "貳" "貮" "弍"))
    (3 (number positive plural) ("三" "参" "參" "參" "弎"))
    (4 (number positive plural) ("四" "肆" "亖"))
    (5 (number positive plural) ("五" "伍"))
    (6 (number positive plural) ("六" "陸"))
    (7 (number positive plural) ("七" "漆" "柒" "質"))
    (8 (number positive plural) ("八" "捌"))
    (9 (number positive plural) ("九" "玖"))
    ))

(define ($basic/property prop)
  (apply $or
         (filter-map
          (match-lambda
           [(value properties symbols)
            (cond
             [(not (memq prop properties)) #f]
             [else
              ($let ([_ ($one-of symbols)])
                ($return value))])])
          *basics*)
         ))

(define-constant %jnumber ($basic/property 'number))
(define-constant %jnumber0 ($basic/property 'zero))
(define-constant %jnumber-singular ($basic/property 'singular))
(define-constant %jnumber-positive ($basic/property 'positive))
(define-constant %jnumber-plural ($basic/property 'plural))

;; ## NOTE:
;; `standalone`: 単一文字だけで数を示す
;; `allow-singular`: "一" の前置を許可する。(NG: "一百" OK: "一千")

;; (UNIT PROPERTIES SYMBOLS)
(define-constant *units*
  `(
    (,(expt 10 -21) (fraction) ("清浄"))
    (,(expt 10 -20) (fraction) ("虚空"))
    (,(expt 10 -19) (fraction) ("六徳"))
    (,(expt 10 -18) (fraction) ("刹那"))
    (,(expt 10 -17) (fraction) ("弾指"))
    (,(expt 10 -16) (fraction) ("瞬息"))
    (,(expt 10 -15) (fraction) ("須臾"))
    (,(expt 10 -14) (fraction) ("逡巡"))
    (,(expt 10 -13) (fraction) ("模糊"))
    (,(expt 10 -12) (fraction) ("漠"))
    (,(expt 10 -11) (fraction) ("渺"))
    (,(expt 10 -10) (fraction) ("埃"))
    (,(expt 10 -9)  (fraction) ("塵"))
    (,(expt 10 -8)  (fraction) ("沙"))
    (,(expt 10 -7)  (fraction) ("繊"))
    (,(expt 10 -6)  (fraction) ("微"))
    (,(expt 10 -5)  (fraction) ("忽"))
    (,(expt 10 -4)  (fraction) ("糸" "絲"))
    (,(expt 10 -3)  (fraction) ("毛" "毫"))
    (,(expt 10 -2)  (fraction) ("厘" "釐"))
    (,(expt 10 -1)  (fraction) ("分"))
    (,(expt 10 1)   (single4 standalone) ("十" "拾" "拾"))
    (,(expt 10 2)   (single4 standalone) ("百"))
    (,(expt 10 3)   (single4 standalone allow-singular) ("千"))
    (,(expt 10 4)   (block4) ("万" "萬"))
    (,(expt 10 8)   (block4) ("億"))
    (,(expt 10 12)  (block4) ("兆"))
    (,(expt 10 16)  (block4) ("京"))
    (,(expt 10 20)  (block4) ("垓"))
    (,(expt 10 24)  (block4) ("𥝱"))
    (,(expt 10 28)  (block4) ("穣"))
    (,(expt 10 32)  (block4) ("溝"))
    (,(expt 10 36)  (block4) ("澗"))
    (,(expt 10 40)  (block4) ("正"))
    (,(expt 10 44)  (block4) ("載"))
    (,(expt 10 48)  (block4) ("極"))
    (,(expt 10 52)  (block4) ("恒河沙"))
    (,(expt 10 56)  (block4) ("阿僧祇"))
    (,(expt 10 60)  (block4) ("那由他"))
    (,(expt 10 64)  (block4) ("不可思議"))
    (,(expt 10 68)  (block4) ("無量大数"))
    ))

(define ($units/property prop)
  (apply $or
         (filter-map
          (match-lambda
           [(unit properties symbols)
            (cond
             [(not (memq prop properties)) #f]
             [else
              ($let ([_ ($one-of symbols)])
                ($return unit))])])
          *units*)))

(define ($less-single su)
  ($let* ([n&u %single4]
          [ns ($optional ($less-single (cdr n&u)) 0)])
    (let1 r (+ (car n&u) ns)
      (if (< (cdr n&u) su)
        ($return r)
        ($raise (format "Not a valid order of single block ~a ~a"
                        su n&u))))))

(define-constant %single4-unit ($units/property 'single4))
(define-constant %single4-unit1 ($units/property 'allow-singular))
(define-constant %single4-standalone-unit ($units/property 'standalone))
(define-constant %single4
  ($try-or
   ($let ([n %jnumber-plural]
          [u %single4-unit])
     ($return (cons (* n u) u)))
   ($let ([_ %jnumber-singular]
          [u %single4-unit1])
     ($return (cons u u)))
   ($let ([u %single4-standalone-unit])
     ($return (cons u u)))
   ($let ([n %jnumber-positive])
     ($return (cons n 1)))
   ))
(define-constant %single ($less-single (expt 10 4)))

(define ($less-block bu)
  ($let* ([n&u %block4]
          [ns ($optional ($less-block (cdr n&u)) 0)])
    (let1 r (+ (car n&u) ns)
      (if (< (cdr n&u) bu)
        ($return r)
        ($raise (format "Not a valid order of block ~a ~a"
                        bu n&u))))))

(define-constant %block4-unit ($units/property 'block4))
(define-constant %block4
  ($try-or
   ($let ([n %single]
          [u %block4-unit])
     ($return (cons (* n u) u)))
   ($let ([n %single])
     ($return (cons n 1)))))
(define-constant %block ($less-block +inf.0))

(define-constant %fraction-unit ($units/property 'fraction))
(define-constant %fraction-part
  ($let ([n %jnumber]
         [u %fraction-unit])
    ($return (cons (* n u) u))))

(define ($less-fraction fu)
  ($let* ([n&u %fraction-part]
          [ns ($optional ($less-fraction (cdr n&u)) 0)])
    (let1 r (+ (car n&u) ns)
      (if (< (cdr n&u) fu)
        ($return r)
        ($raise (format "Not a valid order of fraction block ~a ~a"
                        fu n&u))))))

(define-constant %fraction ($less-fraction 1))

;; あえて日本語 Symbol を使う。
(define-constant %漢数字
  ($try-or
   %fraction
   %block
   %jnumber0))

;;;
;;; Build
;;;

(define-constant *fixnum-block-units*
  (cons
   (list 1 () "")
   (filter-map
    (match-lambda
     [(unit properties (symbol . _))
      (cond
       [(not (memq 'block4 properties)) #f]
       [else
        (list unit properties symbol)])])
    *units*)))

(define-constant *fixnum-single-units*
  (cons
   (list 1 '(allow-singular) "")
   (filter-map
    (match-lambda
     [(unit properties (symbol . _))
      (cond
       [(not (memq 'single4 properties)) #f]
       [else
        (list unit properties symbol)])])
    *units*)))

(define-constant *fixnum-number-definitions*
  (list->vector
   (map
    (match-lambda
     [(value properties (symbol . _))
      symbol])
    *basics*)))

;; TODO
(define (construct-flonum-block n)
  (error "not yet supported"))

;; 0 <  n < 10000
(define (construct-single N)
  (let1 *num* *fixnum-number-definitions*
    (let loop ([defs *fixnum-single-units*]
               [n N]
               [res '()])
      (cond
       [(or (= n 0)
            (null? defs))
        (string-join res "")]
       [else
        (match-let1 (_ props symbol) (car defs)
          (receive (d1 r1) (div-and-mod n 10)
            (cond
             [(= r1 0)
              (loop (cdr defs) d1 res)]
             [(= r1 1)
              (loop
               (cdr defs) d1
               (cons (format "~a~a"
                             (if (memq 'allow-singular props)
                               (vector-ref *num* r1)
                               "")
                             symbol) res))]
             [else
              (loop
               (cdr defs) d1
               (cons (format "~a~a"
                             (vector-ref *num* r1)
                             symbol) res))])))]))))

;; 0 <= N
(define (construct-fixnum-block N)
  (cond
   [(zero? N)
    (vector-ref *fixnum-number-definitions* 0)]
   [else
    (let loop ([n N]
               [defs *fixnum-block-units*]
               [res '()])
      (cond
       [(or (null? defs)
            (zero? n))

        (when (and (null? defs)
                   (not (zero? n)))
          (error "Unable to convert to Kanji" N))

        (string-join res "")]
       [else
        (match-let1 ((_ props symbol) . rest-def) defs
          (receive (n1 r1) (div-and-mod n 10000)
            (cond
             [(= r1 0)
              (loop n1 rest-def res)]
             [else
              (let ([single (format "~a~a" (construct-single r1) symbol)])
                (loop n1 rest-def (cons single res)))])))]))]))

;; 大きな string から漢数字を抽出しやすくするため words を取り出す。
;; 単語のうち文字シーケンスの最初に現われる単語のみ。
;; 例えば "億" は現状の仕様では妥当な漢数字の先頭にくることはない。
(define-constant japanese-number-start-words
  (append
   (append-map
    (match-lambda
     [(_ _ symbols . _)
      symbols])
    *basics*)
   (append-map
    (match-lambda
     [(_ props symbols)
      (if (memq 'standalone props)
        symbols
        '())])
    *units*)))

(define-constant kansuji-start
  ($ regexp-compile
     $ regexp-parse
     $ (cut string-join <> "|")
     $ map regexp-quote japanese-number-start-words))

;;;
;;; API
;;;

;; N: number
(define (construct-kansuji n :optional (oport (current-output-port)))
  (display (construct-kansuji-string n) oport))

(define (construct-kansuji-string n)
  (cond
   [(integer? n)
    (construct-fixnum-block n)]
   [(flonum? n)
    ;; TODO make error when 42.195 like number.
    (construct-flonum-block n)]
   [else
    (error "Not a supported value" n)]))

;; TODO think again default return value. string construction maybe too heavy cost.
(define (japanese-number-result/string n rest)
  (values n (rope->string rest)))

(define (japanese-number-result/port . args)
  (receive (n s) (apply japanese-number-result/string args)
    (values n (open-input-string s))))

;; japanese text might have another unit with no separator. (e.g. 百兆円)
;; CONT: Default CONT Parse IPORT and return number and rest input as a new port.
(define (parse-kansuji :optional (iport (current-input-port))
                               (cont japanese-number-result/string))
  (peg-parse-port %漢数字 iport cont))

;; S: string
;; CONT: Default CONT Parse IPORT and return number and rest as a string.
(define (parse-kansuji-string s :optional (cont japanese-number-result/string))
  (call-with-input-string s (cut parse-kansuji <> cont)))


