#!/usr/bin/perl
#last appdated : 7/10

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

main();

sub main(){
#=pod
  open(my $in, "senBERT_label0.list");


  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);

    my @data=split(/ /, $line);
    if($#data<=1){next;}

    my $filename=$data[0];    #filename
    my $label=$data[1];       #label

    my %hash;
    for(my $i=2; $i<=$#data; $i++){$hash{$data[$i]}++;}

    open(my $in2, "../TDNET/mk_txt/txt/$filename");
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
#=cut


=pod
  open(my $in, "label0.list");

  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @tmp=split(/,/, $line);
    my $filename=$tmp[0];

    @tmp=split(/:/, $tmp[1]);
    my $label=$tmp[0];

    open(my $in2, "../TDNET/mk_txt/txt/$filename");
    my $sid=1;


    while(my $str=<$in2>){

      my $tmp=decode_utf8($str);
      my @d=split(/ /, $tmp);
      my $line2=$d[1];
      chomp($line2);
      if($line2!~/[\p{Han}\p{Hiragana}\p{Katakana}]/){next;}
      $line2=~s/\a//g;
      $line2=~s/\f//g;
      $line2=~s/\r//g;
      $line2=~s/\0//g;
      $line2=~s/\v//g;
      $line2=~s/\b//g;
      $line2=~s/\t//g;
      $line2=~s/　//g;
      $line2=~s/ //g;
      if($line2 eq ""){next;}


      #形態素解析
      my @tmp2=split(/ /, $str);
      my $str_utf8=$tmp2[1];

      my $mecab_results=decode_utf8($c->parse($str_utf8));
      my @pos=split(/\n/, $mecab_results);
      my @TangoHinsi=split(/\t/, $pos[$#pos-1]);
      my @Kaisekikekka=split(/,/, $TangoHinsi[1]);
      if(($Kaisekikekka[0] ne "助動詞" && $Kaisekikekka[0] ne "助詞") && $TangoHinsi[0]ne"お知らせ"){next;}


      print encode_utf8("$label $filename:$sid $line2\n");
      $sid++;

    }#while

  }#while
=cut
}
