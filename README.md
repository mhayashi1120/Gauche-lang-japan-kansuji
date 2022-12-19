# Gauche-lang-japan-kansuji

数値と日本語圏の漢数字表記を相互変換します。

- 0 <=> "零"
- 71256543 <=> "七千百二十五万六千五百四十三"
- 1234000034560000 <=> "1,234 兆 3,456 万"
- 123456 <=> "12 万 3,456"

# API

## construct-kansuji / construct-kansuji-string

文化庁の推奨する表記方法にするときは `:type` keyword に `arabic` symbol を渡すこと。

1,234 万
1,234 億

## parse-kansuji / parse-kansuji-string

文字や port の先頭から漢数字を読み取って <number> を返却する。厳格に parse したいときは optional な CONT 引数を使う必要がある。

# 基本的なルール

- O 百万 X 一百万
- O 百   X 一百
- O 千 O 一千
- X 万 O 一万
- X 億 O 一億
- O 百兆二十億 X 二十億百兆
- 現代の生活で 42.195 などを漢数字で表すことはない。(はずだよね？)
- O 三分二厘 X 一万三分
- 後続に単位がつく場合がある。(e.g. 百兆円) 非対応文字にあたってもエラーにしないでそこで返却する。
- たぶん具体例はないと思うけど、後続単位が意図せずに漢数字の単位と一致してしまった場合はどうしようもない。処理不可能。
- "万" "億" といった 10^(4*n) の単位を BLOCK と呼称する。
- 万未満の数字パーツを SINGLE と呼称する。

## 小数について

ref: https://ja.wikipedia.org/wiki/%E5%88%86_(%E6%95%B0)#%E7%99%BE%E5%88%86%E3%81%AE%E4%B8%80%E3%82%92%E6%84%8F%E5%91%B3%E3%81%99%E3%82%8B%E3%81%A8%E3%81%AE%E8%AA%A4%E8%A7%A3
ref: https://kanjibunka.com/kanji-faq/history/q0057/

> ただ、気を付けていただきたいのは、この表にはおなじみの「割」が抜けている点です。
> ややこしいのですが、この表は、実際の数字を表す場合の表で、割合を表すときには、
> 10分の１に「割」が割って入って、後は１桁ずつ繰り下がるそうです。

ref: https://ja.wikipedia.org/wiki/%E5%88%86_(%E6%95%B0)#.E3.81.9D.E3.81.AE.E4.BB.96.E3.81.AE.E8.A1.A8.E7.8F.BE.E3.83.BB.E4.BD.BF.E7.94.A8

> 「七分咲き」、「五分五分」、「九分九厘」、「腹八分（腹八分目）」、「盗人にも三分の理」、「七分袖」

## Note:

ref: https://ja.wikipedia.org/wiki/%E5%91%BD%E6%95%B0%E6%B3%95
ref: https://www.benricho.org/kanji/kansuji.html

文化庁による数字表記のガイドライン

ref: https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/kokugo_kadai/iinkai_32/pdf/91942601_02.pdf

> Ⅱ－４ 数字の使い方 > 兆・億・万の単位は漢字を使う
