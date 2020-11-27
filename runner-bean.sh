#!/usr/local/bin/bash

# Long time ago since last use. It used to be useful.

set -euo pipefail

args=$@
input=
output=
tmpstore=
cleanup=false
destdir=


function rmit {
   if [[ $? == 0 ]]; then
      echo [happy] $@
   else
      errcode=$?
      echo [grumpy] $@
   fi
   if test -d $tmpstore; then
      if $cleanup; then
         rm -rf $tmpstore
      fi
   fi
   true
}

trap rmit SIGTERM  EXIT


while getopts :d:t:i:o:h opt
do
    case "$opt" in
    i)
      input=$OPTARG
      ;;
    d)
      destdir=$OPTARG
      ;;
    o)
      output=$OPTARG
      ;;
    t)
      tmpstore=$OPTARG
      ;;
    h)
      cat <<EOU
-t <dname>        use dname as tmp working directory (create if necessary)
-i <fnames>       copy files to tmp directory
-o <fnames>       copy files from tmp directory to current directory
-d <dname>        copy files in -o to this directory rather than current directory
EOU
      exit
      ;;
    :)
      error="Flag $OPTARG needs argument"
      false
      ;;
    ?)
      error="Flag $OPTARG unknown"
      false
      ;;
   esac
done

shift $(($OPTIND-1))


   ## create temp directory,
   ## and all files required.
   ##
if [[ x$tmpstore == x ]]; then
   tmpstore=/tmp/$USER.$host.$$
   cleanup=true
fi
mkdir -p $tmpstore


for f in $input; do
   cp $f $tmpstore
   echo done copying file $f
done


curwd=$(pwd)

if [[ x$destdir == x ]]; then
   destdir=$curwd
fi

cd $tmpstore

"$@"


for f in $output; do
   if [[ -e $f ]]; then
      cp $f $destdir
      echo $done retrieving file $f
   else
      echo "file $f not created as expected" 2>&1
   fi
done





