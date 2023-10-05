#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

use constant OUTFILE => "train.list";

main();

sub main(){
  print STDOUT "make ".OUTFILE." ...\n";
  open(my $out, ">../../data.list/".OUTFILE);
  open(my $in, "../../data.list/label.list");

  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);

    my @filename_label=split(/,/, $line);
    if($#filename_label<1){next;}

    my $filename=$filename_label[0];    #filename
    my $label=$filename_label[1];       #label

    open(my $in2, "../../TDNET/mk_txt/txt2/$filename");
    my $sid=1;
    while(my $line=decode_utf8(<$in2>)){      #文単位のループ
      chomp($line);

      my @id_sentence=split(/ /, $line);
      $sentence=$id_sentence[1];
      $sentence=~s/\a//g;
      $sentence=~s/\f//g;
      $sentence=~s/\r//g;
      $sentence=~s/\0//g;
      $sentence=~s/\v//g;
      $sentence=~s/\b//g;
      $sentence=~s/\t//g;
      $sentence=~s/　//g;
      $sentence=~s/ //g;
      $sentence=replaceNamedEntity($sentencea);
      if($sentence eq ""){next;}

      my @d2=split(/:/, $id_sentence[0]);  #原文書の文ID
      my $gsid=$d2[1];

      if(exists($hash{$gsid})){
        print $out encode_utf8("$label $filename:$sid $sentence\n");
        $sid++;
      }

    }#文単位
    undef %hash;

  }#file単位

}

sub replaceNamedEntity{
  my $sentence=$_[0];
  my $mecab_results = decode_utf8($c->parse($sentence));
  my @POS = split(/\n/,$mecab_results);
  foreach my $wordAndInfo(@POS){
    next if($wordAndInfo!~"固有名詞");
    my @wordAndInfoList=split(/\t/, $wordAndInfo);
    my $namedEntity=$wordAndInfoList[0];
    $sentence=~s/$namedEntity/*/;
  }
  return $sentence;
}