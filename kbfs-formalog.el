(defvar kbfs-formalog-agent-name "KBFS-Agent1")

(global-set-key "\C-c\C-k\C-vKF" 'kbfs-formalog-quick-start)

(global-set-key "\C-ckfe" 'kbfs-formalog-edit-kbfs-formalog-file)
(global-set-key "\C-ckfgl" 'kbfs-formalog-action-get-line)
(global-set-key "\C-ckfws" 'kbfs-formalog-set-windows)
(global-set-key "\C-ckfs" 'kbfs-formalog-quick-start)
(global-set-key "\C-ckfr" 'kbfs-formalog-restart)
(global-set-key "\C-ckfk" 'kbfs-formalog-kill)
(global-set-key "\C-ckfc" 'kbfs-formalog-clear-context)

(defvar kbfs-formalog-default-context "Org::FRDCSA::KBFS")

(defun kbfs-formalog-issue-command (query)
 ""
 (interactive)
 (uea-query-agent-raw nil kbfs-formalog-agent-name
  (freekbs2-util-data-dumper
   (list
    (cons "_DoNotLog" 1)
    (cons "Eval" query)))))

(defun kbfs-formalog-action-get-line ()
 ""
 (interactive)
 (see (kbfs-formalog-issue-command
  (list "_prolog_list"
   (list "_prolog_list" 'var-Result)
   (list "emacsCommand"
    (list "_prolog_list" "kmax-get-line")
    'var-Result)))))

(defun kbfs-formalog-quick-start ()
 ""
 (interactive)
 
 (kbfs-formalog)
 (kbfs-formalog-fix-windows)
 (kbfs-formalog-select-windows))

(defun kbfs-formalog (&optional load-command)
 ""
 (interactive)
 (if (kbfs-formalog-running-p)
  (error "ERROR: KBFS Already running.")
  (progn
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/kbfs-formalog/scripts" "*KBFS*")
   (sit-for 3.0)
   (ushell)
   (sit-for 1.0)
   (pop-to-buffer "*KBFS*")
   (insert (or load-command "./kbfs-start -u"))
   (comint-send-input)
   (sit-for 3.0)
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/kbfs-formalog/scripts && ./kbfs-start-repl" "*KBFS-REPL*" nil 'formalog-repl-mode)
   (setq formalog-agent kbfs-formalog-agent-name)
   (sit-for 1.0))))

(defun kbfs-formalog-set-windows ()
 ""
 (interactive)
 (kbfs-formalog-fix-windows)
 (kbfs-formalog-select-windows))

(defun kbfs-formalog-fix-windows ()
 ""
 (interactive)
 (delete-other-windows)
 (split-window-vertically)
 (split-window-horizontally)
 (other-window 2)
 (split-window-horizontally)
 (other-window -2))

(defun kbfs-formalog-select-windows ()
 ""
 (interactive)
 (switch-to-buffer "*KBFS*")
 (other-window 1)
 (switch-to-buffer "*ushell*")
 (other-window 1)
 (switch-to-buffer "*KBFS-REPL*")
 (other-window 1)
 (ffap "/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/kbfs_formalog.pl"))

(defun kbfs-formalog-restart ()
 ""
 (interactive)
 (if (yes-or-no-p "Restart KBFS? ")
  (progn
   (kbfs-formalog-kill)
   (kbfs-formalog-quick-start))))

(defun kbfs-formalog-kill ()
 ""
 (interactive)
 (flp-kill-processes)
 (shell-command "killall -9 \"kbfs-start\"")
 (shell-command "killall -9 \"kbfs-start-repl\"")
 (shell-command "killall-grep KBFS-Agent1")
 (kmax-kill-buffer-no-ask (get-buffer "*KBFS*"))
 (kmax-kill-buffer-no-ask (get-buffer "*KBFS-REPL*"))
 ;; (kmax-kill-buffer-no-ask (get-buffer "*ushell*"))
 (kbfs-formalog-running-p))

(defun kbfs-formalog-running-p ()
 (interactive)
 (setq kbfs-formalog-running-tmp t)
 (let* ((matches nil)
	(processes (split-string (shell-command-to-string "ps auxwww") "\n"))
	(failed nil))
  (mapcar 
   (lambda (process)
    (if (not (kmax-util-non-empty-list-p (kmax-grep-v-list-regexp (kmax-grep-list-regexp processes process) "grep")))
     (progn
      (see process 0.0)
      (setq kbfs-formalog-running-tmp nil)
      (push process failed))))
   kbfs-formalog-process-patterns)
  (setq kbfs-formalog-running kbfs-formalog-running-tmp)
  (if (kmax-util-non-empty-list-p failed)
   (see failed 0.1))
  kbfs-formalog-running))

(defun kbfs-formalog-clear-context (&optional context-arg)
 (interactive)
 (let* ((context (or context-arg kbfs-formalog-default-context)))
  (if (yes-or-no-p (concat "Clear Context <" context ">?: "))
   (freekbs2-clear-context context))))

(defvar kbfs-formalog-process-patterns
 (list
  "kbfs-start"
  "kbfs-start-repl"
  "/var/lib/myfrdcsa/codebases/internal/unilang/unilang-client"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/kbs2-server"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/server.pl"
  ))

(defun kbfs-formalog-eval-function-and-map-to-integer (expression)
 ""
 (interactive)
 (kbfs-formalog-serpro-map-object-to-integer
  (funcall (car expression) (cdr expression))))

(defun kbfs-formalog-serpro-map-object-to-integer (object)
 ""
 (interactive)
 (see object)
 (see (formalog-query (list 'var-integer) (list "prolog2TermAlgebra" object 'var-integer))))

(defun kbfs-formalog-serpro-map-integer-to-object (integer)
 ""
 (interactive)
 (see integer)
 (see (formalog-query (list 'var-integer) (list "termAlgebra2prolog" object 'var-integer))))

(defun kbfs-formalog-edit-kbfs-formalog-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/kbfs-formalog.el"))

;; emacsCommand(['kmax-get-line'],Result). 
;; (see (freekbs2-importexport-convert (list (list 'var-Result) (list "emacsCommand" (list "kmax-get-line") 'var-Result)) "Interlingua" "Perl String"))

;; "Eval" => {
;;           "_prolog_list" => {
;;                             "_prolog_list" => [
;;                                               \*{'::?Result'}
;;                                             ],
;;                             "emacsCommand" => [
;;                                               [
;;                                                 "_prolog_list",
;;                                                 "kmax-get-line"
;;                                               ],
;;                                               \*{'::?Result'}
;;                                             ]
;;                           }
;;         },

;; "Eval" => [
;;           [
;;             "_prolog_list",
;;             [
;;               "_prolog_list",
;;               \*{'::?Result'}
;;             ],
;;             [
;;               "emacsCommand",
;;               [
;;                 "_prolog_list",
;; 	        "kmax-get-line",
;;               ],
;;               \*{'::?Result'}
;;             ]
;;           ]
;;         ],


;; <message>
;;   <id>1</id>
;;   <sender>KBFS-Agent1</sender>
;;   <receiver>Emacs-Client</receiver>
;;   <date>Sat Apr  1 10:16:28 CDT 2017</date>
;;   <contents>eval (run-in-shell \"ls\")</contents>
;;   <data>$VAR1 = {
;;           '_DoNotLog' => 1,
;;           '_TransactionSequence' => 0,
;;           '_TransactionID' => '0.667300679865178'
;;         };
;;   </data>
;; </message>

;; (see (eval (read "(run-in-shell \"ls\")")))
;; (see (cons "Result" nil ))

;; (see (freekbs2-util-data-dumper
;;      (list
;;       (cons "_DoNotLog" 1)
;;       (cons "Result" nil)
;;       )
;;       ))

;; ;; (see '(("_DoNotLog" . 1) ("Result")))
;; ;; (see '(("Result"))

;; (freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))
;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (see '(("_DoNotLog" . 1) ("Result")))
;; (see '(("Result")))
;; (see '(("_DoNotLog" . 1)))

;; (join ", " (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '("Result")))


;; (kbfs-formalog-eval-function-and-map-to-integer (list 'buffer-name))




;;;;;;;;;;;;;;;; FIX Academician to use KBFS-Formalog
;; see /var/lib/myfrdcsa/codebases/minor/academician/academician-kbfs.el

(defun kbfs-formalog-retrieve-file-id (file)
 (let* ((chased-original-file (kmax-chase file))
	(results
	 (formalog-query
	  (list 'var-FileIDs)
	  (list "retrieveFileIDs" chased-original-file 'var-FileIDs)
	  nil "KBFS-Agent1")))
  (see (car (cdadar results)))))

;; (defun academician-get-title-of-publication (&optional overwrite)
;;  ""
;;  (interactive "P")
;;  (let* ((current-cache-dir (doc-view--current-cache-dir))
;; 	(current-document-hash (gethash current-cache-dir academician-parscit-hash))
;; 	(title0 (gethash current-cache-dir academician-title-override-hash)))
;;   (if (non-nil title0)
;;    title0
;;    (progn
;;     (academician-process-with-parscit overwrite)
;;     (let* ((title1
;; 	    (progn
;; 	     ;; (see current-document-hash)
;; 	     (cdr (assoc "content" 
;; 		   (cdr (assoc "title" 
;; 			 (cdr (assoc "variant" 
;; 			       (cdr (assoc "ParsHed" 
;; 				     (cdr (assoc "algorithm" current-document-hash))))))))))))
;; 	   (title2
;; 	    (cdr (assoc "content" 
;; 		  (cdr (assoc "title" 
;; 			(cdr (assoc "variant" 
;; 			      (cdr (assoc "SectLabel" 
;; 				    (cdr (assoc "algorithm" current-document-hash)))))))))))
;; 	   (title 
;; 	    (chomp (or title1 title2))))
;;      (if (not (equal title "nil"))
;;       title
;;       (academician-override-title)))))))

;; (defun academician-process-with-parscit (&optional overwrite)
;;  "Take the document in the current buffer, process the text of it
;;  and return the citations, allowing the user to add the citations
;;  to the list of papers to at-least-skim"
;;  (interactive "P")
;;  (if (derived-mode-p 'doc-view-mode)
;;   (if doc-view--current-converter-processes
;;    (message "Academician: DocView: please wait till conversion finished.")
;;    (let ((academician-current-buffer (current-buffer)))
;;     (academician-doc-view-open-text-without-switch-to-buffer)
;;     (while (not academician-converted-to-text)
;;      (sit-for 0.1))
;;     (let* ((filename (buffer-file-name))
;; 	   (current-cache-dir (doc-view--current-cache-dir))
;; 	   (txt (expand-file-name "doc.txt" current-cache-dir)))
;;      (if (equal "fail" (gethash current-cache-dir academician-parscit-hash "fail"))
;;       (progn
;;        ;; check to see if there is a cached version of the parscit data
;;        (if (file-readable-p txt)
;; 	(let* ((command
;; 		(concat 
;; 		 "/var/lib/myfrdcsa/codebases/minor/academician/scripts/process-parscit-results.pl -f "
;; 		 (shell-quote-argument filename)
;; 		 (if overwrite " -o " "")
;; 		 " -t "
;; 		 (shell-quote-argument txt)
;; 		 " | grep -vE \"^(File is |Processing with ParsCit: )\""
;; 		 ))
;; 	       (debug-1 (if academician-debug (see (list "command: " command))))
;; 	       (result (progn
;; 			(message (concat "Processing with ParsCit: " txt " ..."))
;; 			(shell-command-to-string command)
;; 			)))
;; 	 (if academician-debug (see (list "result: " result)))
;; 	 (ignore-errors
;; 	  (puthash current-cache-dir (eval (read result)) academician-parscit-hash))
;; 	 )
;; 	(message (concat "File not readable: " txt)))
;;        ;; (freekbs2-assert-formula (list "has-title") academician-default-context)
;;        )))))))
