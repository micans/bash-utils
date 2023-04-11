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

## Unix file column and row manipulation using column names

  `pick` is a concise command-line query/programming tool to manipulate streamed data columns and rows.
  It can be thought of as (unix) `cut` on steroids, augmented with aspects of `R` and `awk`.

  - Column names or indexes become variables.
  - Create new variables using arithmetic and string operations on existing variables.
  - Each variable can reference any variable previously defined.
  - Optionally output a variable as a new column.
  - Optionally update an existing column (`-i`).
  - Load dictionaries for mapping values either from file or command-line/string.
  - Filter rows of interest using variables in conditional expressions (`@foo/gt/0`).
  - Insert new columns at position `N` (by default at end), keep old columns (`-A` and `-A<N>`).
  - Remove columns (`-x col1 col2 col3`).
  - Ragged input (e.g. SAM format) with `-O<N>` (collate all columns from `N` onwards).
  - If needed, perl regular expression selection of multiple column names, e.g. `foo\d{3}`.
  - Syntax is compact and common use cases avoid shell metacharacters.

  `pick` is the latest incarnation of a concept that I've attempted many times
  over the years.  This is the first one that is fun to use, surprisingly
  powerful, with an implementation that has some aspects of elegance.

  The interface is a tiny command-line format to describe column selection,
  row filtering, and derived column computation. It was designed to avoid shell
  meta characters as much as possible. Derived columns are computed in a tiny
  stack language that accepts column names (`:<name>`), constant values (`^<value>`)
  and operators (`,<op>`).

  `pick` and `hissyfit` are a powerful combination. I aim to either find a good
  terminal scatterplot script or add it myself for unmitigated textual science joy.
  [YouPlot](https://github.com/red-data-tools/YouPlot) looks quite promising.


```
   # pick columns foo bar from data.txt. Order is as specified.
   #
pick foo bar < data.txt

   # pick columns bar foo from data.txt, in that order. With -h
   # the column names themselves are dropped.
   #
pick -h bar foo < data.txt

   # pick column 5 and 3 from data.txt, in that order; -k implies
   # no column names are expected, and handles are 1-based indexes.
   #
pick -k 5 3 < data.txt

> ---------------

   # pick columns foo bar with rows where tim fields are larger than zero.
   # multiple @ selections are possible; default is AND, use -o for OR.
   # tim can refer to a newly computed variable.
   #
pick foo bar @tim/gt/0 < data.txt
   #                                   Comparison operators are many:
   #   = /=                            string identy select, avoid
   #   ~ /~                            string (Perl) regular expression select, avoid
   #   ~eq~ ~ne~ ~lt~ ~le~ ~ge~ ~gt~   string comparison
   #   /eq/ /ne/ /lt/ /le/ /ge/ /gt/   numerical comparison
   #   /ep/ /om/                       numerical proximity (additive, multiplicative)
   #   /all/ /any/ /none/              bit selection

   # as above, but compare to column bob (indicated by leading :)
   #
pick foo bar @tim/gt/:bob < data.txt

> ---------------

   # as the first, also output new column doodle which is column yam with column
   # bob subtracted and constant value '1' added. (interval length for inclusive bounds)
   #
pick foo bar doodle::yam:bob,sub^1,add < data.txt
   #
   # <name>::<compute> puts the result of <compute> in <name> and outputs it
   # <name>:=<compute> puts the result of <compute> in <name> (for comparison or further use)
   #
   #   : signifies a handle,
   #   , signifies an operator
   #   ^ signifies a constant value

> ---------------

   # select all columns (-A), add 1 to column foo in-place (-i).
   #
pick -Ai foo::foo^1,add < data.txt

> ---------------

   # pick the length of items in column foo without printing a header, pipe it to
   # hissyfit.  Each compute needs an associated name that is unique (the part
   # before ::).  In this example the unique name is the empty string, offering the tiny
   # convenience that you don't always need to expend energy on thinking up a variable
   # name / column name.
   #
pick -h ::foo,len < data.txt | hissyfit

> ---------------

   # Output everything and swap two columns. This is mostly to illustrate how
   # columns and compute names interact.  Compute names are like normal
   # variables, so to swap two values a third name is needed.
   #
pick -Aki foo:=1 1::2 2::foo < data.txt
   #
   #   -k implies no columns names are read, column handles are 1 2 3 ..
   #   -A selects all columns for output.
   #   -i is needed to allow overwriting existing columns 1 and 2.  
   #   Assignments happen proceeding from left to right
   #   := computes a value without outputting it,
   #   :: computes a value and selects it for output.

> ---------------

   #  If large numbers of columns are present/needed, it can be useful to select
   #  column names with a regular expression. A pattern that contains any of [({\*?^$
   #  is assumed to be a regular expression rather than just a column name.
   #  Use -F (fixed) to prevent regular expressions being used.
   #
pick 'foo\d{2}$' < data.txt

   # As above, in a derived column select multiple input columns, then take the
   # maximal value across, giving it the new name foomax. Use -h to avoid
   # printing out a column header.  Currently addall, maxall, minall and
   # joinall consume the entire stack.
   #
pick foomax::'foo\d{2}$',maxall < data.txt
   #
   # Be careful with patterns in compute; e.g. if the pattern starts with ^
   # (for start of string), it must be url-encoded as %5E; otherwise it will be
   # interpreted as the token introducing a constant value.  The characters
   # ^ : , have special meaning in the pick stack language (see above) and must
   # be url-encoded.

   # A bit more ambitious; express all columns whose names match foo\d\d in
   # terms of a percentage relative to column foo01. A copy of foo01 is needed
   # (in reference) as it is transformed in-place.  Due to the use of ':='
   # rather than '::' the derived column reference is not output.  The
   # placeholder '__' is used to slot each matching column into the compute
   # expression.
   #
pick -Ai reference:=foo01 '\foo\d{2}$'::__:reference^1,pct < data.txt

> ---------------

   # Create fasta files with pick.
   # Simplest case, two input columns. Quotes needed as '>' is a shell meta character.
   # %0A is the url-encoding of a newline.
   #
pick  -k '::^>:1^%0A:2' > out.fa
   #
   # Use columns foo and bar instead
   #
pick   '::^>:foo^%0A:bar' > out.fa
   #
   # As above, add column zut as further annotation. Optionally use %20 for the space character.
   #
pick   '::^>:foo^ :zut^%0A:bar' > out.fa

> ---------------

   # Map column values using a dictionary. Dictionaries can be specified in two ways:
   #        --fdict-NAME=/path/to/dictfile      where dictfile is two-column tab-separated.
   #        --cdict-NAME=foo:bar,zut:tim        comma-separated key:value pairs
   #
   # NAME is the name of the dictionary, to be used with the map operator as seen below.
   # Multiple fdict and cdict specifications can be used for the same NAME.
   #
echo -e "a\t3\nb\t4\nc\t8" | pick -Aik --cdict-foo=a:Alpha,b:Beta 1::1^foo,map
   #
   # By default if no key is found in the dictionary the value is left alone. It is possible
   # to specify a not-found string using this syntax:
   #
   #        --fdict-NAME/STRING=/path/to/dictfile
   #        --cdict-NAME/STRING=foo:bar,zut:tim
   #
echo -e "a\t3\nb\t4\nc\t8" | pick -Aik --cdict-foo/FOONOTFOUND=a:Alpha,b:Beta 1::1^foo,map
Alpha 3
Beta  4
FOONOTFOUND 8
   #
   # You could grep that value, or use pick itself to select or filter such columns, e.g. below
   #  - the -i (in-place) option is dropped
   #  - the mapped values in column 1 are put in variable x
   #  - x is not output (:= instead of ::)
   #  - unmappable values are set to FOONOTFOUND
   #  - Those rows are selected where x has the FOONOTFOUND value
   #
echo -e "a\t3\nb\t4\nc\t8" | pick -Ak --cdict-foo/FOONOTFOUND=a:1,b:1 x:=1^foo,map @x=FOONOTFOUND
c  8
   #
   # The empty string can be used as the special unmappable value:
   #
echo -e "a\t3\nb\t4\nc\t8" | pick -Ak --cdict-foo/=a:1,b:1 x:=1^foo,map @x=
c  8

```

  Pick supports a wide range of functionality. Standard arithmetic, bit
  operations and a number of math functions are provided (see below).  It is also possible
  to match and extract substrings using Perl regexes (as a derived value or new
  column) with `get`, change an existinig column using a regex with `ed` and
  `edg`, compute md5 sums, URL-encode and decode, convert to and from binary,
  octal and hex, reverse complement DNA/RNA, and extract statistics from cigar
  strings. Display options include formatting of fractions and percentages
  and zero padding of integers.
  
  The documentation is output when given `-H` - `-h` is the option to prevent
  output of column names, or `-l` for a more concise summary of options and
  syntax.

  Supported compute operators:
```
Stack control: dup pop xch
Consume 1: abs binto cgseqlen cos exp exp10 hexto lc len log log10 md5 octto rc rev rot13 sign sin sq sqrt tan tobin tohex tooct uc urldc urlec
Consume 2: add and cat cgcount cgls cgmax cgsum cgtally dd div get max min mod mul or pow sub uie xor zp
Consume 3: ed edg frac pct substr

```


## Unix terminal histograms and bar charts

  `hissyfit` can be used at the end of Unix pipes (or read from file) to draw
  terminal histograms and bar charts for quickly gauging numerical data and count
  data - see screenshots and link to raw output below.

  No need to fire up R or Python.  [It's just one script.](https://raw.githubusercontent.com/micans/bash-utils/master/hissyfit)
  Example usage with some random data is below. **Sadly github markdown does not allow setting of line-height, hence the stripy look.**
  It looks better in the terminal (screen shots below).
```
for i in {1..100000}; do echo $(( (RANDOM+RANDOM+RANDOM)/3)); done | \
   hissyfit --cv=0/32768/64/16 --x=0%4000 --d=5461/10922/21845/27306
                             ▂ ▂█▅
                           ▆▄█████▆▇▇
                         ▃███████████▄▂▂
                       ▄▆███████████████▃
                      ▂██████████████████▃
                     ▂████████████████████▅
                    ▆██████████████████████▃
                   ▂████████████████████████▇
                  ▅██████████████████████████▆
                ▁▆████████████████████████████▇▂
               ▃████████████████████████████████▂
              ▃██████████████████████████████████▇
            ▃▇████████████████████████████████████▇▅
          ▄█████████████████████████████████████████▇▅
       ▂▅█████████████████████████████████████████████▇▅▁
  ▁▁▃▅▇██████████████████████████████████████████████████▇▅▃▂▁
____.____,____.____,____Q____,__Q_.____Q____.____,____.____,____
|      |  ◆    |     ◆ |       |       |  ◆   |      ◆|       |
0      4000    8000    12000   16000   20000  24000   28000   32000
          5461       10922                21845      27306  
▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭▭
ND=100000 hmin=0 hmax=32768 dmin=359 dmax=32391
topbin(i=33,n=3635,p=3.6,x~16640) bw=512 qr=(12559 16425 20276)
Division bin sizes
      Left     Right      Count   Pct     Sum     Pct
       359    5461.3      2085    2.08    2085    2.08
    5461.3   10922.7      14396   14.40   16481   16.48
   10922.7   21845.3      66780   66.78   83261   83.26
   21845.3   27306.6      14685   14.69   97946   97.95
   27306.6     32391      2054    2.05    100000  100.00
```

  All hissyfit parameters here are optional.
  The `--cv` (canvas) parameter can set up to four parameters simultaneously: min and max histogram
  endpoints, the number of bins, and the height of the histogram.
  
  The `--x` parameter sets ticks for display. When given the format `N%w` it results in all ticks that are `w`
  apart, anchored at position `N`, and fit in the range of data shown. Alternatively, it can be supplied
  with the format `x1[/x2]*` (a list of numbers separated by slashes) to set each tick explicitly.
  
  The `--d` parameter defines variable-sized super-bins for which hissyfit will
  output a table of counts and percentages. This option can be useful after initial inspection
  of a histogram to gauge the size of different modes. In this example the division values were
  chosen to represent the four points { μ ± σ, μ ± 2σ } where μ and σ are the expected mean and deviation
  for a sum of three uniform distributions on [0,32768].

  The default number of bins is 100. With no parameters given hissyfit output looks like this:
```
for i in {1..100000}; do echo $(( (RANDOM+RANDOM+RANDOM)/3)); done | hissyfit
                                                 █▁  ▅▃▃
                                            ▆█▇▇▅██▅▆███ ▁▃
                                        █ ▇████████████████▅▅
                                      ▇██▆███████████████████▄
                                    ▃███████████████████████████
                                  ▃▂████████████████████████████▄▆
                                 ▁████████████████████████████████▇
                                ███████████████████████████████████▂
                              ▁█████████████████████████████████████▁▁
                             ▂████████████████████████████████████████▁▁
                            ████████████████████████████████████████████▂
                          ▃▅██████████████████████████████████████████████▁
                         ▄█████████████████████████████████████████████████▆
                      ▃▅████████████████████████████████████████████████████▆
                    ▂▆████████████████████████████████████████████████████████▇▂
                   ▆████████████████████████████████████████████████████████████▆▂
               ▁▄▆▇███████████████████████████████████████████████████████████████▇▃
             ▃▅██████████████████████████████████████████████████████████████████████▆▅▁
        ▁▂▃▇▇███████████████████████████████████████████████████████████████████████████▇▅▃
   ▂▁▃▆▆████████████████████████████████████████████████████████████████████████████████████▆▅▄▄▂
375.0 ___,____.____,____.____,____.___Q,____.____,Q___.____,__Q_.____,____.____,____.____,__ 32289.0
ND=100000 hmin=375 hmax=32289 dmin=375 dmax=32289
topbin(i=50,n=2254,p=2.3,x~16172.43) bw=319.14 qr=(12519 16388 20225)
```

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

