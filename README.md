# bash-utils

## Command line directory bookmarks

Apparix used to live here but has [its own repository](https://github.com/micans/apparix)
now.


## Miscellaneous code

- `bubba` Bsub/wrapper LSF submission script to take some pain away.
  It prints the constructed bsub command and submits it. Several options
  including dry run (-T).

- `hissyfit`  Unix terminal ascii histograms for quickly gauging numerical data.
  Expected input is a stream of numbers, one per line.
  Drawn with Unicode block glyphs by default (use `--plain` to disable).  Other
  options are min and max histogram endpoints (`--min --max`, simultaneously acts
  as data sub-selection), height/resolution
  (`--height`), cumulative tallying (`--cumulative`), user-specified glyphs
  (`--stairs`) and the number of bins.
  It can also take the output of `uniq -c` to draw bar charts for categorical data
  (see fourth screenshot below), when given the `--tallyin` option. In this case
  the output is in the form of horizontal bars with labels in front and counts after.

![regular histogram, unicode paint](https://github.com/micans/bash-utils/blob/master/img/hf.png)

![regular histogram, ascii paint](https://github.com/micans/bash-utils/blob/master/img/hf2.png)

![regular histogram, emoji paint](https://github.com/micans/bash-utils/blob/master/img/fh3.png)

![horizontal bar chart of categorical data](https://github.com/micans/bash-utils/blob/master/img/hft.png)

- `merge-files-col.sh` This merges columns of files using `transpose`
  from [the reaper distribution](https://github.com/micans/reaper). It is quite a bit faster and much
  more memory efficient than a straightforward Python or perl implementation.

- `peach.c`  PArEnthesis CHecker. It's not smart about anything and will complain about
   things like `/* my little list 1) foo 2) bar */` and `"->)(<-"`. Still I've found it
   helpful over the years. It checks `{}`, `()` and `[]`. This is the first C program I wrote,
   so please be gentle.

- `wordmer.pl` generate all words of length `k` over some alphabet.

- `tallyho.sh` tally the first `N` sequences of a fastq file, for example to look at index reads.
   This uses `tally` from [the reaper distribution](https://github.com/micans/reaper).


## bash-workutils

Space/time bash functions in `.bash-workutils` (see further below). Most of
these will lead to a lot of disk access, use with care.  A bunch of other
miscellaneous functions have been added. Two worth picking out are

- `funcfile NAME` find in which file function `NAME` is defined.
- `ls_func FILE` list all functions defined in `FILE`.

The list of functions in `.bash-workutils`:

```
achoo bj bjl colcount colnames ffn funcfile gimme_sum grab groupify
howoldami lines ls_bigold ls_count_files ls_file_spread ls_func
ls_lastfile ls_ls ls_misc ls_mouldy ls_size_any ls_size_suffix myman
nchar procli public silent tailafter ungroupify
```

Space time functions in more detail:

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

## bash-myutils

More small functions that I use in `.bash-myutils`. These are slightly
more random than the ones in `.bash-workutils`.

```
bash_max bash_min countcram cpuhours debug_bash decolon ffncp ffnl fqfa
helpme nflogcmd set_farm_mem themax themax2 themin themin2 theminmax
```

