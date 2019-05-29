# bash-utils

## Apparix

Directory bookmarking system. It used to be implemented in C, shipped with bash
wrapper functions and completion code. This is now legacy, and if you want it
you should go and get it from an old commit
(https://github.com/micans/bash-utils/tree/b825f656bc1092613d74d30ce5a1efc644d37948).

The new pure shell implementation is in `.bourne-apparish`. This works with bash
and zsh, providing tab completion for both. The zsh version goes through the
native zsh completion mechanism for files, so it will complete exactly like you
expect it to.

The bash version implements its own file completions. It has an extra
sophisticated mode called Gödel completion, which quotes directories and can
still complete on subdirectories. To disable this mode, set the variable
`$BERTRAND_RUSSEL` to a nonempty string.

There may be some weird behaviour if you have file names with colons in. This
is because of `$COMP_WORDBREAKS`: see
https://stackoverflow.com/questions/2805412/bash-completion-for-maven-escapes-colon.
You may have to manually override this variable. If you do, check that it
doesn't get re-overriden by any other scripts. (`git-completion` seems to
forcefully add a colon, for example.)

There is also a reference bash prompt that can talk to apparix, if you've got it
set up, in `.bashpromptrc`.

If you're a user of `bash-completion`
(requiring Bash >= 4.1) you may be interested in the compatibility-breaking
branch https://github.com/goedel-gang/bash-utils/tree/twenty-first-century,
which just uses `_filedir`.

This fork allows itself to be a little more extravagant, and also has an
alternative zsh apparix that wraps directory hashing, automatically providing
bookmarks everywhere that zsh does file expansion. It also has some more prompts
for Zsh and packages some demo shells and screenshots.

## bash-myutils

Small functions that I use in `.bash-myutils`.

## bash-workutils

Space/time bash functions in `.bash-workutils`. Most of these will lead to a lot
of disk access, use with care.


```
--- ls_bigold
  List directories up to a certain depth, ordered by disk usage,
  with the number of days since last modified.
  Argument: directory depth.
  Example:
  ls_bigold 2
  NOTE: in a project/team root directory this may take some time and
  tax the file system. Perhaps best to save the output in a file.
  CAVEAT subdirectories of a directory may have changed. Use as guide!
  USEFUL order the output by the third column to group directories together,
    e.g. ls_bigold 2 > out.bigold; sort -k 3 out.bigold

--- ls_mouldy
  Find directories left untouched for longer than first argument (in days)
  up to a depth of second argument.
  Example:
  ls_mouldy 183 3
  CAVEAT subdirectories of a directory may have changed. Use as guide!

--- ls_size_any
  List all regular files recursively and sort by human-readable size.
  First optional argument:   lower bound e.g. 10M or 16k, or 0k
  Second optional argument:  upper bound e.g. 4k (useful for small files)
  Example:
  ls_size_any 10M     # find files larger than 10M
  ls_size_any 0k 4k   # find small files

--- ls_size_suffix
  Find files ending with suffix recursively, sort by human-readable size.
  First argument: suffix, e.g. .cram or .fastq.gz
  Second (optional) argument: a lower bound for size, e.g. 10M or 64k.
  Example:
  ls_size_suffix .fastq.gz
  ls_size_suffix .cram 500M
  ls_size_suffix .cram 1G

--- ls_file_spread
  For each directory count the number of files in it, recursively.
  The output is sorted by count, with a total tally added.
  Useful to check if applications are well-behaved and do not
  crush the file system with large numbers of files in a single directory.
  Modified from code by Glenn Jackmann on stackoverflow.
```
