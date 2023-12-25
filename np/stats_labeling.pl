#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
    my %hash;
    open(my $in, "<", "../../data.list/label_0.list");
    while(my $line=decode_utf8(<$in>)){
        chomp($line);
        my @data=split(/ /, $line);
        if($#data==0){next;}
        $hash{$data[1]}++;
    }

    my $sum=0;
    for(my $i=0; $i<38; $i++){
        print("$i : $hash{$i}\n");
        $sum+=$hash{$i};
    }
    print("$sum\n");
}