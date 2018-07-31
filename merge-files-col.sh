#!/bin/bash

# Merge single columns from multiple files using standard command line
# utilities and additionally the custom 'transpose' program from the
# micans/reaper respository.
#
# Several checks (e.g. row name identiy) and options are available, see the -h
# output.
# Intermediate output and final output are both gzipped.
#
# This program uses cut(1) to isolate the columns; it writes each sequentially
# using paste(1) as a single line and appends the lines.  This leads to a
# result which is the transposed of what is needed; In terms of a standard
# application (input columns are gene counts across multiple conditions) output
# row names now correspond to samples and column names correspond to gene names.
#
# The final result is obtained by using the custom program 'transpose', which
# is a C implementation of the needed transpose operation This combined
# approach is generally a lot faster than using R to load tables and cbind to
# combine the columns into a new table.
#
# TODO: clean-up of extra files; perhaps work in /tmp.
#


set -euo pipefail

                        # For these options, see the documentation under -h
                        # for a description of what they do.
basename=out
test_tp=false
header=true
rowdatastart=2
rownames_check=true
help=false
col=2
colname=
colname_expected=
stripright=
stripleft=
output=
skip=0
verbose=false

function clean_up {
   thestatus=$?
   if $help; then
      true
   elif [[ $thestatus == 0 ]]; then
      >&2 echo "[happy] Script succeeded - gzipped output in $output"
      if [[ -e "$tpfile.TP" ]]; then
         rm "$tpfile.TP"
         >&2 echo "removed file $tpfile.TP after successful test"
      fi
   else
      >&2 echo "[grumpy] Script failed"
   fi
}


   ##  register the function clean_up to be run when script exits,
   ##  after all the other code in this script.
   ##  At the moment it does not do much.
   ##
trap clean_up INT TERM EXIT


while getopts :c:C:E:b:o:s:x:y:VLTHh opt
do
    case "$opt" in
    b)
      basename=$OPTARG
      ;;
    c)
      col=$OPTARG
      ;;
    x)
      stripleft=$OPTARG
      ;;
    y)
      stripright=$OPTARG
      ;;
    C)
      colname=$OPTARG
      ;;
    H)
      header=false
      rowdatastart=1
      ;;
    E)
      colname_expected=$OPTARG
      ;;
    o)
      output=$OPTARG
      ;;
    T)
      test_tp=true
      ;;
    L)
      rownames_check=false
      ;;
    V)
      verbose=true
      ;;
    s)
      skip=$(($OPTARG+1))
      ;;
    h)
      cat <<EOU
Usage: merge-col-files.sh [ -c <NUM> ] [ MORE OPTIONS ] FILES
Options:
-b basename    basename for output (default $basename)
-c <NUM>       column index (default 2)
-C <colname>   rename column to <colname> (default taken from column head)
-E <check>     require file column name to be <check> (mnemonic: expect)
                  Caveat: currently this check is only performed for the first file in the list.
-o <name>      write output to name (default: <basename>.<colname>.txt.gz)
-x pattern     for result column name, strip pattern from the left of file name
-y pattern     for result column name, strip pattern from the right of file name
-T             test use of the transpose program (re-transpose, compare with original)
-L             lax; do not test whether row names (first column) are identical between files
-V             verbosity on
-s <num>       skip first <num> lines
EOU
      help=true
      exit
      ;;
    :) >&2 echo "Flag $opt needs argument"
        exit 1;;
    ?) >&2 echo "Flag $OPTARG unknown"
        exit 1;;
   esac
done

OPTIND=$(($OPTIND-1))
shift $OPTIND

if [[ $# == 0 ]]; then
   >&2 echo "Error (no files provided)"
   false
fi
firstfile=$1

if $header; then
     # get the column labels of interest, e.g. gene counts.
     #
  read -a colnames <<EOF
  $(tail -n +$skip "$firstfile" | head -n 1 | cut -f $col)
EOF

  >&2 echo "Found column name ${colnames[0]}"
  if [[ ! -z "$colname" ]]; then
     >&2 echo "Using supplied column name $colname"
  else
     colname=${colnames[0]}
  fi

  if [[ ! -z "$colname_expected" && "$colname_expected" != "$colname" ]]; then
     >&2 echo "Expected column name $colname_expected but found $colname"
     false
  fi
else
  colname=col${col}
fi


tpfile=$basename.$colname.TP.gz
dstfile=$basename.$colname.txt.gz
rownamefile=$basename.$colname.rn
idx=1

   # Get the row labels of interest, e.g. gene names.
   # Save them for comparison with rownames in later files,
   # and write them to the destination file (gzipped).
   #
(tail -n +$skip "$firstfile" | cut -f 1 | tee "$rownamefile" | paste -s | gzip) > "$tpfile"
   #
   # Note: below we append to tpfile (after gzipping). This is OK because
   # zipfiles can be concatenated.

(
for f in $@; do
   level=$f
   if [[ ! -z "$stripleft" ]]; then
      level=${level#$stripleft}
   fi
   if [[ ! -z "$stripright" ]]; then
      level=${level%$stripright}
   fi
   if $verbose; then
    >&2 printf "%5d $level\n" $idx
   fi
   idx=$(($idx+1))

   if $rownames_check && ! cmp -s "$rownamefile" <(tail -n +$skip $f | cut -f 1) ; then
      >&2 echo "rownames check failed when comparing $firstfile and $f"
      false
   fi

   (echo "$level"; cut -f $col $f | tail -n +$skip | tail -n +$rowdatastart) | transpose -i - --nozip -o -
done
)  | gzip >> $tpfile


if [[ -z "$output" ]]; then
   output=$dstfile
fi

transpose -i $tpfile -o $output

if $test_tp; then
   transpose -i "$output" -o "$tpfile.TP"
   files="$tpfile and $tpfile.TP"
   if ! cmp -s <(zcat "$tpfile") <(zcat "$tpfile.TP"); then
      >&2 echo "Files $files are not byte-identical"
      false
   else
      >&2 echo "Test passed - $files are byte-identical"
   fi
fi   



# Todo:
# - improve tpfile dstfile rownamefile; enable directories and play
#   nicely with -o option. e.g. -o output/base
# - -s option exists, perhaps also skip initial regex (e.g. initial lines
#   starting with #
