#!/usr/bin/perl

use strict;
use Encode;
use utf8;
use MeCab;
my $model=new MeCab::Model();
my $c=$model->createTagger();
use File::Find;

main();

sub main(){
    my $TextDir = "../../TDNET/mk_txt/txt2";
    my @TextList;
    find( sub{ push(@TextList,$File::Find::name) if(-f $_); },$TextDir);

    foreach my $file(@TextList){
        print $file;
        open(my $in, $file);
        $filename=[split(/\//, $file)]->[5];
        open(my $out, ">../../data.list/wakati/$filename");
        while(my $line=<$in>){
            chomp($line);
            my $txt=[split(/ /, $line)]->[1];
            my $mecab_results=decode_utf8($c->parse($txt));
            my @pos=split(/\n/, $mecab_results);
            foreach my $wordAndInfo(@pos){
                if($wordAndInfo=~"名詞"){print $out encode_utf8([split(/\t/, $wordAndInfo)]->[0])+" "}
            }
        }
    }
}