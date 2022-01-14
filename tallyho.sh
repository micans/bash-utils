#!/bin/bash

set -euo pipefail

fqfile=${1?Please provide fastq file, can be gzipped}
limit=${2:-50000}
take=head

if [[ $limit == 0 ]]; then
  take=tail
  limit=+1
fi

zcat -f $fqfile | $take -n $limit | perl -ne 'print if $. % 4 == 2' | tally -record-format %R%n -format %R%t%C%n  -o - 2>.tallyho | zcat

