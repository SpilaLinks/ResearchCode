#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main(){

  my %chash;
  $chash{0}="0:上場会社の決定事実"; $chash{1}="1:上場会社の発生事実"; $chash{2}="2:上場会社の決算情報"; $chash{3}="3:上場会社の業績予想、配当予想の修正"; $chash{4}="4:その他の情報"; $chash{5}="5:子会社等の決定事実"; $chash{6}="6:子会社等の発生事実"; $chash{7}="7:子会社等の業績予想";

  open(my $in, "../makeTestData/test.list");
  my @bunsuu;
  my @id;
  my $i=-1;

  while(my $line=decode_utf8(<$in>)){
    chomp($line);
    my @d1=split(/ /, $line);
    my @d2=split(/:/, $d1[0]);
    #foreach my $a(@d2){print("$a\n");};
    if($d2[1]==1){$i++; $id[$i]=$d2[0];}
    $bunsuu[$i]++;
  }
  close($in);


  open(my $in, "output_RoBERTA");
  my %hindo;
  my $flag=1; my $idnum=0;

  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @tmp=split(/ /, $line);
    my $label;
    if($tmp[0]eq"LABEL_0"){$label=0;}
    elsif($tmp[0]eq"LABEL_1"){$label=1;}
    elsif($tmp[0]eq"LABEL_2"){$label=2;}
    elsif($tmp[0]eq"LABEL_3"){$label=3;}
    elsif($tmp[0]eq"LABEL_4"){$label=4;}
    elsif($tmp[0]eq"LABEL_5"){$label=5;}
    elsif($tmp[0]eq"LABEL_6"){$label=6;}
    elsif($tmp[0]eq"LABEL_7"){$label=7;}

    #label足し算
    $hindo{$label}++;

    if($flag==$bunsuu[$idnum]){
      #文書の分類結果
      for my $key(sort{$hindo{$b}<=>$hindo{$a}}keys %hindo){
        print encode_utf8("$id[$idnum] $chash{$key}\n");
        last;
      }

      #パラメータリセット
      %hindo=();
      $flag=1;
      $idnum++;
      next;
    }
    $flag++;

  }#while

}
