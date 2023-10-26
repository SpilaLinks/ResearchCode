#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main(){

  my $FILEPATH1="../../data.list/bert_label.list";
  my $FILEPATH2="../classifyBERT/classified_RoBERTA.list";

  my $l0=0; my $l1=0; my $l2=0; my $l3=0; my $l4=0; my $l5=0;my $l6=0;my $l7=0;

  my $filename=$FILEPATH1;

  open(my $in, $filename);
  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @tmp=split(/ /, $line);
    #print("$tmp[1]\n");
    my @data=split(/:/, $tmp[1]);
    #print encode_utf8("$data[0]\n");

    if($data[0]eq"0"){$l0++;}
    if($data[0]eq"1"){$l1++;}
    if($data[0]eq"2"){$l2++;}
    if($data[0]eq"3"){$l3++;}
    if($data[0]eq"4"){$l4++;}
    if($data[0]eq"5"){$l5++;}
    if($data[0]eq"6"){$l6++;}
    if($data[0]eq"7"){$l7++;}
  }

  print encode_utf8("[0]上場会社の決定事実 : $l0\n[1]上場会社の発生事実 : $l1\n[2]上場会社の決算情報 : $l2\n[3]上場会社の業績予想、配当予想の修正等 : $l3\n[4]その他の情報 : $l4\n[5]子会社等の決定事実 : $l5\6\n[6]子会社等の発生事実 : $l6\n[7]子会社等の業績予想の修正等 : $l7\n\n");

}
