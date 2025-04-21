
;;; Code:
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("eorg"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここにいっぱい設定を書く
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))


(leaf leaf-convert
  :setq ((ring-bell-function quote ignore)))


(leaf *language-settings
  :config
  (set-language-environment 'Japanese) ;言語を日本語に
  (prefer-coding-system 'utf-8) ;極力UTF-8を使う
  (leaf mozc ;; Mozc setting
    :ensure t
    :config
    (setq default-input-method "japanese-mozc")
    (global-set-key (kbd "C-o") 'toggle-input-method)
    (define-key mozc-mode-map (kbd "C-o") 'toggle-input-method)))

;; sudo apt-get install cmigemo
;; 以下の設定はubuntu用
(leaf migemo
  :ensure t
  :require t
  :defun
  (migemo-init)
  :custom
  (migemo-command . "cmigemo")
  (migemo-options . '("-q" "--emacs"))
  (migemo-dictionary . "/usr/share/cmigemo/utf-8/migemo-dict")
  (migemo-user-dictionary . nil)
  (migemo-regex-dictionary . nil)
  (migemo-coding-system . 'utf-8-unix)
  :config
  (migemo-init))

(leaf *font
  :config
  ;; 絵文字インストール
  (leaf nerd-icons :ensure t)
  (set-face-attribute 'default nil
                     :family "HackGen Console NF" ;; フォントファミリ名
                     :foundry "PfEd"              ;; フォントの作成元
                     :width 'normal               ;; フォント幅
                     :height 140                  ;; フォントサイズ
                     :weight 'regular             ;; フォントの太さ
                     :slant 'normal               ;; フォントの傾斜
                     :foreground "#333333"        ;; 前景色
                     :background "#FFFFFF")       ;; 背景色
  )


(leaf vterm :ensure t)
;; sudo apt install cmake libtool libtool-bin
;; C-c C-tでコピーモードを切り替えられる

(leaf files
  :doc "file input and output commands for Emacs"
  :tag "builtin"
  :custom `((auto-save-timeout . 15)
            (auto-save-interval . 60)
            (auto-save-file-name-transforms . '((".*" ,(locate-user-emacs-file "backup/") t)))
            (backup-directory-alist . '((".*" . ,(locate-user-emacs-file "backup"))
                                        (,tramp-file-name-regexp . nil)))
            (version-control . t)
            (delete-old-versions . t)))

(leaf japanese-holidays
  :ensure t
  :require t
  :config
  (setq calendar-holidays (append calendar-holidays japanese-holidays)))


(leaf magit :ensure t)

(leaf *org
  :config
  (setq org-src-preserve-indentation t)
  (leaf org-babel
    :defvar
    org-babel-python-command
    org-startup-with-iniline-images
    org-confirm-babel-evaluate
    :config
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((shell      . t)
       (emacs-lisp . t)
       (lisp       . t)
       (plantuml   . t)
       (org        . t)
       (python     . t)
       (dot        . t)
       (latex      . t)
       (jupyter    . t)))    
    (setq org-babel-python-command "python3")
    (setq org-startup-with-iniline-images t)
    (setq org-confirm-babel-evaluate nil)
    (setq org-src-fontify-natively t)
    )
  (setq org-image-actual-width nil)
  (leaf ox-gfm :ensure t
    :config (require 'ox-gfm))
  (leaf org-attach-screenshot
    :ensure t
    :custom
    (org-attach-screenshot-dirfunction .
				       (lambda () (concat (file-name-sans-extension (buffer-file-name)) "-att"))))
  (leaf org-capture
    :config
    (setq org-directory "~/org")
    (setq org-daily-tasks-file (format "%s/tasks.org" org-directory))
    (global-set-key (kbd "\C-cc") 'org-capture)
    :custom
    (org-capture-templates .
    '(("d" "daily TODO" entry (file org-daily-tasks-file) "%[~/.emacs.d/assets/org-templates/routine.org]" :prepend t))))
  (leaf org-agenda
    :config
    (global-set-key (kbd "\C-ca") 'org-agenda)
    (setq org-agenda-files '("/prj/trade/journal/" "~/diary/"
			     "~/work/2024/emacs-python/"
			     "~/org/")))
  (leaf org-modern
    :ensure t
    :custom
    (org-modern-progress . '("○" "◔" "◑" "◕" "✅"))
    :hook
    ((org-mode . org-modern-mode)
     (org-agenda-finalize . org-modern-agenda)))
  (setq org-fontify-quote-and-verse-blocks t)

  ;; org-block のフェイス設定
  (set-face-attribute 'org-block nil
                      :background "#FFFFE0"
                      :foreground "#000088"
                      :extend t)

  ;; org-block-begin-line のフェイス設定
  (set-face-attribute 'org-block-begin-line nil
                      :background "#E0E0E0"
                      :foreground "#000000"
                      :italic t
                      :extend t)

  ;; org-block-end-line のフェイス設定
  (set-face-attribute 'org-block-end-line nil
                      :background "#E0E0E0"
                      :foreground "#000000"
                      :italic t
                      :extend t)
  )

(leaf org-roam
  :ensure t
  :init
  ;; Acknowledge V2 migration warnings, set before loading org-roam
  (setq org-roam-v2-ack t)
  :config
  ;; Set the directory where Org Roam files are stored
  (setq org-roam-directory (file-truename "~/org/roam/"))
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:15}" 'face 'org-tag)))

  ;; Ensure the roam directory exists before enabling autosync
  (let ((roam-dir (expand-file-name org-roam-directory)))
    (unless (file-directory-p roam-dir)
      ;; Create the directory if it doesn't exist
      (make-directory roam-dir t)
      (message "Created Org Roam directory: %s" roam-dir)))

  ;; Enable automatic database synchronization
  (org-roam-db-autosync-mode)

  ;; Define keybindings globally
  (define-key global-map (kbd "C-c n f") #'org-roam-node-find)
  (define-key global-map (kbd "C-c n i") #'org-roam-node-insert)
  (define-key global-map (kbd "C-c n d") #'org-roam-dailies-capture-today)
  ;; Add more keybindings as needed
  )

;; setting for taskchute

(leaf revita
  :el-get "yamanogotoshi/revita"
  :require t
  :hook
  (kill-emacs-hook . revita-save-project-file-alist)
  (org-after-todo-state-change-hook . revita-org-add-logbook-if-missing)
  (org-clock-in-hook . revita-org-update-start-time)
  (org-clock-out-hook . revita-org-update-end-time)
  :bind
  ("C-c t" . (lambda () 
               (interactive)
               (find-file "~/org/tasks.org")))
  ("C-c o" . revita-open-project-file)
  ("C-c p" . revita-insert-project-link)
  :setq
  (org-columns-default-format . "%5TODO(state) %10TAGS(proj) %25ITEM(task) %Effort(estim){:} %CLOCKSUM(clock) %START_TIME(start) %END_TIME(end)"))

(defun days-between-dates (date1 date2)
  "Calculate the number of days between DATE1 and DATE2.
   Dates should be strings in the format 'YYYY-MM-DD'."
      (let ((time1 (date-to-time date1))
            (time2 (date-to-time date2)))
	(floor (- (time-to-days time2)
		  (time-to-days time1)))))

(leaf *jupyter
  :config
  (leaf jupyter
    :ensure t
    :defvar jupyter-repl-echo-eval-p
    :config
    (setq jupyter-repl-echo-eval-p t)
    ;:hook
    ; これを入れるとREPLにコードを送る挙動がおかしくなる
    ;(jupyter-repl-mode . (lambda () (display-line-numbers-mode -1))))
    )
  (leaf zmq :ensure t))

(leaf code-cells
  :ensure t
  :hook (python-ts-mode-hook . code-cells-mode-maybe)
  :config
  (define-key code-cells-mode-map (kbd "C-c C-c") #'code-cells-eval)
  (define-key code-cells-mode-map (kbd "M-p") #'code-cells-backward-cell)
  (define-key code-cells-mode-map (kbd "M-n") #'code-cells-forward-cell))

(defun image-save-with-arg (&optional file)
  "Save the image under point.
This writes the original image data to a file.  Rotating or
changing the displayed image size does not affect the saved image.
If FILE is provided, save to that file. Otherwise, prompt for a filename."
  (interactive)
  (let ((image (image--get-image)))
    (with-temp-buffer
      (let ((image-file (plist-get (cdr image) :file)))
        (if image-file
            (if (not (file-exists-p image-file))
                (error "File %s no longer exists" image-file)
              (insert-file-contents-literally image-file))
          (insert (plist-get (cdr image) :data))))
      (let ((save-file (or file
                           (read-file-name "Write image to file: "))))
        (write-region (point-min) (point-max) save-file)
        (message "Image saved to %s" save-file)))))

(defun my-image-save ()
  "Save the image under point to the '.fig' directory with a timestamp filename.
Creates the '.fig' directory if it doesn't exist.
Copies the full path of the saved image to the clipboard."
  (interactive)
  (let* ((fig-dir ".fig")
         (out-f (format-time-string (concat fig-dir "/%Y%m%d-%H%M%S.png")))
         (full-path (expand-file-name out-f)))
    ;; Create '.fig' directory if it doesn't exist
    (unless (file-exists-p fig-dir)
      (make-directory fig-dir t)
      (message "Created directory: %s" (expand-file-name fig-dir)))
    ;; Save the image
    (image-save-with-arg out-f)
    ;; Copy the full path to clipboard
    (kill-new full-path)
    ;; Message to inform user
    (message "Image saved and full path copied to clipboard: %s" full-path)    
    ;; Return the full path of the saved image
    full-path))

(defun my-image-yank ()
  "Insert an Org mode file link for the image path in the clipboard at the current cursor position.
Only insert if the file is an image (png, jpg, jpeg, gif, or svg)."
  (interactive)
  (let ((file-path (substring-no-properties (current-kill 0))))
    (if (string-match-p "\\.\\(png\\|jpe?g\\|gif\\|svg\\)$" file-path)
        (let ((relative-path (file-relative-name file-path)))
          (insert (format "#+ATTR_HTML: :width 300\n[[file:%s]]" relative-path))
          (org-redisplay-inline-images))
      (message "Clipboard content is not a supported image file path. No insertion performed."))))

;; npm install -g pyrightが別で必要
(leaf eglot
  :ensure t
  :defvar eglot-server-programs
  :hook
  (python-ts-mode-hook . eglot-ensure)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
		 '((python-mode python-ts-mode) .
		   ; ruffコマンド内蔵のruff-lspを使う場合
		   ;("ruff" "server")
		   ; pip install ruff-lspで入れたruff-lspを使う場合
		   ;("ruff-lsp")
		   ("pyright-langserver" "--stdio")
		   ))))

;; Tree-sitter
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; code format
;; ref https://tam5917.hatenablog.com/entry/2024/07/01/150557
;; reformatterについての解説 https://apribase.net/2024/06/10/emacs-reformatter/
(leaf reformatter
  :ensure t
  :config
  (leaf ruff-format
    :ensure t
    :hook
    (python-ts-mode-hook . ruff-format-on-save-mode))
  (reformatter-define ruff-sort-imports
		      :program "ruff"
		      :args (list "check" "--fix" "--select" "I001" "--stdin-filename"
				  (or (buffer-file-name) input-file))
		      :group 'python)
  ;; 保存時にruffでimport順をソートするマイナーモード
  (add-hook 'python-ts-mode-hook #'ruff-sort-imports-on-save-mode)
  ;; ruffによってfixをかけるコマンドやマイナーモードを導入
  (reformatter-define ruff-fix
		      :program "ruff"
		      :args  (list "check" "--fix" "--stdin-filename"
				   (or (buffer-file-name) input-file))
		      :group 'python)
  )

;; syntax check
;; ref https://mako-note.com/ja/python-emacs-eglot/#pyright
(use-package flymake-ruff
  :ensure t
  :hook (eglot-managed-mode-hook . (lambda ()
                                     (when (derived-mode-p 'python-mode 'python-ts-mode)
                                       (flymake-ruff-load)))))

(use-package flymake
  :ensure t
  :bind (nil
         :map flymake-mode-map
         ("C-c C-p" . flymake-goto-prev-error)
         ("C-c C-n" . flymake-goto-next-error))
  :config
  (set-face-background 'flymake-errline "red4")
  (set-face-background 'flymake-warnline "DarkOrange"))

(use-package flymake-diagnostic-at-point
  :ensure t
  :after flymake
  :config
  (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode)
  (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))


;; code template, completion
;; ref https://mako-note.com/ja/python-emacs-eglot/#tempel
;; ref https://qiita.com/nobuyuki86/items/7c65456ad07b555dd67d
;; ref https://github.com/minad/tempel

(use-package corfu
  :custom ((corfu-auto t)
           (corfu-auto-delay 0)
           (corfu-auto-prefix 3)
           (corfu-cycle t)
           (corfu-on-exact-match nil)
           (tab-always-indent 'complete))
  :bind (:map corfu-map
         ("TAB" . corfu-insert)
         ("<tab>" . corfu-insert)
         ("RET" . nil)
         ("<return>" . nil))
  :init
  :config
  (global-corfu-mode +1)
  (setq max-specpdl-size 13000)  ; デフォルトは 1600
  (setq max-lisp-eval-depth 10000)  ; デフォルトは 800
  )

;; Configure Tempel
(use-package tempel
  ;; Require trigger prefix before template name when completing.
  :custom
  (tempel-trigger-prefix "<")
  (tempel-path "~/.emacs.d/templates/*")

  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert))

  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  ;; (global-tempel-abbrev-mode)
)

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
(use-package tempel-collection
  :ensure t)


(leaf *complement
  :config
  (leaf vertico
    :ensure t
    :init
    (vertico-mode))
  (leaf consult
    :ensure t)
  (leaf orderless
    :ensure t
    :init  (icomplete-mode)
    :custom  (completion-styles . '(orderless)))
  (leaf embark
    :ensure t
    :bind
    ("C-c C-o" . embark-export)
    ("C-S-a" . embark-act)       ;; pick some comfortable binding
    ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  (leaf embark-consult
    :ensure t
    :after (embark consult)
    :hook
    (embark-collect-mode . consult-preview-at-point-mode))
  (leaf marginalia
    :ensure t
    :defun marginalia-mode
    :init
    (marginalia-mode))
  (leaf affe
    :ensure t
    :after (orderless consult))
  )

; AI
;; ellama

(load "~/.emacs.d/secrets.el")
(leaf *llm
  :config  
  (leaf llm
    :ensure t
    :require llm-gemini
    :config
    (defvar my-gemini-provider
      (make-llm-gemini :key gemini-api-key))
    :custom
    (llm-warn-on-nonfree . nil))
  (leaf ellama
    :ensure t
    :custom
    (ellama-language . "Japanese")
    :config
    (setq ellama-provider my-gemini-provider)
    ))

;; aidermacs
; $ pip install aider-install
; $ aider-install 
(use-package aidermacs
  :ensure t
  :bind
  ("C-c a" . aidermacs-transient-menu)
  :config
  (setq aidermacs-backend 'comint)
  :custom
  ; See the Configuration section below
  (aidermacs-use-architect-mode t)
  (aidermacs-default-model "openrouter/google/gemini-2.5-pro-exp-03-25:free"))


;; xwidget
(setq xwidget-webkit-cookie-file (expand-file-name "webkit-cookies.txt" user-emacs-directory))

(setq display-time-interval 60)
(setq display-time-string-forms
  '((format "%s:%s" 24-hours minutes)))
(setq display-time-day-and-date t)
(display-time-mode t)
(global-display-line-numbers-mode 1)

(add-to-list 'exec-path "~/.pyenv/shims")

(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)



