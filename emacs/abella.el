;; Emacs mode for Abella theorem files.
;;
;; Based on tutorial at:
;;   http://two-wugs.net/emacs/mode-tutorial.html
;;

(defvar abella-mode-hook nil)

(add-to-list 'auto-mode-alist '("\\.thm\\'" . abella-mode))

(defun make-regex (&rest args)
  (concat "\\<" (regexp-opt args) "\\>"))

(defvar abella-font-lock-keywords
  (list
    (cons (make-regex "Define" "Theorem \\W*" "Axiom") font-lock-keyword-face)
;   (cons (make-regex "true" "false") font-lock-constant-face)
;   (cons (make-regex "forall" "exists" "nabla") font-lock-keyword-face)
;   (cons (make-regex "intros" "apply" "case" "induction" "search"
;                     "to" "on" "inst" "with" "cut" "unfold"
;                     "assert" "exists" "split" "split*" "clear")
   font-lock-keyword-face)
  "Default highlighting for Abella major mode")

(defvar abella-mode-syntax-table
  (let ((abella-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" abella-mode-syntax-table)
    (modify-syntax-entry ?' "w" abella-mode-syntax-table)
    (modify-syntax-entry ?/ "w" abella-mode-syntax-table)
    (modify-syntax-entry ?% "<" abella-mode-syntax-table)
    (modify-syntax-entry ?\n ">" abella-mode-syntax-table)
    (modify-syntax-entry ?. "." abella-mode-syntax-table)
    (modify-syntax-entry ?+ "." abella-mode-syntax-table)
    (modify-syntax-entry ?- "." abella-mode-syntax-table)
    (modify-syntax-entry ?* "." abella-mode-syntax-table)
    (modify-syntax-entry ?= "." abella-mode-syntax-table)
    (modify-syntax-entry ?> "." abella-mode-syntax-table)
    (modify-syntax-entry ?< "." abella-mode-syntax-table)
    (modify-syntax-entry ?# "." abella-mode-syntax-table)
    (modify-syntax-entry ?\ "." abella-mode-syntax-table)
    abella-mode-syntax-table)
  "Syntax table for Abella major mode")

;; Proof navigation
(defvar abella-mode-keymap
  (let ((abella-mode-keymap (make-keymap)))
    (define-key abella-mode-keymap "\C-c\C-e" 'abella-previous-command-send)
    (define-key abella-mode-keymap "\C-c\C-n" 'abella-forward-command-send)
    (define-key abella-mode-keymap "\C-c\C-p" 'abella-backward-command-send)
    abella-mode-keymap)
  "Keymap for Abella major mode")

(defun abella-forward-command ()
  (interactive)
  (search-forward-regexp "%\\|\\.")
  (if (equal (match-string 0) "%")
      (progn (beginning-of-line)
             (next-line 1)
             (abella-forward-command))))

(defun abella-backward-command ()
  (interactive)
  (backward-char 1)
  (abella-backward-command-rec)
  (forward-char 1))

(defun abella-backward-command-rec ()
  (interactive)
  (while (search-backward "%" (point-at-bol) t))
  (if (not (search-backward "." (point-at-bol) t))
      (progn (end-of-line 0)
             (abella-backward-command-rec))))

(defun abella-previous-command-send ()
  (interactive)
  (abella-backward-command)
  (abella-forward-command-send))

(defun abella-forward-command-send ()
  (interactive)
  (let ((beg (point))
        str)
    (abella-forward-command)
    (setq str (buffer-substring beg (point)))
    (other-window 1)
    (switch-to-buffer "*shell*")
    (end-of-buffer)
    (insert str)
    (comint-send-input)
    (other-window -1)))

(defun abella-backward-command-send ()
  (interactive)
  (abella-backward-command)
  (other-window 1)
  (switch-to-buffer "*shell*")
  (end-of-buffer)
  (insert "undo.")
  (comint-send-input)
  (other-window -1))

(defun abella-mode ()
  "Major mode for editing abella theorem files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table abella-mode-syntax-table)
  (use-local-map abella-mode-keymap)
  (set (make-local-variable 'font-lock-defaults)
       '(abella-font-lock-keywords))
;  (set (make-local-variable 'indent-line-function) 'abella-indent-line)
  (setq major-mode 'abella-mode)
  (setq mode-name "Abella")
  (run-hooks 'abella-mode-hook))

(provide 'abella-mode)