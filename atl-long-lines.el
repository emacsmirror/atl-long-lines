;;; atl-long-lines.el --- Automatically truncate lines for long lines  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Shen, Jen-Chieh
;; Created date 2020-08-01 14:57:57

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Automatically truncate lines for long lines.
;; Keyword: truncate lines auto long
;; Version: 0.1.2
;; Package-Requires: ((emacs "24.3"))
;; URL: https://github.com/jcs-elpa/atl-long-lines

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Automatically truncate lines for long lines.
;;

;;; Code:

(require 'cl-lib)

(defgroup atl-long-lines nil
  "Automatically truncate lines for long lines."
  :prefix "atl-long-lines-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/jcs-elpa/atl-long-lines"))

(defcustom atl-long-lines-delay 0.4
  "Seconds to delay before trigger function `toggle-truncate-lines'."
  :type 'float
  :group 'atl-long-lines)

(defvar atl-long-lines--timer nil
  "Timer use for function `run-with-idle-timer'.")

;;; Util

(defun atl-long-lines--end-line-column ()
  "Get the column at the end of line."
  (save-excursion (goto-char (line-end-position)) (current-column)))

(defmacro atl-long-lines--mute-apply (&rest body)
  "Execute BODY without message."
  (declare (indent 0) (debug t))
  `(let ((message-log-max nil))
     (with-temp-message (or (current-message) nil)
       (let ((inhibit-message t)) (progn ,@body)))))

;;; Core

(defun atl-long-lines-do-toggle ()
  "Do toggle truncate lines at current position."
  (atl-long-lines--mute-apply
    (if (< (window-width) (atl-long-lines--end-line-column))
        (toggle-truncate-lines -1)
      (toggle-truncate-lines 1))))

(defun atl-long-lines--start-timer ()
  "Start the idle timer for activation."
  (when (timerp atl-long-lines--timer) (cancel-timer atl-long-lines--timer))
  (setq atl-long-lines--timer (run-with-idle-timer
                               atl-long-lines-delay nil
                               #'atl-long-lines-do-toggle)))

(defun atl-long-lines--enable ()
  "Enable 'atl-long-lines-mode'."
  (add-hook 'post-command-hook 'atl-long-lines--start-timer nil t))

(defun atl-long-lines--disable ()
  "Disable 'atl-long-lines-mode'."
  (remove-hook 'post-command-hook 'atl-long-lines--start-timer t))

;;;###autoload
(define-minor-mode atl-long-lines-mode
  "Minor mode 'atl-long-lines-mode'."
  :lighter " ATL-LL"
  :group atl-long-lines
  (if atl-long-lines-mode (atl-long-lines--enable) (atl-long-lines--disable)))

(defun atl-long-lines--turn-on-atl-long-lines-mode ()
  "Turn on the 'atl-long-lines-mode'."
  (atl-long-lines-mode 1))

;;;###autoload
(define-globalized-minor-mode global-atl-long-lines-mode
  atl-long-lines-mode atl-long-lines--turn-on-atl-long-lines-mode
  :require 'atl-long-lines)

(provide 'atl-long-lines)
;;; atl-long-lines.el ends here
