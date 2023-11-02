#!/usr/bin/perl
use strict;
use Encode;
use utf8;

main();

sub main
{
    my %chash;
    $chash{0}="0:上場会社の決定事実"; $chash{1}="1:上場会社の発生事実"; $chash{2}="2:上場会社の決算情報"; $chash{3}="3:上場会社の業績予想、配当予想の修正"; $chash{4}="4:その他の情報"; $chash{5}="5:子会社等の決定事実"; $chash{6}="6:子会社等の発生事実"; $chash{7}="7:子会社等の業績予想"; $chash{8}="8:該当なし";


    open(my $in, "<", "../../data.list/test.list");
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


    open(my $in, "<", "../../data.list/output");
    my %yudo;
    my $flag=1; my $idnum=0;

    while(my $line=decode_utf8(<$in>)){
      chomp($line);
	#尤度の足し算
	    my @data=split(/ /, $line);
	    for(my $j=0; $j<=$#data; $j++){$yudo{$j}+=$data[$j];}

	    if($flag==$bunsuu[$idnum]){
        foreach my $key(keys %yudo){  #平均値の計算
          $yudo{$key}/=$flag;
        }

	      for my $key(reverse sort{$yudo{$a}<=>$yudo{$b}}keys %yudo){  #分類結果
		      print encode_utf8("$id[$idnum] $chash{$key}\n");
		      last;
        }

	    #値のリセット
	      %yudo=();
	      $flag=1;
	      $idnum++;
	      next;
      }
	    $flag++;
    }
}
