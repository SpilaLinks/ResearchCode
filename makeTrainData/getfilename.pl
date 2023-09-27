#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
   my $home = $ENV{"HOME"};
   my $TextDir = $home."/data/TDNET/mk_txt/";
   my @TextList;
   find( sub{ push(@TextList,$File::Find::name) if(-f $_); },$TextDir);


   foreach my $file (sort @TextList){     #file単位のループ
       my @data=split(/\//, $file);      #filename
       print encode_utf8("$data[7],");

       open(my $in, $file);
       my $flag=0;     #ラベル付いたならループ終了のflag
       my $i=0;        #先頭10行(i=10)までループ
       my $sflag=0;    #子会社のflag
       while(my $line=decode_utf8(<$in>)){       #1行単位のループ、ラベル付
         if($line==""){print("empty file"); last;}
         if($i>=10){last;}
	       chomp($line);

	       #文字列マッチング

         #    〜子会社等の情報〜
	       if($line=~"子会社"){print encode_utf8("子会社の情報\n"); $flag++; last;}
	       #if($line=~"子会社"){
	           #6 子会社等の決定事実
           

	           #7 子会社等の発生事実
	           #8 子会社等の業績予想
	       #}


    	   #    〜上場会社の情報〜
	       #[1] 上場会社の決定事実
	       if($line=~(
         "募集" || "売出し" #1
         || "需要状況の調査" #2
         || "資本金" #3
         || "資本準備金" || "利益準備金" #4
         || "自己株式の取得" #5
         || "株式無償割当て" ||"新株予約権無償割当て" #6
         || "見込み調査" #7
         || "株式の分割" || "株式の併合" #8
         || "剰余金" #9
         || "組織再編" #10
         || "公開買付け" #11
         || "意見表明" #12
         || "解散" #14
         || "企業化" #15
         || "提携" #16
         || "固定資産" #18
         || "休止" || "廃止" #19
         || "上場廃止申請" #20
         || "代表取締役" || "代表執行役" #23
         || "合理化" #24
         || "商号" || "名称" #25
         || "単元株式数" #26
         || "決算期変更" #27
         || " 繰上償還" #30
         || "承認申請書" #33
         || "株式事務の委託" #34
         || "内部統制報告書" #35
         || "定款" #36
         || "全部取得条項付種類株式" #37
         )){print encode_utf8("[1]上場会社の決定事実\n"); $flag++; last;}

	       #2 上場会社の発生事実
	       if($line=~(
         "主要株主" || "筆頭株主" #2
         || "上場廃止" #3
         || "発行差止請求" #16
         || "株主総会" #17
         || "保有有価証券" #18
         || "利益の喪失" #19
         || "提出遅延" #22
         || "提出期限延長申請" #23
         || "監査報告書" #24 25
         || "株式事務代行委託契約の解除通知" #26
         )){print encode_utf8("[2]上場会社の発生事実\n"); $flag++; last;}

	       #3 上場会社の決算情報
	       if($line=~"決算短信"){print encode_utf8("[3]上場会社の決算情報\n"); $flag++; last;}

	       #4 上場会社の業績予想、配当予想の修正
	       if($line=~(
         "業績予想" || "予想値" || "決算値" #1
         || "配当予想" #2
         )){print encode_utf8("[4]上場会社の業績予想、配当予想の修正等\n"); $flag++; last;}

	       #5 その他の情報
	       if($line=~(
         "投資単位の引下げ" #1
         || "財務会計基準機構" #2
         || "MSCB" #3
         || "非上場の親会社" #5
         || "事業計画" || "成長可能性" #6
         || "上場維持基準" #7
         )){print encode_utf8("[5]その他の情報\n"); $flag++; last;}



	       $i++;
       }
       if($flag==0){print encode_utf8("\n");}
   }
}
