;;
;; Package Gauche-lang-japan-kansuji
;;

(define-gauche-package "Gauche-lang-japan-kansuji"
  ;;
  :version "0.5.8"

  ;; Description of the package.  The first line is used as a short
  ;; summary.
  :description "Japanese Kanji parsing / construction"

  ;; List of dependencies.
  ;; Example:
  ;;     :require (("Gauche" (>= "0.9.5"))  ; requires Gauche 0.9.5 or later
  ;;               ("Gauche-gl" "0.6"))     ; and Gauche-gl 0.6
  :require (("Gauche" (>= "0.9.11-p1")))

  ;; List of providing modules
  ;; NB: This will be recognized >= Gauche 0.9.7.
  ;; Example:
  ;;      :providing-modules (util.algorithm1 util.algorithm1.option)
  :providing-modules (lang.ja.kansuji)

  ;; List name and contact info of authors.
  ;; e.g. ("Eva Lu Ator <eval@example.com>"
  ;;       "Alyssa P. Hacker <lisper@example.com>")
  :authors ("Masahiro Hayashi <mhayashi1120@gmail.com>")

  ;; List name and contact info of package maintainers, if they differ
  ;; from authors.
  ;; e.g. ("Cy D. Fect <c@example.com>")
  :maintainers ()

  ;; List licenses
  ;; e.g. ("BSD")
  :licenses ("BSD")

  ;; Homepage URL, if any.
  :homepage "https://github.com/mhayashi1120/Gauche-lang-japan-kansuji"

  ;; Repository URL, e.g. github
  :repository "git@github.com:mhayashi1120/Gauche-lang-japan-kansuji.git"
  )
