#!/usr/bin/perl

#  Suppose our alphabet has 3 tokens xyz and we want to generate all words of
#  length 5. We keep track of a word as a register of integers.
#  That is, a fruit machine that changes state:
#
#        (0)   (0)   (0)   (0)   (0)      ->       xxx
#        (0)   (0)   (0)   (0)   (1)      ->       xxy
#        (0)   (0)   (0)   (0)   (2)      ->       xxz
#        (0)   (0)   (0)   (1)   (0)      ->       xyx
#        (0)   (0)   (0)   (1)   (1)      ->       xyy
#        (0)   (0)   (0)   (1)   (2)      ->       xyz
#        (0)   (0)   (0)   (2)   (0)      ->       xzx
#        ..
#
#  This is arithmetic where a 1 is added to the rightmost position; if
#  there is a carry we need to increment its left neighbour and so on.
#  When the leftmost position generates a carry we are done.


my $amz = shift;
die "need alphabet as first argument" unless defined($amz);

my $N = shift;
die "need k as in k-mer as second argument" unless defined($N) && $N >= 0;

my @amz = split "", $amz;
my $k = @amz;
my @register = (0) x $N;

if (!$k || !$N) {
   exit 0;
}

while (1) {

   print map { $amz[$_] } @register;
   print "\n";
   my $r = @register;
   while (--$r>=0) {
      $register[$r]++;
      last if $register[$r] %= $k;          # last if no carry.
   }
   last if $r < 0;      # signifies carry in leftmost position.
}

