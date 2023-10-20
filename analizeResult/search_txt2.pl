#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main(){
    ######################
    my $searchWord="上場廃止";
    ######################
    open(my $in, "<", "../../data.list/label.list");
    while(my $line=decode_utf8(<$in>)){
        chomp($line);
        my @filename_label=split(/,/, $line);
        if($#filename_label==1){next;}
        open(my $in2, "<", "../../TDNET/mk_txt/txt2/$filename_label[0]");
        while(my $input=decode_utf8(<$in2>)){
            chomp($input);
            my $text=[split(/ /, $input)]->[1];

            if($text=~"コーポレート・ガバナンス"){last;}
            if($text=~$searchWord){print("$filename_label[0]\n"); last;}
        }
    }
}