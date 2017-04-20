### Handling mirror Git and Hg repositories for PicoLisp project

#### Setup
1. Add 'tgz', 'hg-repo', 'git-repo' subdirectories
2. Clone your Mercurial repository into 'hg-repo'
3. Clone your Git repository into 'git-repo'
4. Add such line to crontab:
```
10 0,6,12,18 * * * cd <path-to-pil-repo> && <path-to-pil>/pil main.l -updaterepo -bye 2>&1 >> log/pil-repo
``` 
