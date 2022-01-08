# bash-utils

## Command line directory bookmarks

Apparix used to live here but has [its own repository](https://github.com/micans/apparix)
now.


## Misc scripts

- *bubba* Bsub/wrapper LSF submission script to take some pain away.
  It prints the constructed bsub command and submits it. Several options
  including dry run (-T).

- *hissyfit*  Unix terminal ascii histograms for quickly gauging data.
  It uses 100 bin (currently fixed), optional min/max data subselection,
  yunits adjustable, optional cumulative histogram.


```
> hissyfit --nyunits=100  --min=0 --max=3 iput
          |-
          ||
         +||
         |||.
         ||||
        +||||
        |||||
        |||||'         .+||
       '||||||       .-||||'
       |||||||     .'|||||||+
      '|||||||    -||||||||||
      |||||||||  -||||||||||||
      |||||||||'||||||||||||||'
     ||||||||||||||||||||||||||+
     |||||||||||||||||||||||||||
    |||||||||||||||||||||||||||||
   |||||||||||||||||||||||||||||||
   ||||||||||||||||||||||||||||||||'-
 --|||||||||||||||||||||||||||||||||||''++--+-.--.------+++--++---....
-|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||''+-+---.... .
____.____^____.____^____.____^____.____^____.____^____.____^____.____^____.____^____.____^____.____^
N=273410 oor=356/0.1% hmin=0 hmax=3 dmin=0.01409641 dmax=5.863222 bigbin=13464 bin-width=0.03
```

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
