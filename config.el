;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Luigi D. C. Soares"
      user-mail-address "luigidcsoares@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font
      (font-spec :family "MesloLGS NF" :weight 'light :size 14))
(setq doom-variable-pitch-font
      (font-spec :family "Iosevka Aile" :weight 'light :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-one-light)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Private Config ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Maximize screen on startup:
;; (add-to-list 'initial-frame-alist '(fullscreen . maximized))
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Wrapping lines: set fill-column as 70
(setq-default fill-column 70)

;; Define custom leaderkey binding:
;; (setq doom-leader-key ","
;;       doom-localleader-key ", l")

;; Change order of latex viewers (to use pdf-tools, yoi must
;; have :tools +pdf enabled):
(setq +latex-viewers `(pdf-tools zathura okular))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; Themes ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fonte:
;; https://emacs.stackexchange.com/questions/24088/make-a-function-to-toggle-themes

(defvar *haba-theme-dark* 'doom-one)
(defvar *haba-theme-light* 'doom-one-light)
(defvar *haba-current-theme* *haba-theme-dark*)

;; disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))

(defun haba/next-theme (theme)
  (if (eq theme 'default)
      (disable-theme *haba-current-theme*)
    (progn
      (load-theme theme t)))
  (setq *haba-current-theme* theme))

(defun haba/toggle-theme ()
  (interactive)
  (if (eq *haba-current-theme* *haba-theme-dark*)
      (haba/next-theme *haba-theme-light*)
        (haba/next-theme *haba-theme-dark*)))

(map! :leader :desc "Toggle doom theme" "tt" #'haba/toggle-theme)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Org Mode ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! org
  ;; Set latex preview tikzpicture
  (setq org-preview-latex-default-process 'dvisvgm)

  ;; Hide emphasis markers on formatted text
  (setq org-hide-emphasis-markers t)

  ;; Set latex preview scale
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.5))

  (add-hook 'org-mode-hook #'org-bullets-mode)
  (add-hook 'org-mode-hook #'org-inline-pdf-mode))

(after! ox-latex
  ;; Export code blocks with minted
  (setq org-latex-src-block-backend 'minted)
  (add-to-list 'org-latex-packages-alist '("newfloat" "minted"))

  ;; Based on the default value
  (setq org-latex-pdf-process
        '("latexmk -shell-escape -f -pdf -%latex -interaction=nonstopmode -output-directory=%o %f")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Presentation Mode ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! visual-fill-column
  (setq visual-fill-column-width 140
        visual-fill-column-center-text t))

(after! org-present
  (defun my/org-present-add-page-number ()
    ;; Add page number to each headline level 1 (skip title page)
    (let ((i 1))
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (hl)
          (when (eq (org-element-property :level hl) 1)
            (let* ((begin (+ (org-element-property :begin hl) 1))
                   ;; let end = begin
                   (overlay (make-overlay begin begin))
                   (page-number (number-to-string i)))
              (push overlay org-present-overlays-list)
              (overlay-put overlay 'after-string (concat page-number "."))
              (setq i (1+ i))))))))

  (defun my/org-present-start ()
    (my/org-present-add-page-number)
    ;; Set a blank header line string to create blank space at the top
    (setq-local header-line-format " ")

    ;; Tweak font sizes
    (setq-local face-remapping-alist
                '((default (:height 1.5) variable-pitch)
                  (header-line (:height 3.0) variable-pitch)
                  (org-document-title (:height 1.75) org-document-title)
                  (org-document-info (:height 1.5) org-document-info)
                  (org-code (:height 1.55) org-code)
                  (org-verbatim (:height 1.55) org-verbatim)
                  (org-block (:height 1.25) org-block)
                  (org-block-begin-line (:height 0.7) org-block)))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;; Customize Faces ;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Copy the default faces so we can restore them later after presentations
    (dolist (face '((org-level-1 . org-level-1-default) (org-level-2 . org-level-2-default)
                    (org-level-3 . org-level-3-default) (org-level-4 . org-level-4-default)
                    (org-level-5 . org-level-5-default) (org-level-6 . org-level-6-default)
                    (org-level-7 . org-level-7-default) (org-level-8 . org-level-8-default)))
      (copy-face (car face) (cdr face)))

    ;; Resize Org headings
    (dolist (face '((org-level-1 . 1.9) (org-level-2 . 1.8)
                    (org-level-3 . 1.75) (org-level-4 . 1.7)
                    (org-level-5 . 1.8) (org-level-6 . 1.8)
                    (org-level-7 . 1.8) (org-level-8 . 1.8)))
      (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'medium :height (cdr face)))

    ;; Make the document title a bit bigger
    (copy-face 'org-document-title 'org-document-title-default)
    (set-face-attribute 'org-document-title nil :font "Iosevka Aile" :weight 'bold :height 2.0)

    ;; Make sure certain org faces use the fixed-pitch face when variable-pitch-mode is on
    (copy-face 'org-block 'org-block-default)
    (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)

    (copy-face 'org-table 'org-table-default)
    (set-face-attribute 'org-table nil :inherit 'fixed-pitch)

    (copy-face 'org-formula 'org-formula-default)
    (set-face-attribute 'org-formula nil :inherit 'fixed-pitch)

    (copy-face 'org-code 'org-code-default)
    (set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))

    (copy-face 'org-verbatim 'org-verbatim-default)
    (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))

    (copy-face 'org-special-keyword 'org-special-keyword-default)
    (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))

    (copy-face 'org-meta-line 'org-meta-line-default)
    (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))

    (copy-face 'org-checkbox 'org-checkbox-default)
    (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

    (org-display-inline-images)
    (org-latex-preview '(64)) ; C-u C-u C-u = clear all images in the buffer
    (org-latex-preview '(16)) ; C-u C-u = display all images in the buffer

    ;; Center the presentation and wrap lines
    (visual-fill-column-mode 1)
    (visual-line-mode 1)

    ;; Disable line numbers
    (display-line-numbers-mode 0)

    (variable-pitch-mode 1))

  (defun my/org-present-quit ()
    ;; Reset font customizations
    (setq-local face-remapping-alist '((default fixed-pitch)))

    (dolist (face '((org-level-1 . org-level-1-default) (org-level-2 . org-level-2-default)
                    (org-level-3 . org-level-3-default) (org-level-4 . org-level-4-default)
                    (org-level-5 . org-level-5-default) (org-level-6 . org-level-6-default)
                    (org-level-7 . org-level-7-default) (org-level-8 . org-level-8-default)))
      (copy-face (cdr face) (car face)))

    (copy-face 'org-document-title-default 'org-document-title)
    (copy-face 'org-block-default 'org-block)
    (copy-face 'org-table-default 'org-table)
    (copy-face 'org-formula-default 'org-formula)
    (copy-face 'org-code-default 'org-code)
    (copy-face 'org-verbatim-default 'org-verbatim)
    (copy-face 'org-special-keyword-default 'org-special-keyword)
    (copy-face 'org-meta-line-default 'org-meta-line)
    (copy-face 'org-checkbox-default 'org-checkbox)

    ;; Clear the header line format by setting to `nil'
    (setq-local header-line-format nil)

    ;; Stop centering the document
    (visual-fill-column-mode 0)
    (visual-line-mode 0)

    ;; Re-enable line numbers
    (display-line-numbers-mode 1)

    (variable-pitch-mode 0))

  ;; Remove normal/evil motion bindings so we can edit
  ;; the doc in presentation mode
  (map! :map org-present-mode-keymap :n "j" nil)
  (map! :map org-present-mode-keymap :n "k" nil)
  (map! :map org-present-mode-keymap "<right>" nil)
  (map! :map org-present-mode-keymap "<left>" nil)

  ;; Map prev/next slides to page-down and page-up
  (map! :map org-present-mode-keymap "<next>" #'org-present-next)
  (map! :map org-present-mode-keymap "<prior>" #'org-present-prev)

  (add-hook 'org-present-mode-hook #'my/org-present-start)
  (add-hook 'org-present-mode-quit-hook #'my/org-present-quit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Dafny Mode ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! boogie-friends
  (setq flycheck-dafny-executable "/usr/bin/dafny")
  (map! :map dafny-mode-map :localleader
        "c" #'lsp-dafny-counterexamples-mode)

  ;; Add hook to force counterexamples update after flycheck
  ;; (this should probably be in lsp-dafny; maybe a PR?)
  (add-hook 'lsp-dafny-counterexamples-mode-hook
            (lambda ()
              (if lsp-dafny-counterexamples-mode
                  (add-hook 'flycheck-after-syntax-check-hook
                            #'lsp-dafny--counterexamples-show)
                (remove-hook 'flycheck-after-syntax-check-hook
                             #'lsp-dafny--counterexamples-show)))))
