#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

use constant OUTFILE => ">../../data.list/test.list";

main();

sub main(){
  print STDOUT "make ".OUTFILE." ...\n";
  open(my $out, OUTFILE);
  open(my $in, "../../data.list/label.list");

  while(my $line=decode_utf8(<$in>)){
    chomp($line);
    my @filename_label=split(/,/, $line);
    if($#filename_label>=1){next;}

    my $filename=$filename_label[0];
    open(my $in2, "../../TDNET/mk_txt/txt2/$filename");
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
      #if($Kaisekikekka[0] ne "助動詞" && $Kaisekikekka[0] ne "助詞"){next;}


      print $out encode_utf8("$filename:$sid $line2\n");
      $sid++;

    }#sen

  }#file

}
