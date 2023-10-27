#!/usr/bin/perl

use strict;
use Encode;
use utf8;
use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

main();

sub main(){
  open(my $in, "<", "../../data.list/label.list");
  my $averageTfidf=0;
  my $N=0;
  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);
    my @filename_label=split(/,/, $line);
    if($#filename_label==0){next;}

    my $filename=$filename_label[0];    #filename
    my $label=[split(/ /, $filename_label[1])]->[0];       #label

    my %tfidf=load_tfidf($filename);   #tfidf値の読み込み

    open(my $in2, "<", "../../TDNET/mk_txt/txt2/$filename");
    while(my $str=decode_utf8(<$in2>)){      #文単位のループ
      chomp($str);
      my $sentence=[split(/ /, $str)]->[1];
      $sentence=~s/[[:cntrl:]]//g;
      $sentence=~s/\a//g;
      $sentence=~s/\f//g;
      $sentence=~s/\r//g;
      $sentence=~s/\0//g;
      $sentence=~s/\v//g;
      $sentence=~s/\b//g;
      $sentence=~s/\t//g;
      $sentence=~s/　//g;
      $sentence=~s/\s//g;
      $sentence=~s/[\s　]//g;
      $sentence=~s/ //g;
      my $str_utf8=encode_utf8($sentence);
      if($sentence eq ""){next;}

      #tf-idfの計算
      my $sum_tfidf=0;
      my $mecab_results=decode_utf8($c->parse($str_utf8));
      my @split_result=split(/\n/, $mecab_results);
      foreach my $word_info(@split_result){
        if($word_info eq "EOS"){next;}
        my $word=[split(/\t/, $word_info)]->[0];
        $sum_tfidf+=$tfidf{$word};
      }
      if($sum_tfidf==0){next;}
      $averageTfidf=($averageTfidf*$N+$sum_tfidf)/($N+1);
      $N++;
      print("N=$N : average=$averageTfidf\n");
    }#文単位
    undef %tfidf;
  }#file単位
  print("\nEOC\nN=$N : average=$averageTfidf\n");
}

sub load_tfidf{
  my $filename=$_[0];
  my %tfidf;

  open(my $in, "<", "../../data.list/tfidf.list");
  my $flag=0;
  while(my $line=decode_utf8(<$in>)){
    if($flag==1 && $line!~"\t"){last;}
    if($line=~$filename){$flag=1; next;}
    if($flag){
      my @word_tfidf=split(/: /, $line);
      $word_tfidf[0]=~s/\t//g;
      $tfidf{$word_tfidf[0]}=$word_tfidf[1];
    }
  }
  close($in);
  return %tfidf;
}