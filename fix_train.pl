#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main(){
  open(my $in, "tmp.list");
  my $i=0;
  while(my $line=decode_utf8(<$in>)){
    chomp($line);
    my @data=split(/ /, $line);
    my $len=@data;

    if($data[2] eq (''||' '||'　'||'\n')){$i++;}
    #print encode_utf8("$data[2]\n");
    #if($len==2){print encode_utf8("2\n");}

    print encode_utf8("$line\n");
  }
  #print ("$i\n")
}
