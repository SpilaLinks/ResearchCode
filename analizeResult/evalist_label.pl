#!/usr/bin/perl

use strict;
use Encode;
use utf8;

main();

sub main(){
    open(my $in, "<", "eva_100file.list");
    while(my $line=decode_utf8(<$in>)){
        chomp($line);
        my @data=split(/ /, $line);
        if($#data!=2){
            if($line=~/\d{1}\..*/){print encode_utf8("$line\n");}
            next;
        }
        my $filename=$data[1];
        open(my $in2, "<", "../../data.list/bert_label.list");
        my $flag=0;
        while(my $input=decode_utf8(<$in2>)){
            chomp($input);
            if([split(/ /, $input)]->[0] ne $filename){next;}
            print encode_utf8("$input\n");
            $flag=1;
        }
        if($flag==0){print("$filename is train-data file\n");}
    }
}