#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();

use File::Find;

use constant OUTFILE => "train.list";
use constant THRESHOLD_TFIDF => 1;

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

    my %tfidf=load_tfidf($filename);  #tfidf値の読み込み

    open(my $in2, "../../TDNET/mk_txt/txt2/$filename");
    my $sid=1;
    while(my $str=<$in2>){      #文単位のループ
      chomp($str);
      my $string=deleteCntrL([split(/ /, $str)]->[1]);
      my $line2=decode_utf8($str);

      my @id_sentence=split(/ /, $line2);
      my $sentence=$id_sentence[1];
      $sentence=~s/[[:cntrl:]]//g;
      $sentence=~s/　//g;
      $sentence=~s/ //g;
      #$sentence=replaceNamedEntity($sentence);
      if($sentence eq ""){next;}

      #print ([split(/ /, $str)]->[1]."\n");
      my $sum=calc_total_tfidf(%tfidf, $string);
      #print encode_utf8("$sum : $sentence\n");
      if(calc_total_tfidf(%tfidf, $sentence)<THRESHOLD_TFIDF){next;}

      print $out encode_utf8("$label $filename:$sid $sentence\n");
      $sid++;
    }#文単位
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

  open(my $in, "../../data.list/tfidf.list");
  my $flag=0;
  while(my $line=decode_utf8(<$in>)){
    if($flag==1 && $line!~"\t"){last;}
    if($line=~$filename){$flag=1; next;}
    if($flag){
      my @word_tfidf=split(/: /, $line);
      $tfidf{$word_tfidf[0]}=$word_tfidf[1];
    }
  }
  close($in);
  return %tfidf;
}

sub calc_total_tfidf{
  my %tfidf=$_[0];
  my $sentence=$_[1];
  print ("$sentence\n");
  my $sum_tfidf=0;
  my $mecab_results=decode_utf8($c->parse($sentence));
  my @split_result=split(/\n/, $mecab_results);
  foreach my $word_info(@split_result){
    if($word_info eq "EOS"){last;}
    my $word=[split(/\t/, $word_info)]->[0];
    #print encode_utf8("$word\n");
    $sum_tfidf+=$tfidf{$word};
  }
  return $sum_tfidf;
}

sub deleteCntrL{
  $_[0]=~s/[[:cntrl:]]//g;
  $_[0]=~s/　//g;
  $_[0]=~s/ //g;
  return $_[0];
}