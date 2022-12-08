;; Use the MALPA repo
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; We want the use-package macro
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Let's set up VI-mode
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1))
(use-package evil
  :ensure t
  :config
  (evil-mode)
  (evil-set-undo-system 'undo-tree))

;; LaTeX
(use-package auctex
  :ensure t
  :defer t)
(add-hook 'LaTeX-mode-hook #'visual-line-mode)

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
