;;; emacs-init -- Initialize Emacs

;;; Commentary:

;; This is Joelle's Emacs configuration file

;;; Code:

;; Debug on error
; (setq debug-on-error t)

;; Use the MALPA repo
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Update package contents
(unless package-archive-contents (package-refresh-contents))

;; We want the use-package macro
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Let's set up VI-mode
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1))
(setq undo-tree-history-directory-alist '(("." . "~/tmp")))
;; (require 'evil)
(use-package evil
  :ensure t
  :config
  (evil-mode)
  (evil-set-undo-system 'undo-tree))

;; LaTeX
;(defun TeX-ispell-skip-setchar ()
;    "Placate flycheck."
;  (nil)
(use-package auctex
  :ensure t
  :defer t)
(add-hook 'LaTeX-mode-hook #'visual-line-mode)
(require 'tex-ispell)
(eval-after-load "tex-ispell"
  '(progn
     (TeX-ispell-skip-setcar
      '(("\\\\autocite" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\citeyear" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\nptextcite" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\nptextcites" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\parencite" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\parencites" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\textncite" ispell-tex-arg-end 1)))
     (TeX-ispell-skip-setcar
      '(("\\\\textncites" ispell-tex-arg-end 1)))))

;; Wrap lines in org mode
(add-hook 'org-mode-hook #'visual-line-mode)

;; Display line numbers
(global-display-line-numbers-mode)

;; Display column numbers in status bar
(setq column-number-mode t)

;; Highlight tabs
(require 'whitespace)
(global-whitespace-mode t)
(setq whitespace-style '(face empty lines-tail tabs tab-mark trailing))
(setq whitespace-line-column 1000000)

;; Put custom stuff in a different file
(setq custom-file "~/.custom.el")

;; org-mode
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; Git
(unless (package-installed-p 'magit)
  (package-install 'magit))
(require 'magit)

;; Delete autosave files and backup files
;; Borrowed from https://se30.xyz/conf.html
(defvar jmaslak/autosave-dir "~/tmp")
(make-directory jmaslak/autosave-dir t)
(setq auto-save-file-name-transforms
      `((".*" ,jmaslak/autosave-dir t)))
(setq make-backup-files nil)

;; No startup messages
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Define function to turn off tabs, from
;; https://emacs.stackexchange.com/questions/52047/how-to-change-shell-script-mode-indentation-not-to-use-tabs
(defun turn-off-indent-tabs-mode ()
    "Turn off indent tabs mode."
  (setq indent-tabs-mode nil))

;; Shell script config
(add-hook 'sh-mode-hook #'turn-off-indent-tabs-mode)

;; Git highlights
(unless (package-installed-p 'diff-hl)
  (package-install 'diff-hl))
(use-package diff-hl)
(diff-hl-flydiff-mode)
(global-diff-hl-mode)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

;; Flycheck
(use-package flycheck
  :ensure t
  :defer t
  :hook (prog-mode . flycheck-mode))

;; Raku
(use-package raku-mode
  :ensure t
  :defer t)

;; Perl
(defalias 'perl-mode 'cperl-mode)
(require 'cperl-mode)
(setq cperl-indent-level 4)

(provide '.emacs)
;;; .emacs ends here
