# bash-utils

Some of the scripts here are to aid data inspection in the command line, avoiding
the need to fire up R or Python. These are primarily `pick` (for selecting/combining/transforming/filtering
tabular data) and `hissyfit` (terminal histograms). Also useful is `transpose` from
[github.com/micans/reaper](https://github.com/micans/reaper) for fast and low-memory transposition
of (large) tabular data.

**List of highly useful software**
[GNU datamash](https://www.gnu.org/software/datamash/).


## Command line directory bookmarks

Apparix used to live here but has [its own repository](https://github.com/micans/apparix)
now.

## Stream compute on rows/columns in tabular data.

  `pick` can be thought of as (unix) `cut` on steroids, augmented with aspects of `R` and `awk`.
  It can select columns like `cut`, but allows doing so either by column name or column index;
  it understands both header lines and row names.

  - Column names or indexes become variables
  - These variables can be used to create new columns using arithmetic or string operations, or to update an existing column.
  - The same variables can be used in conditional expressions to filter rows of interest.

  `pick` is the latest incarnation of a concept that I've attempted and failed at
  many times over the years.  The recent ones were all called `recol`.  This is
  the first one that is fun to use, surprisingly powerful, and an implementation
  that has some aspects of elegance, although the commit history of pick
  reveals a fairly hideous detour and slow winding way to conciseness.

  The interface is a tiny command-line format to describe column selection,
  row filtering, and derived column computation. It was designed to avoid shell
  meta characters as much as possible. Derived columns are computed in a tiny
  stack language that accepts column names (`:<name>`), constant values (`^<value>`)
  and operators (`,<op>`).

  `pick` and `hissyfit` are a powerful combination. I aim to either find a good
  terminal scatterplot script or add it myself for unmitigated textual science joy.
  [YouPlot](https://github.com/red-data-tools/YouPlot) looks quite promising.


```
   # pick columns foo bar from data.txt.
   #
pick foo bar < data.txt

   # select all columns (-A), add 1 to column foo in-place (-i).
   #
pick -Ai foo::foo^1,add < data.txt

   # pick columns foo bar with rows where tim fields are larger than zero.
   # multiple @ selections are possible; default is AND, use -o for OR.
   # tim can refer to a newly computed variable
   #
pick foo bar @tim/gt/0 < data.txt

   # as the first, also output new column doodle which is column yam with column
   # bob subtracted and constant value '1' added. (interval length for inclusive bounds)
   #
pick foo bar doodle::yam:bob,sub^1,add < data.txt
   #
   # <name>::<compute> puts the result of <compute> in <name> and outputs it
   # <name>:=<compute> puts the result of <compute> in <name> (for comparison or further use)
   #
   # : signifies a handle,
   # , signifies an operator
   # ^ signifies a constant value

   # pick the length of items in column foo without printing a header, pipe it to
   # hissyfit.  Each compute needs an associated name that is unique (the part
   # before ::).  In this example the unique name is the empty string.
   #
pick -h ::foo,len < data.txt | hissyfit
```

  I add whatever functionality seems useful. Hence it is currently possible to encrypt your
  data with rot13 or reverse complement DNA/RNA. The documentation is output when given `-H` -
  `-h` is the option to prevent output of column names, or `-l` for a more concise summary
  of options and syntax.

  Supported compute operators:
  `dup pop xch abs cos exp exp10 lc len log log10 rc rev rot13 sign sin sq sqrt tan uc add and cat div get max min mod mul or pow sub xor ed edg`


## Unix terminal histograms and bar charts

  `hissyfit` can be used at the end of Unix pipes (or read from file) to draw
  terminal histograms and bar charts for quickly gauging numerical data and count
  data - see screenshots and link to raw output below.

  No need to fire up R!
  [It's just one script, get it here.](https://raw.githubusercontent.com/micans/bash-utils/master/hissyfit)

  For numerical data expected input is a stream of numbers, one per line.
  Options are min and max
  histogram endpoints (`--min --max`, simultaneously acts as data sub-selection),
  height/resolution (`--height` in lines, resolution is 8 times larger),
  cumulative tallying (`--cumulative`),
  the number of bins (`--bins`),
  and user-specified glyphs (`--stairs`).
  It is also possible to read input that already specifies the histogram heights (`--histin`).

  For bar charts `hissyfit` accepts the output of `uniq -c` (that is, each line has `<count> <label>`)
  to draw bar charts for categorical data (see fourth screenshot), when given the `--tallyin` option.
  In this case the output is in the form of horizontal bars with labels in
  front and counts after.
  To sort by label (or otherwise), simply use unix `sort` before `uniq -c`, e.g.
  `sort | uniq -c | hissyfit`.
  To sort by count, use `sort | uniq -c | sort -n | hissyfit`.

  Histograms and bar charts are drawn with Unicode block glyphs by default. Use
  `--plain` to disable this and use `--stairs` to provide your own glyphs.

### Example outputs (in HTML/\<pre>)

  Sticking the output within `<pre></pre>` tags is a cheap way of getting
  histograms in HTML.  Below are some screenshots; the corresponding raw text
  (and display) in `HTML/<pre>` can be seen either [as a github
  preview](https://htmlpreview.github.io/?https://github.com/micans/bash-utils/blob/master/hissyfit.html),
  [right in this repo
  (source)](https://github.com/micans/bash-utils/blob/master/hissyfit.html) or
  [here at micans.org](http://micans.org/stijn/haphazard/hissyfit.html).


### Beyond and more

  Hissyfit is just one script. Projects with more code and much greater capabilities are
- [Jp -  terminal plots from JSON (or CSV) data](https://github.com/sgreben/jp)
- [Termgraph - basic graphs in the terminal](https://github.com/mkaz/termgraph)
- [YouPlot - plots in the terminal](https://github.com/red-data-tools/YouPlot)
- [bashplotlib - plots in the terminal](https://github.com/glamp/bashplotlib)
- [plotext - plot directly in the terminal](https://github.com/piccolomo/plotext)
- [distribution - character-based graphs in the terminal](https://github.com/wizzat/distribution)


### Screenshots

![regular histogram, unicode block paint](https://github.com/micans/bash-utils/blob/master/img/hf.png)

![regular histogram, simple paint](https://github.com/micans/bash-utils/blob/master/img/hf2.png)

![regular histogram, emoji paint](https://github.com/micans/bash-utils/blob/master/img/fh3.png)

![horizontal bar chart of categorical data](https://github.com/micans/bash-utils/blob/master/img/hft.png)


## Miscellaneous code

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

- `bubba` Bsub/wrapper LSF submission script to take some pain away.
  It prints the constructed bsub command and submits it. Several options
  including dry run (-T).


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

