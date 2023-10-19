#!/usr/bin/perl

use strict;
use Encode;
use utf8;

main();

sub main{
  my @name=("上場会社の決定事実", "上場会社の発生事実", "上場会社の決算情報", "上場会社の業績予想、配当予想の修正等", "その他の情報", "子会社等の決定事実", "子会社等の発生事実", "子会社等の業績予想の修正等");

  open(my $in, "../../data.list/sentenceBERT.list");
  my %hash;
  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @data=split(/ /, $line);
    if($#data==1){next;}
    $hash{$data[1]}+=$#data-1;
  }

  print encode_utf8("     学習データのクラスごとの文数\n");
  for(my $i=0; $i<8; $i++){
    print encode_utf8("$i $name[$i] : $hash{$i}\n");
  }

}
