#!/usr/bin/perl

use strict;
use Encode;
use utf8;

main();

sub main{
  open(my $in, "evaBERT.list");
  my @fileids;
  while(my $line=decode_utf8(<$in>)){
    chomp($line);
    my @tmp=split(/ /, $line);
    my $filename=$tmp[0];
    push(@fileids, $filename);
  }#while

  foreach my $fn(@fileids){
    open(my $in, "./TDNET/mk_txt/txt/$fn");

    while(my $line=decode_utf8(<$in>)){
      chomp($line);
      my @tmp=split(/ /, $line);
      print encode_utf8("$tmp[1]\n");

    }#while
    print("\n");

  }#foreach

}
