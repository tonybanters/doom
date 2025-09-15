;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-G

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tokyo-night)
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 28))
;; (setq doom-font (font-spec :family "Jost Medium:style=Regular" :size 28))
(set-frame-parameter (selected-frame) 'alpha '(90 . 90))
(add-to-list 'default-frame-alist '(alpha . (90 . 90)))

;; Enable syntax highlighting in #+begin_src blocks
(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-hide-block-startup nil
      org-src-preserve-indentation nil
      org-edit-src-content-indentation 0)

(after! evil
  ;; Treat dash (-) as part of word
  (modify-syntax-entry ?- "w" (standard-syntax-table))
  (modify-syntax-entry ?- "w" (syntax-table)))

;; Also works for symbol-based motions like `yiw`, `ciw`, etc.
(after! evil
  (setq evil-symbol-word-search t))

;; Make C-c quit insert mode in Evil
(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
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
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(use-package fzf
  :commands (fzf fzf-git fzf-grep fzf-git-grep)
  :init
  (setq fzf/args "-x --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        fzf/grep-command "rg --no-heading -nH"
        fzf/position-bottom t
        fzf/window-height 15))


;; Enable fuzzy matching everywhere
(setq completion-styles '(orderless)
      completion-category-defaults nil
      completion-category-overrides '((file (styles . (orderless)))))

(setq consult-fd-args "fd --color=never --type f --hidden --follow --exclude .git")

;; Base dir for ripgrep
(defvar my/base-dir (getenv "HOME")
  "Base directory for project-wide grep-like commands.")

(defun my/set-base-dir ()
  "Set the root directory for consult-ripgrep."
  (interactive)
  (let ((dir (read-directory-name "Set base directory: " my/base-dir)))
    (setq my/base-dir dir)
    (message "Search root set to: %s" dir)))

(defun my/consult-ripgrep-base ()
  "Run consult-ripgrep from the custom base dir."
  (interactive)
  (consult-ripgrep my/base-dir))

(defun my/consult-ripgrep-symbol-base ()
  "Search for symbol at point from custom base dir."
  (interactive)
  (let ((sym (thing-at-point 'symbol t)))
    (consult-ripgrep my/base-dir sym)))

(defun my/consult-fd ()
  "Run consult-fd from the custom base dir."
  (interactive)
  (let ((default-directory my/base-dir))
    (consult-fd)))

(defun my/fzf-find-files ()
  "Fuzzy find files in base dir using fzf."
  (interactive)
  (let ((default-directory my/base-dir))
    (fzf)))

(defun my/fzf-base-dir ()
  "FZF using files in `my/base-dir` via fd."
  (interactive)
  (let ((process-environment
         (cons (format "FZF_DEFAULT_COMMAND=fd --type f --hidden --follow --exclude .git . %s" my/base-dir)
               process-environment))
        (default-directory my/base-dir))
    (fzf)))


(defun my/consult-fd-doom ()
  "Run consult-fd in ~/.config/doom"
  (interactive)
  (let ((default-directory "~/.config/doom"))
    (consult-fd)))

(defun my/fzf-doom-config ()
  "Fuzzy find files in ~/.config/doom using fzf."
  (interactive)
  (let ((default-directory "/home/tony/.config/doom"))
    (fzf)))

(defun my/fzf-home ()
  "Fuzzy find files in ~/.config/doom using fzf."
  (interactive)
  (let ((default-directory "/home/tony/tonybtw"))
    (fzf)))
(use-package org-fancy-priorities
  :ensure t
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚑" "▲" "»")))

;; (setq
;;    ;; org-fancy-priorities-list '("[A]" "[B]" "[C]")
;;    ;; org-fancy-priorities-list '("❗" "[B]" "[C]")
;;    org-fancy-priorities-list '("🟥" "🟧" "🟨")
;;    org-priority-faces
;;    '((?A :foreground "#ff6c6b" :weight bold)
;;      (?B :foreground "#98be65" :weight bold)
;;      (?C :foreground "#c678dd" :weight bold))
;;    org-agenda-block-separator 8411)

;; (defun my/org-pretty-priorities ()
;;   "Replace A/B/C priority cookies with custom symbols."
;;   (setq prettify-symbols-alist
;;         '(("[#A]" . "⚑")  ; High priority → flag
;;           ("[#B]" . "▲")  ; Medium priority → triangle
;;           ("[#C]" . "»"))) ; Low priority → arrow
;;   (prettify-symbols-mode 1))

;; (add-hook 'org-mode-hook #'my/org-pretty-priorities)
;; (add-hook 'org-agenda-mode-hook #'my/org-pretty-priorities)

;; Colors for agenda view
;; (custom-set-faces
;;  '(org-priority ((t (:inherit default))))
;;  '(org-priority-highest ((t (:foreground "red" :weight bold))))
;;  '(org-priority-high    ((t (:foreground "yellow" :weight bold))))
;;  '(org-priority-low     ((t (:foreground "green" :weight bold)))))

(map! :leader
      (:prefix ("f" . "file/find")
       :desc "ripgrep from base dir"       "g" #'my/consult-ripgrep-base
       ;; :desc "Find file from base dir"     "f" #'my/fzf-find-files
       ;; :desc "Find file from base dir"     "f" #'my/fzf-home
       :desc "Find file from base dir"     "f" #'my/consult-fd
       :desc "Find buffer"                 "b" #'consult-buffer
       :desc "ripgrep symbol from base"    "s" #'my/consult-ripgrep-symbol-base
       :desc "Find Doom config via fzf"    "i" #'my/fzf-doom-config
       :desc "Find Recent files"           "o" #'consult-recent-file)
      (:prefix ("c" . "custom")
       :desc "Set base directory" "r" #'my/set-base-dir
       :desc "Dired at current file" "d"
       (lambda ()
         (interactive)
         (dired (file-name-directory (or buffer-file-name default-directory)))))
      (:prefix ("b" . "buffers")
       :desc "Buffer menu" "m" #'ibuffer))

(map! :n "gr" #'+lookup/references)

(setq org-agenda-files '("~/repos/agendas/personal.org" "~/repos/agendas/work.org"))

(after! org
  ;; Enable org-superstar-mode automatically in org buffers
  (add-hook 'org-mode-hook #'org-superstar-mode)

  ;; Custom bullet characters
  (setq org-superstar-headline-bullets-list
        '("◉" "●" "○" "◆" "●" "○" "◆")))
