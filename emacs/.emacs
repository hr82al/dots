(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(package-selected-packages
   '(lsp-ui lsp-mode company-flx company-fuzzy company use-package eglot))
 '(tool-bar-mode nil))

(cond
 ((string-equal system-type "darwin") ; Mac OS X
  (progn
    (setq mac-option-key-is-meta nil)
    (setq mac-command-key-is-meta t)
    (setq mac-command-modifier 'meta)
    (setq mac-option-modifier nil)
    (custom-set-faces
     '(default ((t (:family "Liberation Mono" :foundry "nil" :slant normal :weight regular :height 180 :width normal)))))))
 ((string-equal system-type "gnu/linux") ; linux
  (progn
    (menu-bar-mode 0)
    (custom-set-faces
     '(default ((t (:family "Liberation Mono" :foundry "1ASC" :slant normal :weight regular :height 143 :width normal)))))))

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
	    (setq typescript-ts-mode-indent-offset 2)))






;; (add-hook 'python-ts-mode-hook-mode-hook #'lsp-deferred)

(use-package lsp-mode
  :config
  (setq lsp-idle-delay 0.5
        lsp-enable-symbol-highlighting t
        lsp-enable-snippet nil  ;; Not supported by company capf, which is the recommended company backend
        lsp-pyls-plugins-flake8-enabled t)
  (lsp-register-custom-settings
   '(("pyls.plugins.pyls_mypy.enabled" t t)
     ("pyls.plugins.pyls_mypy.live_mode" nil t)
     ("pyls.plugins.pyls_black.enabled" t t)
     ("pyls.plugins.pyls_isort.enabled" t t)

     ;; Disable these as they're duplicated by flake8
     ("pyls.plugins.pycodestyle.enabled" nil t)
     ("pyls.plugins.mccabe.enabled" nil t)
     ("pyls.plugins.pyflakes.enabled" nil t)))
  :hook
  ((python-ts-mode . lsp))
  :ensure t)

(use-package lsp-ui
  :config (setq lsp-ui-sideline-show-hover t
                lsp-ui-sideline-delay 0.5
                lsp-ui-doc-delay 5
                lsp-ui-sideline-ignore-duplicates t
                lsp-ui-doc-position 'bottom
                lsp-ui-doc-alignment 'frame
                lsp-ui-doc-header nil
                lsp-ui-doc-include-signature t
                lsp-ui-doc-use-childframe t)
  :commands lsp-ui-mode
  :ensure t)




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

(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)



(setenv "QC" "/home/pd/.config/qtile/config.py")
(setenv "EC" "/home/pd/.emacs")

