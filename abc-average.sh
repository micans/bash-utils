#!/bin/bash

# This script expects on STDIN a stream with format
# LABEL whitespace LABEL whitespace NUMBER
# it will order each label pair lexicographically and then sort the stream so that labels
# x y
# y x
# are grouped together.
# After this it will take the average of numbers associated with a pair of labels and output
# this again in the same three-column format.

# This script can be used to compute the average edge weight for a network if edges
# are specified in two directions.


set -euo pipefail

perl -ane '$i=$F[0]le$F[1]?0:1;;print "@F[$i,1-$i,2]\n"' | sort | perl <(cat <<'EOF'
use strict;
use warnings;

sub emit_ave {
  my ($e, $ar) = @_;
die "! $e [@$ar]\n" unless @$ar;
  my $s  = 0.0;
  $s    += $_ for @{$ar};
  $s /= @{$ar};
  print "$e\t$s\n";
}

my $pe = "";
my @W  = ();

while (<>) {
  chomp;
  my @F = split;

  my $i = $F[0] le $F[1] ? 0 : 1;
  my $e = "$F[$i]\t$F[1-$i]";

  if ($pe && $pe ne $e) {
    emit_ave($pe, \@W);
    @W = ();
  }
  push @W, $F[2];
  $pe = $e;
}
emit_ave($pe, \@W);
EOF
)
