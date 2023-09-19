(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(package-selected-packages
   '(company-flx helm company-fuzzy elisp-ts-mode company tree-sitter typescript-mode use-package eglot)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Liberation Mono" :foundry "1ASC" :slant normal :weight regular :height 143 :width normal)))))

(menu-bar-mode 0)
(tool-bar-mode 0)


(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)


(defun init-tree-sitter-langs ()
  (setq treesit-language-source-alist
	'(
	  (rust "https://github.com/tree-sitter/tree-sitter-rust") 
	  (python "https://github.com/tree-sitter/tree-sitter-python")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
	  (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
	  (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
	  (c "https://github.com/tree-sitter/tree-sitter-c")
	  (bash "https://github.com/tree-sitter/tree-sitter-bash")
	  (css "https://github.com/tree-sitter/tree-sitter-css")
	  (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
	  (yaml "https://github.com/ikatyang/tree-sitter-yaml")
	  (json "https://github.com/tree-sitter/tree-sitter-json")
	  (html "https://github.com/tree-sitter/tree-sitter-html")))
  (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist)))

(unless (treesit-language-available-p 'typescript)
  (init-tree-sitter-langs))


(use-package company
  :init
  (setq company-require-match nil            ; Don't require match, so you can still move your cursor as expected.
        company-tooltip-align-annotations t  ; Align annotation to the right side.
        company-eclim-auto-save nil          ; Stop eclim auto save.
        company-dabbrev-downcase nil)        ; No downcase when completion.
  :config
  ;; Enable downcase only when completing the completion.
  (defun jcs--company-complete-selection--advice-around (fn)
    "Advice execute around `company-complete-selection' command."
    (let ((company-dabbrev-downcase t))
      (call-interactively fn)))
  (advice-add 'company-complete-selection :around #'jcs--company-complete-selection--advice-around)
  :ensure t)

(use-package company-flx
  :ensure t)

(use-package company-fuzzy
  :hook (company-mode . company-fuzzy-mode)
  :init
  (setq company-fuzzy-sorting-backend 'flx
	company-fuzzy-prefix-on-top nil
        company-fuzzy-trigger-symbols '("." "->" "<" "\"" "'" "@"))
  :ensure t)

(setq company-idle-delay 0.5)


(add-hook 'lisp-interaction-mode-hook (lambda () (progn(company-mode))))


(add-to-list 'auto-mode-alist '("\\.rs\\'" .  rust-ts-mode))
(add-hook 'rust-ts-mode-hook
	  (lambda ()
	    (eglot-ensure)
	    (company-mode 1)
	    ))

(add-to-list 'auto-mode-alist '("\\.ts\\'" .  typescript-ts-mode))
(add-hook 'typescript-ts-mode-hook
	  (lambda ()
	    (eglot-ensure)
	    (company-mode 1)
	    (setq indent-tabs-mode nil)
	    (setq tab-width 2)
	    (setq typescript-ts-mode-indent-offset 2)
	    ))

(global-set-key (kbd "C-<tab>") #'company-indent-or-complete-common)


;; IDO
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(setq ido-use-filename-at-point 'guess)
(setq ido-use-url-at-point nil)
(setq ido-create-new-buffer 'always)
(setq ido-file-extensions-order '(".ts" ".txs" ".js" ".jsx" ".org" ".txt" ".py" ".emacs" ".xml" ".el" ".ini" ".cfg" ".cnf"))
(setq ido-ignore-extensions t)
