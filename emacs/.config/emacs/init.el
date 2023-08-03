;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

;; Magit won't install on the Mac on 28.1 so this is a temporary workaround
(pcase system-type 
  ('darwin (add-to-list 'package-archives
			(cons "gnu-devel" "https://elpa.gnu.org/devel/")
			t)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; macOS Only but might want in Linux
(pcase system-type
  ('darwin (use-package exec-path-from-shell
	     :ensure t
	     :if (memq window-system '(mac ns x))
	     :config
	     ;; (setq exec-path-from-shell-variables '("PATH" "GOPATH"))
	     (exec-path-from-shell-initialize))))

(setq inhibit-startup-message t)      ; Disable startup message
(menu-bar-mode -1)                    ; Disable the menu bar
(scroll-bar-mode -1)                  ; Disable the scroll bar
(tool-bar-mode -1)                    ; Disable the toolbar
(tooltip-mode -1)                     ; Disable tooltips
(set-fringe-mode 10)                  ; Give some breathing room
(setq visible-bell t)                 ; Set up the visible bell
(minibuffer-electric-default-mode t)  ; Make default disappear in the minibuffer when typing
(setq suggest-key-bindings 3)         ; Make keybinding suggestions stick around longer

;; Change the startup message in the minibuffer to a nice greeting
(defun display-startup-echo-area-message ()
  (message "Welcome back Aleks!"))

(setq vc-follow-symlinks nil) ; Stop Emacs from asking about following symlinks when opening files
(recentf-mode 1) ; Have Emacs remember recently opened files when using fild file

;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)

(save-place-mode 1) ; Remember and restore the last cursor location of opened files

(global-auto-revert-mode 1) ; Revert buffers when the underlying file has changed
(setq global-auto-revert-non-file-buffers t) ; Revert Dired and other buffers

(windmove-default-keybindings 'super) ; Navigate between windows with s-<arrow keys>

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode -1) ; Right now they are disabled

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                mu4e-headers-mode-hook
                mu4e-main-mode-hook
                mu4e-view-mode-hook
                org-agenda-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(pcase system-type
  ('gnu/linux
   (set-face-attribute 'default nil :font "Liberation Mono" :height 140))
  ('darwin
   (set-face-attribute 'default nil :font "Monaco" :height 170)))

;; Configure the Modus Theme's appearance
(setq modus-themes-mode-line '(accented)
      modus-themes-bold-constructs t
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold-intense)
      modus-themes-prompts '(bold-intense)
      modus-themes-completions 'opinionated
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings nil
      modus-themes-region '(bg-only)
      modus-themes-headings
      '((1 . (rainbow overline background 1.4))
	(2 . (rainbow background 1.3))
	(3 . (rainbow bold 1.2))
	(t . (semilight 1.1))))

;; Load a Theme
(load-theme 'modus-operandi t)

;; Set a hot-key for switching between light and dark theme
(define-key global-map (kbd "<f5>") #'modus-themes-toggle)

;; Backup options
(setq backup-directory-alist '(("." . "~/.config/emacs/backup/"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      )

;; auto-save
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq kill-buffer-delete-auto-save-files t)

;; Key re-bindings
(global-set-key (kbd "M-o") 'other-window)    ; Move to the other window C-x o but also now M-o
(global-set-key (kbd "M-i") 'imenu)           ; Invoke imenu. This replaces tab-to-tab-stop but what is that even?

(setq auth-sources '("~/.authinfo.gpg"))

(setq bookmark-default-file
      (pcase system-type
	('gnu/linux "~/Dropbox/apps/emacs/bookmarks")
	('darwin "~/Library/CloudStorage/Dropbox/apps/emacs/bookmarks")))

(global-set-key (kbd "<f8>") 'bookmark-bmenu-list)

(setq completion-styles '(substring))  ;; define the completion style
(setq completion-ignore-case  t)  ;; ignore case

;; whick-key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Vertico
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package corfu
  :ensure t)

(global-corfu-mode 1)

(corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

(define-key corfu-map (kbd "<tab>") #'corfu-complete)
(setq tab-always-indent 'complete) ;; This we needed for tab to work. Not from Prot's config.

;; Adapted from Corfu's manual.
(defun contrib/corfu-enable-always-in-minibuffer ()
  "Enable Corfu in the minibuffer if Vertico is not active.
  Useful for prompts such as `eval-expression' and `shell-command'."
  (unless (bound-and-true-p vertico--input)
    (corfu-mode 1)))

(add-hook 'minibuffer-setup-hook #'contrib/corfu-enable-always-in-minibuffer 1)

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; Use GNU ls as insert-directory-program in case of macOS
(when (eq system-type 'darwin)
  (setq insert-directory-program "gls"))

;; Use human readable sizes and group directories first
(setq dired-listing-switches "-alh --group-directories-first")

(setq dired-dwim-target t)            ;; When copying/moving, suggest other dired buffer as target
(setq dired-recursive-copies 'always) ;; Always copy/delete recursively
(setq dired-recursive-deletes 'top)   ;; Ask once before performing a recursive delete

;; Hide details by default
(add-hook 'dired-mode-hook
	  (lambda ()
	    (dired-hide-details-mode 1)))

;; Do not disable using 'a' to visit a new directory without killing the buffer
(put 'dired-find-alternate-file 'disabled nil)

(use-package dired-hide-dotfiles
  :ensure t)

(defun my-dired-mode-hook ()
  "My `dired' mode hook."
  ;; To hide dot-files by default
  (dired-hide-dotfiles-mode))

;; To toggle hiding
(define-key dired-mode-map "." #'dired-hide-dotfiles-mode)
(add-hook 'dired-mode-hook #'my-dired-mode-hook)

(defun dired-xdg-open-file ()
  "Use xdg-open command on a file from dired."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (message "Opening %s..." file)
    (call-process "xdg-open" nil 0 nil file)))

(define-key dired-mode-map (kbd "V") 'dired-xdg-open-file)

(defun my/zapier-day ()
  "Gets a work day started!"
  (interactive)
  (org-agenda nil "z")
  (tab-rename "Agenda")
  (tab-new)
  (org-roam-dailies-goto-today)
  (tab-rename "Notes")
  (save-buffer)
  (tab-next))

(defun my/home-day ()
  "Gets a personal day started!"
  (interactive)
  (org-agenda nil "h")
  (tab-rename "Agenda")
  (tab-new)
  (org-roam-dailies-goto-today)
  (tab-rename "Notes")
  (save-buffer)
  (tab-new)
  (mu4e)
  (sleep-for 3)
  (tab-rename "Email")
  (tab-next))

(defun my/view-and-update-clocktables ()
  "Open time_tracking.org in a split buffer and update all clock tables."
  (interactive)
  (let ((buffer (find-file-noselect "~/docs/org-roam/time_tracking.org")))
    (with-current-buffer buffer
      (save-excursion
	(goto-char (point-min))
	(while (re-search-forward "^#\\+BEGIN: clocktable" nil t)
	  (org-ctrl-c-ctrl-c)
	  (forward-line)))
      (save-buffer))
    (display-buffer buffer)))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "C-c t") 'my/view-and-update-clocktables))

(defun my/kill-all-agenda-files ()
  "Close all buffers associated with files in `org-agenda-files'."
  (interactive)
  (let ((agenda-files (mapcar 'expand-file-name (org-agenda-files))))
    (dolist (buffer (buffer-list))
      (let ((buffer-file-name (buffer-file-name buffer)))
	(when (and buffer-file-name (member buffer-file-name agenda-files))
	  (kill-buffer buffer)))))
  (org-agenda-quit))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "Q") 'my/kill-all-agenda-files))

(define-derived-mode dropbox-exclude-mode fundamental-mode "Dropbox-Exclude"
  "Major mode for handling dropbox exclude list."
  (define-key dropbox-exclude-mode-map (kbd "n") 'next-line)
  (define-key dropbox-exclude-mode-map (kbd "p") 'previous-line)
  (define-key dropbox-exclude-mode-map (kbd "x") 'my/dropbox-add-directory)
  (define-key dropbox-exclude-mode-map (kbd "q") 'kill-buffer-and-window)
  (setq buffer-read-only t))

(defun my/dropbox-exclude-directory ()
  (interactive)
  (if (not (string-equal system-type "gnu/linux"))
      (message "Sorry, this function only works on Linux.")
    (if (not (file-exists-p "/usr/bin/dropbox-cli"))
        (message "dropbox-cli does not exist in /usr/bin/.")
      (let ((directories (dired-get-marked-files)))
        (dolist (directory directories)
          (if (not (string-match "Dropbox" directory))
              (message "Directory %s is not in Dropbox." directory)
            (let ((command (concat "dropbox-cli exclude add " directory)))
              (message "Running command: %s" command)
              (shell-command command)
              (when (get-buffer "*Dropbox Exclude List*")
                (with-current-buffer "*Dropbox Exclude List*"
                  (let ((buffer-read-only nil))
                    (erase-buffer)
                    (insert (shell-command-to-string "dropbox-cli exclude"))
                    (goto-char (point-min))
                    (setq buffer-read-only t)))))))))))

(defun my/dropbox-add-directory ()
  (interactive)
  (let* ((current-line (thing-at-point 'line t))
         (command (concat "dropbox-cli exclude remove " default-directory (string-trim current-line))))
    (message "Running command: %s" command)
    (shell-command command)
    (with-current-buffer "*Dropbox Exclude List*"
      (let ((buffer-read-only nil))
        (erase-buffer)
        (insert (shell-command-to-string "dropbox-cli exclude"))
        (goto-char (point-min)))
      (setq buffer-read-only t))))

(defun my/dropbox-exclude-list ()
  (interactive)
  (if (not (string-equal system-type "gnu/linux"))
      (message "Sorry, this function only works on Linux.")
    (if (not (file-exists-p "/usr/bin/dropbox-cli"))
        (message "dropbox-cli does not exist in /usr/bin/.")
      (if (not (string-match "Dropbox" default-directory))
          (message "Current directory is not in Dropbox.")
        (let* ((buffer-name "*Dropbox Exclude List*")
               (buffer (get-buffer-create buffer-name)))
          (split-window-right)
          (other-window 1)
          (switch-to-buffer buffer)
          (let ((buffer-read-only nil))
            (erase-buffer)
            (insert (shell-command-to-string "dropbox-cli exclude"))
            (goto-char (point-min))
            (setq buffer-read-only t))
          (dropbox-exclude-mode))))))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c d e") 'my/dropbox-exclude-list)
  (define-key dired-mode-map (kbd "C-c d x") 'my/dropbox-exclude-directory))

(defun my/zapier-friday-update-generator ()
    "Migrate entries under the 'Zapier' heading from past 7 days into new org file to trigger a Zap."
    (interactive)
    (require 'org)
    (let* ((base-dir "~/Dropbox/docs/org-roam/daily")
           (target-dir "~/Dropbox/docs/zapier/friday_update_gen")
           (date-format "%Y-%m-%d")
           (today (format-time-string date-format))
           (files-to-process
            (cl-loop for i from 0 to 6
                     for date-str = (format-time-string date-format (time-subtract (current-time) (days-to-time i)))
                     for filename = (expand-file-name (concat date-str ".org") base-dir)
                     if (file-exists-p filename)
                     collect filename))
           (target-file (expand-file-name (concat today ".org") target-dir))
           (zapier-heading "Zapier"))
      (with-current-buffer (find-file-noselect target-file)
        (goto-char (point-max))
        (dolist (file files-to-process)
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (while (re-search-forward (format "^\\* %s" zapier-heading) nil t)
              (let ((element (org-element-at-point)))
                (when (eq (org-element-type element) 'headline)
                  (let ((content (buffer-substring-no-properties (org-element-property :contents-begin element)
                                                                (org-element-property :contents-end element))))
                    (with-current-buffer (find-file-noselect target-file)
                      (goto-char (point-max))
                      (insert (format "* %s\n%s" (file-name-base file) content))))))))
          (save-buffer)))))

(defun my/add-to-agenda-files ()
  (interactive)
  (let ((current-file (buffer-file-name (current-buffer)))
        (agenda-file (expand-file-name "~/docs/agenda.txt" org-directory)))
    (with-temp-buffer
      (insert-file-contents agenda-file)
      (unless (search-backward current-file nil t)
        (goto-char (point-max))
        (unless (bolp)
          (insert "\n"))
        (insert current-file)
        (write-region (point-min) (point-max) agenda-file))
      (setq org-agenda-files (with-temp-buffer
                               (insert-file-contents agenda-file)
                               (split-string (buffer-string) "\n" t))))))

(defun my/remove-from-agenda-files ()
  (interactive)
  (let ((current-file (buffer-file-name (current-buffer)))
        (agenda-file (expand-file-name "~/docs/agenda.txt" org-directory)))
    (with-temp-buffer
      (insert-file-contents agenda-file)
      (goto-char (point-min))
      (when (search-forward current-file nil t) ; search for current file
        (beginning-of-line)
        (let ((begin (point)))
          (forward-line 1)
          (if (eobp)  ; if it's end of buffer, don't include newline
              (delete-region begin (point))
            (delete-region begin (1+ (point))))  ; else, include newline
        (write-region (point-min) (point-max) agenda-file))
      (setq org-agenda-files (with-temp-buffer
                               (insert-file-contents agenda-file)
                               (split-string (buffer-string) "\n" t)))))))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Magit
(use-package magit
  :ensure t)

(use-package pulsar
  :ensure t
  :init
  (setq pulsar-pulse t
	pulsar-delay 0.055
	pulsar-iterations 10
	pulsar-face 'pulsar-magenta
	pulsar-highlight-face 'pulsar-blue)
  :config
  (pulsar-global-mode 1)
  (let ((map global-map))
    (define-key map (kbd "C-x l") #'pulsar-pulse-line)
    (define-key map (kbd "C-x L") #'pulsar-highlight-dwim)))

(use-package ledger-mode
  :config
  (setq ledger-clear-whole-transactions 1)
  (setq ledger-default-date-format "%Y-%m-%d"))

;; Any file ending in _ledger.txt opens in ledger mode
(add-to-list 'auto-mode-alist '("_ledger\\.txt\\'" . ledger-mode))

(defun my/my-ledger ()
  "Open the ledger file located at ~/docs/finances/ledger/my_ledger.txt."
  (interactive)
  (find-file "~/docs/finances/ledger/my_ledger.txt")
  (goto-char (point-max)))

;; Bind the function to F4
(global-set-key (kbd "<f4>") 'my/my-ledger)

(defun my/backup-my-ledger-file ()
  (when (string= (buffer-file-name)
		 (expand-file-name "~/docs/finances/ledger/my_ledger.txt"))
    (let* ((current-date (format-time-string "%Y-%m-%d"))
	   (backup-dir (expand-file-name "~/docs/finances/ledger/backup/"))
	   (backup-file (concat backup-dir current-date "_my_ledger.txt")))
      (unless (file-exists-p backup-dir)
	(make-directory backup-dir))
      (write-region (point-min) (point-max) backup-file))))

(add-hook 'after-save-hook 'my/backup-my-ledger-file)

(defun my/ledger-remove-extra-blank-lines ()
  "Remove consecutive blank lines in ledger-mode buffers, leaving only a single blank line between text."
  (interactive)
  (if (eq major-mode 'ledger-mode)
      (save-excursion
	(goto-char (point-min))
	(while (re-search-forward "\\(^[[:space:]]*\n\\)[[:space:]]*\n+" nil t)
	  (replace-match "\\1")))
    (message "Warning: This function can only be used in ledger-mode.")))

(use-package rg
:config
(rg-enable-default-bindings))

;; Settings for tab-bar-mode
(tab-bar-mode t)                                                 ; Enable tab-bar-mode
(setq tab-bar-new-tab-choice "*scratch*")                        ; Automatically switch to the scratch buffer for new tabs
(setq tab-bar-new-tab-to 'rightmost)                             ; Make new tabs all the way to the right automatically
(setq tab-bar-new-button-show nil)                               ; Hide the new tab button - use the keyboard
(setq tab-bar-close-button-show nil)                             ; Hide the close tab button - use the keyboard
(setq tab-bar-tab-hints nil)                                     ; Hide the tab numbers
(setq tab-bar-format '(tab-bar-format-tabs tab-bar-separator))   ; Get rid of the history buttons in the tab bar

;; Keybindings
(global-set-key (kbd "s-{") 'tab-bar-switch-to-prev-tab)
(global-set-key (kbd "s-}") 'tab-bar-switch-to-next-tab)
(global-set-key (kbd "s-t") 'tab-bar-new-tab)
(global-set-key (kbd "s-w") 'tab-bar-close-tab)

;; tab-bar-history-mode lets you step back or forwad through the window config history of the current tab
(tab-bar-history-mode t)
(global-set-key (kbd "s-[") 'tab-bar-history-back)
(global-set-key (kbd "s-]") 'tab-bar-history-forward)

;; Put the elfeed DB on my Dropbox so the state syncs accross machines
(setq elfeed-db-directory "~/Dropbox/apps/elfeed")

;; Install the package
(use-package elfeed
  :ensure t)

;; Install another package to allow us to use an org file as the source for feeds
(use-package elfeed-org
  :ensure t
  :config
  (elfeed-org)
  (setq rmh-elfeed-org-files (list "~/Dropbox/docs/org-roam/rss_feeds.org")))

(use-package perspective
  :ensure t
  :bind
  ("C-x k" . persp-kill-buffer*)
  ("C-x C-b" . persp-list-buffers)
  :custom
  (persp-mode-prefix-key (kbd "C-x x"))
  :init
  (setq persp-initial-frame-name "master")
  (persp-mode))

;; Org keybindings
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; Define a function and then call a hook to enable some settings whenenver org-mode is loaded
(defun org-mode-setup ()
  ;;(org-indent-mode)
  ;;(variable-pitch-mode 1)
  (visual-line-mode 1))

(add-hook 'org-mode-hook 'org-mode-setup)

;; Start org mode folded
(setq org-startup-folded nil)

;; Set org directory
(setq org-directory "~/docs/org-roam")

;; Use org-indent-mode by default
(setq org-startup-indented t)

;; Set org-agenda files
(setq org-agenda-files (expand-file-name "~/docs/agenda.txt" org-directory))

;; org-agenda window settings
(setq org-agenda-window-setup 'only-window) ; open the agenda full screen
(setq org-agenda-restore-windows-after-quit t) ; restore the previous window arrangement after quitting

;; Include archived trees in the agenda view
;; Used to have this to nil. Now it's recommended to use "v" in the agenda view to include archived items.
(setq org-agenda-skip-archived-trees t)

;; When using (C-c C-x C-a), archive to the sibling instead of a separate file.
(setq org-archive-default-command 'org-archive-to-archive-sibling)

;; Allow refiling to other agenda files 1 level deep
(setq org-refile-targets '((nil :maxlevel . 1)
                           (org-agenda-files :maxlevel . 1)))

;; Save Org buffers after refiling!
(advice-add 'org-refile :after 'org-save-all-org-buffers)

;; Logging
(setq org-log-done 'time)
(setq org-log-into-drawer t)
(setq org-clock-into-drawer "CLOCKING")
(setq org-log-note-clock-out nil)
(setq org-log-redeadline 'time)
(setq org-log-reschedule 'time)
(setq org-read-date-prefer-future 'time)

;; Set todo sequence
(setq org-todo-keywords
    '((sequence "TODO(t)" "ACT(a)" "NEXT(n)" "BACKLOG(b)" "WAIT(w@/!)" "ONG(o)" "|" "DONE(d!)" "SKIP(k!)")))

;; Configure custom agenda views
(setq org-agenda-custom-commands
      '(("D" "Week Dashboard"
         ((agenda "" ((org-deadline-warning-days 7)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-overriding-header "Next Tasks")))))

        ("d" "Day Dashboard"
         ((agenda "" ((org-deadline-warning-days 7)(org-agenda-span 1)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-overriding-header "Next Tasks")))))

        ("H" "Home Week Dashboard"
         ((agenda "" ((org-agenda-tag-filter-preset '("-zapier"))(org-deadline-warning-days 7)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-tag-filter-preset '("-zapier"))(org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-tag-filter-preset '("-zapier"))(org-agenda-overriding-header "Next Tasks")))))

        ("h" "Home Day Dashboard"
         ((agenda "" ((org-agenda-tag-filter-preset '("-zapier"))(org-deadline-warning-days 7)(org-agenda-span 1)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-tag-filter-preset '("-zapier"))(org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-tag-filter-preset '("-zapier"))(org-agenda-overriding-header "Next Tasks")))))

        ("Z" "Zapier Week Dashboard"
         ((agenda "" ((org-agenda-tag-filter-preset '("+zapier"))(org-deadline-warning-days 7)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-tag-filter-preset '("+zapier"))(org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-tag-filter-preset '("+zapier"))(org-agenda-overriding-header "Next Tasks")))))

        ("z" "Zapier Day Dashboard"
         ((agenda "" ((org-agenda-tag-filter-preset '("+zapier"))(org-deadline-warning-days 7)(org-agenda-span 1)))
          (todo "ONG|ACT"
                ((org-agenda-overriding-header "Ongoing/Active Tasks")))
          (todo "WAIT"
                ((org-agenda-tag-filter-preset '("+zapier"))(org-agenda-overriding-header "Waiting Tasks")))
          (todo "NEXT"
                ((org-agenda-tag-filter-preset '("+zapier"))(org-agenda-overriding-header "Next Tasks")))))))


;; Configure org tags (C-c C-q)
(setq org-tag-alist
      '((:startgroup)
        ; Put mutually exclusive tags here
        (:endgroup)
        ("home" . ?h)
        ("habit" . ?H)
        ("tech" . ?t)
        ("financial" . ?f)
        ("zapier" . ?z)
        ("gigs" . ?g)
        ("ozostudio" . ?o)
        ("parents" . ?p)
        ("checkout" . ?c)
        ("shopping" . ?s)
        ("connections" . ?C)
        ("someday" . ?S)
        ("emacs" . ?e)
        ("recurring" . ?r)))

;; Add some modules
(with-eval-after-load 'org
  (add-to-list 'org-modules 'org-habit t))

;; Org Contacts
(use-package org-contacts
  :ensure t
  :after org
  :custom (org-contacts-files '("~/docs/org-roam/contacts.org")))

;; Org Contacts
(use-package org-vcard
  :ensure t
  :after org)

;; Org capture
(use-package org-capture
  :ensure nil
  :after ORG)

(defvar my/org-contacts-template "* %(org-contacts-template-name)
    :PROPERTIES:
    :ADDRESS: %^{9 Birch Lane, Verona, NJ 07044}
    :EMAIL: %(org-contacts-template-email)
    :MOBILE: tel:%^{973.464.5242}
    :NOTE: %^{NOTE}
    :END:" "Template for org-contacts.")

(setq org-capture-templates
      `(("c" "Contact" entry (file+headline "~/docs/org-roam/contacts.org" "Misc"),
         my/org-contacts-template :empty-lines 1)

        ("t" "Task")
        ("tt" "Task" entry (file+olp "~/docs/org-roam/todos.org" "Inbox")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tc" "Check Out" entry (file+headline "~/docs/org-roam/todos.org" "Check Out")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} Check Out %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("th" "Home" entry (file+headline "~/docs/org-roam/todos.org" "Home")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tT" "Tech" entry (file+headline "~/docs/org-roam/todos.org" "Tech")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tf" "Financial" entry (file+headline "~/docs/org-roam/todos.org" "Financial")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tC" "Connections" entry (file+headline "~/docs/org-roam/todos.org" "Connections")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("ts" "Shopping" entry (file+headline "~/docs/org-roam/todos.org" "Shopping")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} Buy %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tp" "Parents" entry (file+headline "~/docs/org-roam/todos.org" "Parents")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tg" "Gigs" entry (file+headline "~/docs/org-roam/todos.org" "Gigs")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("to" "OzoStudio" entry (file+headline "~/docs/org-roam/todos.org" "OzoStudio")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tz" "Zapier" entry (file+headline "~/docs/org-roam/todos.org" "Zapier")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("tS" "Someday" entry (file+headline "~/docs/org-roam/todos.org" "Someday")
         "* %^{State|TODO|ACT|NEXT|BACKLOG|WAIT|ONG} %?\n:PROPERTIES:\n:CAPTURED: %U\n:END:\n%i" :empty-lines 1)

        ("m" "Metrics")
        ("mw" "Weight" table-line (file "~/docs/org-roam/weight.org")
         "| %U | %^{Weight} | %^{Note} |" :kill-buffer t)

        ("o" "Mouthpiece")
        ("o1" "One-Piece" table-line (file "~/docs/org-roam/my_mouthpieces.org")
         "| %^{Make} | %^{Model} | one-piece | %^{Finish||silver plated|gold plated|brass|nickel|stainless|bronze|plastic} | | %^{Notes} | |" :kill-buffer t)

        ("o2" "Two-Piece" table-line (file "~/docs/org-roam/my_mouthpieces.org")
         "| %^{Make} | %^{Model} | two-piece | %^{Finish||silver plated|gold plated|brass|nickel|stainless|bronze|plastic} | %^{Threads||standard|metric|other} | %^{Notes} | |" :kill-buffer t)

        ("or" "Rim" table-line (file "~/docs/org-roam/my_mouthpieces.org")
         "| %^{Make} | %^{Model} | rim | %^{Finish||silver plated|gold plated|brass|nickel|stainless|bronze|plastic} | %^{Threads||standard|metric|other} | %^{Notes} | |" :kill-buffer t)

        ("oc" "Cup" table-line (file "~/docs/org-roam/my_mouthpieces.org")
         "| %^{Make} | %^{Model} | cup | %^{Finish||silver plated|gold plated|brass|nickel|stainless|bronze|plastic} | %^{Threads||standard|metric|other} | %^{Notes} | |" :kill-buffer t)))

;; Default org capture file
(setq org-default-notes-file (concat org-directory "~/docs/inbox.txt"))

;; Prevent org-capture from saving bookmarks
(setq org-bookmarks-names-plist '())
(setq org-capture-bookmark nil)

;;Enable certain languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (js . t)
   (shell . t)))

;; Skip confirming when evaluating source blocks
(setq org-confirm-babel-evaluate nil)

;; This is needed as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src elisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("pyo" . "src python :results output"))
(add-to-list 'org-structure-template-alist '("js" . "src js"))
(add-to-list 'org-structure-template-alist '("jso" . "src js :results output"))
(add-to-list 'org-structure-template-alist '("html" . "src html"))
(add-to-list 'org-structure-template-alist '("css" . "src css"))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/docs/org-roam")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
      :unnarrowed t)
     ("p" "project" plain
      "%?"
      :target (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n#+category: ${title}\n#+filetags: project\n")
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%I:%M %p>: %?"
      :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 ("C-c n I" . org-roam-node-insert-immediate)
	 :map org-mode-map
	 ("C-M-i"    . completion-at-point)
	 :map org-roam-dailies-map
	 ("Y" . org-roam-dailies-capture-yesterday)
	 ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (setq org-roam-node-display-template ;; Add filetag view to vertico when finding nodes
    (concat "${title:*} "
	    (propertize "${tags:30}" 'face 'org-tag)))
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
	(org-roam-capture-templates (list (append (car org-roam-capture-templates)
						  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

;; Install the package
(pcase system-type
  ('gnu/linux (use-package mu4e
                :ensure nil))
  ('darwin (use-package mu4e
             :ensure nil
             :load-path "/opt/homebrew/share/emacs/site-lisp/mu/mu4e/"))) ;; macOS Only

;; Because we installed mu with homebrew (macOS Only)
(pcase system-type
  ('darwin (setq mu4e-mu-binary (executable-find "/opt/homebrew/bin/mu"))))

;; GPG binary (macOS Only)
(pcase system-type
  ('darwin (require 'epa-file)
           (setq epg-gpg-program "/opt/homebrew/bin/gpg")
           (epa-file-enable)))

;; set the default mail user agent
(setq mail-user-agent 'mu4e-user-agent)

;; This is set to 't' to avoid mail syncing issues when using mbsync
(setq mu4e-change-filenames-when-moving t)

;; Prevent space bar from moving to next message
(setq mu4e-view-scroll-to-next nil)

;; Display more messages in each mailbox if possible
(setq mu4e-headers-results-limit 5000)

;; Disable auto-save-mode when composing email to eliminate extra drafts
(add-hook 'mu4e-compose-mode-hook #'(lambda () (auto-save-mode -1)))

;; Don't autocomplete email addresses using mu's built in autocompletion (we'll use org-contacts for this)
(setq mu4e-compose-complete-addresses nil)

;; Always show the plaintext version of emails over the HTML version
;; (setq mu4e-view-html-plaintext-ratio-heuristic most-positive-fixnum)

;; Prefer the plain text version of emails
(with-eval-after-load "mm-decode"
  (add-to-list 'mm-discouraged-alternatives "text/html")
  (add-to-list 'mm-discouraged-alternatives "text/richtext"))

;; Inhibit images from loading
(setq gnus-inhibit-images t)

;; Turn off threading by default
(setq mu4e-headers-show-threads nil)

;; Turn off automatic mark as read (use ! instead)
;; (setq mu4e-view-auto-mark-as-read nil)

;; Set the download directory for attachments
(pcase system-type
  ('gnu/linux (setq mu4e-attachment-dir  "~/dls")) ;; Linux
  ('darwin (setq mu4e-attachment-dir  "~/Downloads"))) ;; macOS

;; Refresh mail using isync every 10 minutes
(setq mu4e-update-interval (* 1 60))
(pcase system-type
  ('gnu/linux (setq mu4e-get-mail-command "mbsync -a -c ~/.config/mbsyncrc")) ;; Linux
  ('darwin (setq mu4e-get-mail-command "/opt/homebrew/bin/mbsync -a -c ~/.config/mbsyncrc"))) ;; macOS
(setq mu4e-maildir "~/.local/share/mail")
(setq mu4e-context-policy 'pick-first)

;; Configure how to send mails
;; Note: .authinfo.gpg is used by default for authentication.
;; You can customize the variable auth-sources
(setq message-send-mail-function 'smtpmail-send-it)

;; Make sure plain text emails flow correctly for recipients
(setq mu4e-compose-format-flowed t)

;; Turn off use-hard-newlines - this helps the flow in certain clients aka Gmail
(add-hook 'mu4e-compose-mode-hook (lambda () (use-hard-newlines -1)))

;; Compose a signature
(setq mu4e-compose-signature "Aleks Ozolins\naleks@ozolins.xyz\nm:973.464.5242")

;; Do not include related messages
(setq mu4e-headers-include-related nil)

;; Use org-contacts
(setq mu4e-org-contacts-file  "~/docs/org-roam/contacts.org")
;; BELOW DISABLED AS I THINK IT'S BETTER TO JUST USE ORG CAPTURE FOR REFILING
;;(add-to-list 'mu4e-headers-actions
;;  '("org-contact-add" . mu4e-action-add-org-contact) t)
;;(add-to-list 'mu4e-view-actions
;;  '("org-contact-add" . mu4e-action-add-org-contact) t)

(setq mu4e-maildir-shortcuts
      '(("/aleks@ozolins.xyz/Inbox"           . ?i)
	("/aleks@ozolins.xyz/Sent Items"      . ?s)
	("/aleks@ozolins.xyz/Drafts"          . ?d)
	("/aleks@ozolins.xyz/Archive"         . ?a)
	("/aleks@ozolins.xyz/Trash"           . ?t)
	("/aleks@ozolins.xyz/Admin"           . ?n)
	("/aleks@ozolins.xyz/Admin-Archive"   . ?N)
	("/aleks@ozolins.xyz/Receipts"        . ?r)
	("/aleks@ozolins.xyz/Parents"         . ?p)
	("/aleks@ozolins.xyz/Sus"             . ?u)
	("/aleks@ozolins.xyz/Spam?"           . ?S)))

(setq mu4e-contexts
      (list
       ;; aleks@ozolins.xyz account
       (make-mu4e-context
	:name "1-aleks@ozolins.xyz"
	:match-func
	(lambda (msg)
	  (when msg
	    (string-prefix-p "/aleks@ozolins.xyz" (mu4e-message-field msg :maildir))))
	:vars '((user-mail-address     . "aleks@ozolins.xyz")
		(user-full-name        . "Aleks Ozolins")
		(smtpmail-smtp-server  . "smtp.mailfence.com")
		(smtpmail-smtp-service . 465)
		(smtpmail-stream-type  . ssl)
		(mu4e-drafts-folder    . "/aleks@ozolins.xyz/Drafts")
		(mu4e-sent-folder      . "/aleks@ozolins.xyz/Sent Items")
		(mu4e-refile-folder    . "/aleks@ozolins.xyz/Archive")
		(mu4e-trash-folder     . "/aleks@ozolins.xyz/Trash")))
       ;; aleks.admin@ozolins.xyz account
       (make-mu4e-context
	:name "2-aleks.admin@ozolins.xyz"
	:match-func
	(lambda (msg)
	  (when msg
	    (string-prefix-p "/aleks@ozolins.xyz" (mu4e-message-field msg :maildir))))
	:vars '((user-mail-address     . "aleks.admin@ozolins.xyz")
		(user-full-name        . "Aleks Ozolins")
		(smtpmail-smtp-server  . "smtp.mailfence.com")
		(smtpmail-smtp-service . 465)
		(smtpmail-stream-type  . ssl)
		(mu4e-drafts-folder    . "/aleks@ozolins.xyz/Drafts")
		(mu4e-sent-folder      . "/aleks@ozolins.xyz/Sent Items")
		(mu4e-refile-folder    . "/aleks@ozolins.xyz/Archive")
		(mu4e-trash-folder     . "/aleks@ozolins.xyz/Trash")))))

;; Set the compose context policy
(setq mu4e-compose-context-policy 'pick-first)

;; Allow attaching files from within dired with C-c RET C-a
(require 'gnus-dired)

;; make the `gnus-dired-mail-buffers' function also work on
;; message-mode derived modes, such as mu4e-compose-mode
(defun gnus-dired-mail-buffers ()
  "Return a list of active message buffers."
  (let (buffers)
    (save-current-buffer
      (dolist (buffer (buffer-list t))
        (set-buffer buffer)
        (when (and (derived-mode-p 'message-mode)
                   (null message-sent-message-via))
          (push (buffer-name buffer) buffers))))
    (nreverse buffers)))

(setq gnus-dired-mail-mode 'mu4e-user-agent)
(add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)

;; Run mu4e in the background to sync mail periodically - only in Linux
(when (eq system-type 'gnu/linux)
  (mu4e t))

;; Initial configuration
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "s-L")         ;; Note: The original binding was supposed to be "s-l" but for the moment, that's take up with DWM
  :config
  (lsp-enable-which-key-integration t))

;; Config for Python Mode -- It comes with Emacs so it doesn't have to be installed
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred))

(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
