#!/usr/bin/perl
#last appdated : 6/14

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

main();

sub main(){
  open(my $in, "label.txt");
  while(my $line=decode_utf8(<$in>)){  #file単位のループ

    chomp($line);
    my @data=split(/,/, $line);
    if($#data<1){next;}

    my @data2=split(/ /, $data[1]);
    my $lb=$data2[0];
    my $filename=$data[0];
    open(my $in2, "../../TDNET/mk_txt/txt/$filename");
    my $sid=1;



    while(my $str=<$in2>){  #文単位のループ

      my $ln=decode_utf8($str);
      chomp($ln);
      if($ln!~/[\p{Han}\p{Hiragana}\p{Katakana}]/){next;}
      $ln=~s/\x0A//g;
      $ln=~s/\x0D//g;
      $ln=~s/\x0D?\x0A?$//;
      $ln=~s/\a//;
      $ln=~s/\f//;
      $ln=~s/\r//;
      $ln=~s/\0//;
      $ln=~s/\v//;
      $ln=~s/\b//;
      $ln=~s/\t//;
      if($ln eq ""){next;}

      #sentenceBERT
      my @dt=split(/ /, $ln);
       print encode_utf8("$filename $lb $dt[1]\n");
      if(`python3 calc_similarity.py $dt[1] $lb`==1){print encode_utf8("$lb $filename:$sid $dt[1]\n"); $sid++;}
    }
  }
}
