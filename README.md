# bash-utils

## Apparix

Apparix is a tiny set of commands implementing directory bookmarking in **bash** and **zsh**.
You just need the file [.bourne-apparix](https://raw.githubusercontent.com/micans/bash-utils/master/.bourne-apparix).

There is a cool [**fish** implementation](https://github.com/mzuther/appari-fish)
made by Martin Zuther, named appari-fish.

What apparix does:

- Bookmark the current directory by issuing `bm foo`. This takes effect instantly
  across all your sessions (it is stored in `$HOME/.apparixrc`).

- Jump to `foo` by issuing\
  `to foo`

- Even better, jump to the subdirectory `barzoodle` of `foo` using\
  `to foo barzoodle`

- Even betterer, use tab completion with subdirectory jumping:\
  `to foo b<TAB>`

- Even even betterer, this works at arbitrary levels:\
  `to foo barzoodle/ti<TAB>`

- No less excellent, there are several *distant* listing/editing commands.
  In all cases, tab completions work on subdirectories and files:
```
  als foo              # list directory for apparix mark (plus optional subdirectories)
  als foo -ltr         # trailing part that looks like options is passed to ls
  amd foo              # make directory in apparix mark (plus optional subdirectories)
  ae foo bar.txt       # edit file in apparix mark (plus o.s.)
  av foo bar.txt       # view file in apparix mark (p.o.s.)
  aget foo bar.txt     # copy file from apparix mark (pos)
  amibm                # Is the current directory a bookmark? Useful in prompt.
  ald foo              # only list subdirectories of mark
  aldr foo             # list subdirectories recursively of mark
```
  These helper commands correspond to small bash functions and are easy to add.

Tab completion with apparix works best, IMHO, with cyclic tab completion. This
is activated by the line `TAB: menu-complete` in the file `$HOME/.inputrc` (and you may
need as well put `INPUTRC=$HOME/.inputrc` in `$HOME/.bashrc`), or the
line `bind '"\t":menu-complete'` in `$HOME/.bashrc`. 

Apparix's spiritual home nowadays is right here.
It previously was at what I would now consider the
[site of historical documents](http://micans.org/apparix).

Many thanks to Sitaram Chamarty for the original idea of sub-directory
completion and the first bash implementation thereof, and to Izaak van Dongen
for the zsh completion code and complete overhaul and improvement of the bash
completion code.


### Apparix/apparish
In the beginning the system was called Apparix; it was implemented in C, and
shipped with bash wrapper functions and completion code.  The C code was not
really needed (although it must consume many fewer CPU cycles). Its
reimplementation was called apparish. Then Martin added appari-fish to the
family. I then realised that I still think of the thing as apparix, so I've
tweaked documentation and renamed files to revert back to apparix. But the
glorious shell code itself is still apparish-rich. Stay tuned for further
naming shenanigans.


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
