#!/usr/bin/perl
#last appdated : 6/28

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

main();

sub main(){

  open(my $in, "sentenceBERT.list");


  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);

    my @data=split(/ /, $line);
    if($#data<=1){next;}

    my $filename=$data[0];    #filename
    my $label=$data[1];       #label

    my %hash;
    for(my $i=2; $i<=$#data; $i++){$hash{$data[$i]}++;}

    open(my $in2, "../../TDNET/mk_txt/txt2/$filename");
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

      my @d2=split(/:/, $d1[0]);  #原文書の文ID
      my $gsid=$d2[1];

      if(exists($hash{$gsid})){
        print encode_utf8("$label $filename:$sid $d1[1]\n");
        $sid++;
      }

    }#文単位
    undef %hash;

  }#file単位

}
