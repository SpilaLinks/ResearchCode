#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
   open(my $out, ">", "../../data.list/label_0.list"); 
   open(my $in, "<", "../../data.list/label.list");
   while(my $l=decode_utf8(<$in>)){     #label.listのループ
       chomp($l);
       if($l !~ "上場会社の決定事実"){next;}
       my $filename=[split(/,/, $l)]->[0];
       my $file="../../TDNET/mk_txt/txt2/".$filename;
       open(my $in2, $file);
       my $k=0;
       my $flag=0;     #ラベル付いたならループ終了のflag
       my $japanese=0; #日本語が含まれているかどうか
       while(my $line=decode_utf8(<$in2>)){       #1行単位のループ、ラベル付
         if($k==5){last;}   ####先頭5行のみ探索
         else{$k++;}
         if($line==""){last;}
	     chomp($line);

	       #[文字列マッチング]
        if(($line=~/.*新株式発行.*(お知らせ|について).*/) || ($line=~/.*株式.*売出し.*(お知らせ|について).*/) || ($line=~/.*新株予約権付社債.*発行条件.*(お知らせ|について).*/) || ($line=~/.*第三者割当.*発行.*(お知らせ|について).*/) || ($line=~/.*第三者割当.*処分.*(お知らせ|について).*/)  || ($line=~/.*株式報酬.*新株式発行.*(お知らせ|について).*/)){print $out encode_utf8("$filename 0\n"); $flag++; last;}#1
        if(($line=~/,*新株式発行.*発行登録.*(お知らせ|について).*/)||($line=~/.*需要状況.*調査.*(お知らせ|について).*/)){print $out encode_utf8("$filename 1\n"); $flag++; last;}#2
        if(($line=~/.*資本金.*減少.*(お知らせ|について).*/)||($line=~/.*減資.*(お知らせ|について).*/)){print $out encode_utf8("$filename 2\n"); $flag++; last;} #3
        if(($line=~/.*資本準備金.*減少.*(お知らせ|について).*/) || ($line=~/.*利益準備金.*減少.*(お知らせ|について).*/)){print $out encode_utf8("$filename 3\n"); $flag++; last;} #4
        if(($line=~/.*自己株式.*取得.*(お知らせ|について).*/)||($line=~/.*自己株式.*買付け.*(お知らせ|について).*/)){print $out encode_utf8("$filename 4\n"); $flag++; last;} #5
        if(($line=~/.*株式.*無償割当て.*(お知らせ|について).*/)||($line=~/.*新株予約権.*無償割当て.*(お知らせ|について).*/)||($line=~/.*ライツ・オファリング.*(お知らせ|について).*/)){print $out encode_utf8("$filename 5\n"); $flag++; last;} #6
        if(($line=~/.*新株予約権無償割当て.*発行登録.*(お知らせ|について).*/) || ($line=~/.*需要状況.*見込み.*調査.*(お知らせ|について).*/)||($line=~/.*権利行使.*見込み.*調査.*(お知らせ|について).*/)){print $out encode_utf8("$filename 6\n"); $flag++; last;} #7
        if(($line=~/.*株式.*分割.*(お知らせ|について).*/)||($line=~/.*株式.*併合.*(お知らせ|について).*/)){print $out encode_utf8("$filename 7\n"); $flag++; last;} #8
        if($line=~/.*剰余金.*配当.*(お知らせ|について).*/){print $out encode_utf8("$filename 8\n"); $flag++; last;} #9
        if($line=~/.*合併契約.*締結.*(お知らせ|について).*/){print $out encode_utf8("$filename 9\n"); $flag++; last;} #10
        if(($line=~/.*公開買付け.*開始.*(お知らせ|について).*/)||($line=~/.*意見表明報告書.*回答.*(お知らせ|について).*/)||($line=~/.*公開買付け.*結果.*(お知らせ|について).*/)||($line=~/.*自己株式.*公開買付け.*(お知らせ|について).*/)){print $out encode_utf8("$filename 10\n"); $flag++; last;} #11
        if(($line=~/.*公開買付け.*意見表明.*(お知らせ|について).*/)||($line=~/.*ＭＢＯ.*実施.*(お知らせ|について).*/)){print $out encode_utf8("$filename 11\n"); $flag++; last;} #12
        if(($line=~/.*事業.*譲渡.*(お知らせ|について).*/) || ($line=~/.*事業.*譲受け.*(お知らせ|について).*/)){print $out encode_utf8("$filename 12\n"); $flag++; last;} #13
        if($line=~/.*会社.*解散.*(お知らせ|について).*/){print $out encode_utf8("$filename 13\n"); $flag++; last;} #14
        if($line=~/.*企業化.*(お知らせ|について).*/){print $out encode_utf8("$filename 14\n"); $flag++; last;} #15
        if($line=~/.*業務提携.*(お知らせ|について).*/){print $out encode_utf8("$filename 15\n"); $flag++; last;} #16
        if(($line=~/.*株式.*譲渡.*(お知らせ|について).*/) || ($line=~/.*株式取得.*(子|孫)会社化.*(お知らせ|について).*/)){print $out encode_utf8("$filename 16\n"); $flag++; last;} #17
        if(($line=~/.*固定資産.*取得.*(お知らせ|について).*/)||($line=~/.*固定資産.*譲渡.*(お知らせ|について).*/)||($line=~/.*リース.*固定資産.*(お知らせ|について).*/)){print $out encode_utf8("$filename 17\n"); $flag++; last;} #18
        if(($line=~/.*事業.*休止.*(お知らせ|について).*/)||($line=~/.*部門.*廃止.*(お知らせ|について).*/)){print $out encode_utf8("$filename 18\n"); $flag++; last;} #19
        if($line=~/.*当社株式.*上場廃止.*(お知らせ|について).*/){print $out encode_utf8("$filename 19\n"); $flag++; last;} #20
        if(($line=~/.*破産手続開始.*申立.*(お知らせ|について).*/)||($line=~/.*再生手続開始.*申立.*(お知らせ|について).*/)||($line=~/.*更生手続開始.*申立.*(お知らせ|について).*/)){print $out encode_utf8("$filename 20\n"); $flag++; last;} #21
        if($line=~/.*新.*事業.*開始.*(お知らせ|について).*/){print $out encode_utf8("$filename 21\n"); $flag++; last;}#22
        if(($line=~/.*代表取締役.*異動.*(お知らせ|について).*/) || ($line=~/.*代表執行役.*異動.*(お知らせ|について).*/)){print $out encode_utf8("$filename 22\n"); $flag++; last;} #23
        if($line=~/.*希望退職者.*募集.*(お知らせ|について).*/){print $out encode_utf8("$filename 23\n"); $flag++; last;} #24
        if(($line=~/.*商号.*変更.*(お知らせ|について).*/) || ($line=~/.*名称.*変更.*(お知らせ|について).*/)){print $out encode_utf8("$filename 24\n"); $flag++; last;} #25
        if($line=~/.*単元株式数.*変更.*(お知らせ|について).*/){print $out encode_utf8("$filename 25\n"); $flag++; last;} #26
        if($line=~/.*決算期.*変更.*(お知らせ|について).*/){print $out encode_utf8("$filename 26\n"); $flag++; last;} #27
        if($line=~/.*内閣総理大臣.*申出.*(お知らせ|について).*/){print $out encode_utf8("$filename 27\n"); $flag++; last;}#28
        if($line=~/.*調停開始.*申立.*(お知らせ|について).*/){print $out encode_utf8("$filename 28\n"); $flag++; last;}#29
        if(($line=~/.*期限前償還.*(お知らせ|について).*/)||($line=~/.*社債権者集会.*招集.*(お知らせ|について).*/)){print $out encode_utf8("$filename 29\n"); $flag++; last;} #30
        if($line=~/.*公認会計士.*異動.*(お知らせ|について).*/){print $out encode_utf8("$filename 30\n"); $flag++; last;}#31
        if($line=~/.*継続企業.*前提.*(お知らせ|について).*/){print $out encode_utf8("$filename 31\n"); $flag++; last;}#32
        if($line=~/.*提出期限延長.*承認申請書.*(お知らせ|について).*/){print $out encode_utf8("$filename 32\n"); $flag++; last;} #33
        if($line=~/.*株式事務.*委託.*取止め.*(お知らせ|について).*/){print $out encode_utf8("$filename 33\n"); $flag++; last;} #34
        if($line=~/.*内部統制報告書.*(お知らせ|について).*/){print $out encode_utf8("$filename 34\n"); $flag++; last;} #35
        if($line=~/.*定款.*変更.*(お知らせ|について).*/){print $out encode_utf8("$filename 35\n"); $flag++; last;} #36
        if($line=~/.*全部取得条項付種類株式.*取得.*(お知らせ|について).*/){print $out encode_utf8("$filename 36\n"); $flag++; last;} #37
        if($line=~/.*特別支配株主.*承認.*(お知らせ|について).*/){print $out encode_utf8("$filename 37\n"); $flag++; last;}  
       } #while 1行

       if($japanese==0){next;}
       if($flag==0){print $out encode_utf8("$filename,\n");}
   }
   close($in);

   open(my $in, "<", "../../data.list/bert_label.list");
   while(my $l=decode_utf8(<$in>)){
    chomp($l);
    if($l!~"上場会社の決定事実"){next;}
    my $filename=[split(/ /, $l)]->[0];
    print $out encode_utf8("$filename\n");
   }
}
