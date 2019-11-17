(setq
   *TgzUrl "http://software-lab.de/picoLisp.tgz"
   *TgzDir "tgz/"
   *Tgz (pack *TgzDir "picoLisp.tgz")
   *Curl (list 'curl '-z *Tgz '-o *Tgz '-w "%{http_code}" '--silent *TgzUrl) )

# TODO: email me
(de _alert (Msg)
   NIL )

#(de check_setup ()
#   (prinl "TODO: check prereq") )

(de _backup_tgz (Tgz)
   (when (info Tgz)
      (let BackupTgz
         (pack Tgz
            "." (dat$ (cadr @))
            "-" (pack (mapcar '((X) (pad 2 X)) (time (cddr @)))))
         (unless (info BackupTgz)
            (call "cp" "-a" Tgz BackupTgz) )
         T ) ) )

(de _download (Url DstFile)
   (let (DstDir (or (dirname DstFile) "./")
      Curl (list 'curl '-R '-z DstFile '-o DstFile '-w "%{http_code}" '--silent Url) )
      (ifn (=T (car (info DstDir)))
         (nil (log "Directory '@1' doesn't exist" DstDir))
         (log "Downloading @1..." Url)
         (case (in Curl (read))
            (200 (log "200 OK [@1 bytes]" (car (info DstFile))) T)
            (304 (log "304 Not modified") NIL)
            (T (logerr "@1 download failed" @) (_alert) NIL) ) ) ) )

#(de _mkdir (D)
#   (or (call "mkdir" D)
#      (nil (logerr "Can't create directory '@1'" D)) ) )

#(de _rmdir (D)
#   # TODO: strip trailing slash
#   (or
#      (not (info D))
#      (call "rm" "-r" D)
#      (nil (logerr "Can't delete directory '@1'" D)) ) )

(de hg_clean_repo ()
   (call "find" "hg-repo/" "-depth" "-mindepth" 1 "!" "-path" "hg-repo/.hg*" "-delete") )

(de git_clean_repo ()
   (call "find" "git-repo/" "-depth" "-mindepth" 1 "!" "-path" "git-repo/.git*" "-delete") )

(de _extract (TgzFile DstDir)
   (or (call 'tar '-C DstDir '--strip-components=1 '-xzf TgzFile)
      (nil (logerr "'@1' extraction failed" TgzFile)) ) )

(de log @
   (out NIL
      (prinl (stamp) " [INFO] " (pass text)) ) )

(de logerr @
   (out NIL
      (prinl (stamp) " [ERROR] " (pass text)) ) )

(de _get_version (WorkDir)
   (load (pack WorkDir "src64/version.l"))
   (setq *MsgVersion (pack "v" (glue "." *Version))) )

(de hg_commit ()
   (if (call 'hg 'commit '--cwd "hg-repo" '-A '-m *MsgVersion)
      (t (log "hg commit -m '@1'" *MsgVersion))
      (nil (logerr "hg  commit -m '@1' failed" *MsgVersion)) ) )

(de hg_push ()
   (if (call "hg" "push" "--cwd" "hg-repo/")
      (t (log "hg push succeeded"))
      (nil (logerr "hg push failed")) ) )

(de git @
   (pass 'call "git" "-C" "git-repo/") )

(de git_commit ()
   (or
      (and
         (git "add" "-A")
         (git "commit" "-q" "-uno" "-m" *MsgVersion)
         (git "tag" *MsgVersion)
         (t (log "git commit -m '@1'" *MsgVersion)) )
      (nil (logerr "git commit -m '@1' failed" *MsgVersion)) ) )

(de git_push ()
   (or
      (git "push")
      (nil (logerr "git push failed")) ) )

(de add_misc_files ()
   (call "cp" "-a" "add_files/.github" "git-repo/") )

(de updaterepo ()
   (and
      (_backup_tgz *Tgz)
      (_download *TgzUrl *Tgz)
      # Git
      (or
         (and
            (git_clean_repo)
            # ensure that we are on 'dev' branch,
            # because I plan to track also named releases on 'master' branch
            (git "checkout" "dev" "-q")
            (_extract *Tgz "git-repo/")
            (_get_version "git-repo/")
            (add_misc_files)
            (git_commit)
            (git_push)
         )
         (t (_alert "git failed")) )
      # Mercurial
      (or
         (and
            (hg_clean_repo)
            (_extract *Tgz "hg-repo/")
            (hg_commit)
            (hg_push)
         )
         (t (_alert "hg failed")) ) ) )

#(de updaterepo ()
#   (and
#      (_download)
#      (_extract)
#      (_commit)
#      (_push) ) )

# vi:et:ts=3:sw=3
