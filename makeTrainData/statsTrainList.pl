#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
    my $l=0; my $ul=0;
    my $l1=0; my $l2=0; my $l3=0; my $l4=0; my $l5=0; my $l6=0;my $l7=0;my $l8=0;
    my $unknown=0;

    open(my $in, "../../data.list/label.list");
    while(my $line=decode_utf8(<$in>)){
	chomp($line);
	my @data=split(/,/, $line);
	if($#data==1){
	    $l++;
	    if($data[1]=~"0"){$l1++;}
	    elsif($data[1]=~"1"){$l2++;}
	    elsif($data[1]=~"2"){$l3++;}
	    elsif($data[1]=~"3"){$l4++;}
	    elsif($data[1]=~"4"){$l5++;}
      elsif($data[1]=~"5"){$l6++;}
      elsif($data[1]=~"6"){$l7++;}
      elsif($data[1]=~"7"){$l8++;}
	    else{$unknown++;print encode_utf8("$line\n");}
	}
  else{$ul++;}
    }

    print encode_utf8("label付与 : $l\nlabelなし : $ul\n");
    print encode_utf8("[0]上場会社の決定事実 : $l1\n[1]上場会社の発生事実 : $l2\n[2]上場会社の決算情報 : $l3\n[3]上場会社の業績予想、配当予想の修正等 : $l4\n[4]その他の情報 : $l5\n[5]子会社等の決定事実 : $l6\6\n[6]子会社等の発生事実 : $l7\n[7]子会社等の業績予想の修正等 : $l8\nunknown : $unknown\n");
    my $sum=$l+$ul;
    print encode_utf8("$sum\n");
}
