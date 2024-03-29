#!/usr/bin/perl

use strict;
no strict "refs";
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

my $OUTFILE="../../data.list/train.list";
my $THRESHOLD_TFIDF=0.85;

main();

sub main(){
  open(my $out, ">", $OUTFILE) or die "Can't open write-file:$!\n";
  open(my $in, "<", "../../data.list/label.list") or die "Can't open read-file:$!\n";

  while(my $line=decode_utf8(<$in>)){     #file単位のループ
    chomp($line);
    my @filename_label=split(/,/, $line);
    if($#filename_label<1){next;}

    my $filename=$filename_label[0];    #filename
    my $label=[split(/ /, $filename_label[1])]->[0];       #label

    my %tfidf=load_tfidf($filename);   #tfidf値の読み込み

    open(my $in2, "<", "../../TDNET/mk_txt/txt2/$filename") or die "Can't open txt2/xxx.txt:$!\n";
    my $sid=1;
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
      if($sum_tfidf<$THRESHOLD_TFIDF){next;}
      print $out encode_utf8("$label $filename:$sid $sentence\n");
      $sid++;
    }#文単位
    undef %tfidf;
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

sub load_tfidf{
  my $filename=$_[0];
  my %tfidf;

  open(my $in, "<", "../../data.list/tfidf.list") or die "Can't open tfidf.list:$!\n";
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