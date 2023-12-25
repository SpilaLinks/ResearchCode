#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

main();

sub main(){
  open(my $in, "<", "../../data.list/label_0.list");
  open(my $out, ">", "../../data.list/train_label0.list");
  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);

    my @data=split(/ /, $line);
    if($#data==0){next;}

    my $filename=$data[0];    #filename
    my $label=$data[1];       #label

    open(my $in2, "<", "../../TDNET/mk_txt/txt2/$filename");
    my $sid=1;
    while(my $line=decode_utf8(<$in2>)){      #文単位のループ
      chomp($line);

      my @d1=split(/ /, $line);
      $d1[1]=~s/\a//g;
      $d1[1]=~s/\f//g;
      $d1[1]=~s/\r//g;
      $d1[1]=~s/\0//g;
      $d1[1]=~s/\v//g;
      $d1[1]=~s/\b//g;
      $d1[1]=~s/\t//g;
      $d1[1]=~s/　//g;
      $d1[1]=~s/ //g;
      if($d1[1] eq ""){next;}
      print $out encode_utf8("$label $filename:$sid $d1[1]\n");
      $sid++;
    }#sentence
  }#file
}