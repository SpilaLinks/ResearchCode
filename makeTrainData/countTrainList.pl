#!/usr/bin/perl

use strict;
use Encode;
use utf8;

main();

sub main{
  my @name=("上場会社の決定事実", "上場会社の発生事実", "上場会社の決算情報", "上場会社の業績予想、配当予想の修正等", "その他の情報", "子会社等の決定事実", "子会社等の発生事実", "子会社等の業績予想の修正等", "該当なし");

  open(my $in, "<", "../../data.list/label.list") or die "can't open label.list:$!\n";
  my %hash;
  my $train=0;
  my $test=0;
  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @filename_label=split(/,/, $line);
    if($#filename_label==0){$test++; next;}
    my $label=[split(/ /, $filename_label[1])]->[0];
    $hash{$label}+=1;
    $train++;
  }

  print encode_utf8("学習データのクラスごとの文数\n");
  for(my $i=0; $i<9; $i++){
    print encode_utf8("$i $name[$i] : $hash{$i}\n");
  }
  print encode_utf8("学習データ文書数：$train\n");
  print encode_utf8("テストデータ文書数：$test\n");
}
