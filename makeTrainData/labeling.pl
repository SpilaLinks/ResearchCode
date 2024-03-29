#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
   my $TextDir = "../../TDNET/mk_txt/txt2";
   my @TextList;
   find( sub{ push(@TextList,$File::Find::name) if(-f $_); },$TextDir);
   open(my $out, ">../../data.list/label.list");
   foreach my $file (sort @TextList){     #file単位のループ
       my @data=split(/\//, $file);      #filename

       open(my $in, $file);

       my $k=0;
       my $flag=0;     #ラベル付いたならループ終了のflag
       my $japanese=0; #日本語が含まれているかどうか

       while(my $line=decode_utf8(<$in>)){       #1行単位のループ、ラベル付
         if($k==7){last;}   ####先頭5行のみ探索
         else{$k++;}
         if($line==""){last;}
	       chomp($line);
         if($line=~/[\p{Han}\p{Hiragana}\p{Katakana}]/){$japanese=1;}
         else{next;}

	       #[文字列マッチング]

        # [5]該当なし
        if(($line=~/コーポレートガバナンス/ && $k<=1) #先頭1行までしか見ない
        ||($line=~/Ｎｅｗｓ　Ｒｅｌｅａｓｅ/i && $k<=1) #先頭1行までしか見ない
        ||($line=~/.*ＥＴＦ.*日々の開示事項/ && $k<=3)){ #先頭3行までしか見ない
          print $out encode_utf8("$data[5],5 該当なし\n"); $flag++; last;
        }
        # [4]その他の情報
        if(($line=~/.*投資単位.*引下げ.*(お知らせ|について).*/) #1
        ||($line=~/.*財務会計基準機構.*加入.*(お知らせ|について).*/) #2
        ||($line=~/.*(新株予約権|新株予約権付社債).*(大量行使|行使.*状況).*.*(お知らせ|について).*/)#3
        ||($line=~/.*支配株主.*事項.*(お知らせ|について).*/)#4
        ||($line=~/.*親会社.*決算.*(お知らせ|について).*/) #5
        ||($line=~/.*経営計画.*策定.*(お知らせ|について).*/) #6
        ||($line=~/.*上場維持基準.*計画.*(お知らせ|について).*/) #7
        ){print $out encode_utf8("$data[5],4 その他の情報\n"); $flag++; last;}
        # [3]上場会社の業績予想、配当予想の修正
        if(($line=~/.*業績予想.*修正.*(お知らせ|について).*/) #1
        ||($line=~/.*業績予想.*差異.*(お知らせ|について).*/)
        ||($line=~/.*配当予想.*修正.*(お知らせ|について).*/) #2
        ){print $out encode_utf8("$data[5],3 上場会社の業績予想、配当予想の修正等\n"); $flag++; last;}
        # [2]上場会社の決算情報
        if($line=~/.*決算短信.*(〔日本基準〕|（ＲＥＩＴ）).*/ && $k<=3){     #クラス2は先頭3行までしか見ない
          print $out encode_utf8("$data[5],2 上場会社の決算情報\n"); $flag++; last;
        }
        # [1]上場会社の発生事実
        if(
        ($line=~/.*(営業|営業外|特別)損失.*計上.*(お知らせ|について).*/)||($line=~/.*損害.*発生.*(お知らせ|について).*/)||($line=~/.*商品.*自主回収.*(お知らせ|について).*/)||($line=~/.*有価証券評価損.*(お知らせ|について).*/)#1
        ||($line=~/.*主要株主.*異動.*(お知らせ|について).*/) #2
        ||($line=~/.*上場廃止基準.*抵触.*(お知らせ|について).*/) #3
        ||($line=~/.*訴訟.*提起.*(お知らせ|について).*/)||($line=~/.*訴訟.*解決.*(お知らせ|について).*/)#4
        ||($line=~/.*仮処分命令.*申立.*(お知らせ|について).*/)||($line=~/.*仮処分命令.*決定.*(お知らせ|について).*/)#5
        ||($line=~/.*行政処分.*(お知らせ|について).*/)#6
        ||($line=~/.*親会社.*異動.*(お知らせ|について).*/)||($line=~/.*支配株主.*異動.*(お知らせ|について).*/)||($line=~/.*関係会社.*異動.*(お知らせ|について).*/)#7
        ||($line=~/.*破産手続.*開始.*(お知らせ|について).*/)||($line=~/.*再生手続.*開始.*(お知らせ|について).*/)||($line=~/.*更生手続.*開始.*(お知らせ|について).*/)||($line=~/.*企業担保権.*実行.*(お知らせ|について).*/)#8
        ||($line=~/.*約束手形.*不渡り.*(お知らせ|について).*/)#9
        ||($line=~/.*(親|孫)会社.*破産手続.*開始.*(お知らせ|について).*/)||($line=~/.*(親|孫)会社.*再生手続.*開始.*(お知らせ|について).*/)||($line=~/.*(親|孫)会社.*更生手続.*開始.*(お知らせ|について).*/)||($line=~/.*(親|孫)会社.*企業担保権.*実行.*(お知らせ|について).*/)#10
        ||($line=~/.*債権.*取立不能.*(お知らせ|について).*/)||($line=~/.*債権.*取立遅延.*(お知らせ|について).*/)#11
        ||($line=~/.*取引先.*取引停止.*(お知らせ|について).*/)#12
        ||($line=~/.*債務免除.*金融支援.*(お知らせ|について).*/)#13
        ||($line=~/.*資源.*発見.*(お知らせ|について).*/)#14
        ||($line=~/.*特別支配株主.*株式等売渡請求.*(お知らせ|について).*/)#15
        ||($line=~/.*新株式発行.*差止め.*(お知らせ|について).*/) #16
        ||($line=~/.*株主総会.*招集.*(お知らせ|について).*/) #17
        ||($line=~/.*有価証券.*含み損.*(お知らせ|について).*/) #18
        ||($line=~/.*社債.*利益.*喪失.*(お知らせ|について).*/) #19
        ||($line=~/.*報告書.*提出遅延.*(お知らせ|について).*/) #22
        ||($line=~/.*報告書.*提出期限延長申請.*(お知らせ|について).*/) #23
        ||($line=~/.*監査報告書.*不適正意見.*(お知らせ|について).*/) #24
        ||($line=~/.*報告書.*提出期限.*延長.*承認.*/)#25
        ||($line=~/.*株式事務代行委託契約.*解除通知.*(お知らせ|について).*/) #26
        ){print $out encode_utf8("$data[5],1 上場会社の発生事実\n"); $flag++; last;}
        # [0]上場会社の決定事実
        if((
        ($line=~/.*新株式発行.*(お知らせ|について).*/) || ($line=~/.*株式.*売出し.*(お知らせ|について).*/) || ($line=~/.*新株予約権付社債.*発行条件.*(お知らせ|について).*/)
        || ($line=~/.*第三者割当.*発行.*(お知らせ|について).*/) || ($line=~/.*第三者割当.*処分.*(お知らせ|について).*/)
          || ($line=~/.*株式報酬.*新株式発行.*(お知らせ|について).*/)#1
          || ($line=~/,*新株式発行.*発行登録.*(お知らせ|について).*/)||($line=~/.*需要状況.*調査.*(お知らせ|について).*/) #2
          || ($line=~/.*資本金.*減少.*(お知らせ|について).*/)||($line=~/.*減資.*(お知らせ|について).*/) #3
          || ($line=~/.*資本準備金.*減少.*(お知らせ|について).*/) || ($line=~/.*利益準備金.*減少.*(お知らせ|について).*/) #4
          || ($line=~/.*自己株式.*取得.*(お知らせ|について).*/)||($line=~/.*自己株式.*買付け.*(お知らせ|について).*/) #5
          || ($line=~/.*株式.*無償割当て.*(お知らせ|について).*/)||($line=~/.*新株予約権.*無償割当て.*(お知らせ|について).*/)||($line=~/.*ライツ・オファリング.*(お知らせ|について).*/) #6
          || ($line=~/.*新株予約権無償割当て.*発行登録.*(お知らせ|について).*/)
          || ($line=~/.*需要状況.*見込み.*調査.*(お知らせ|について).*/)||($line=~/.*権利行使.*見込み.*調査.*(お知らせ|について).*/) #7
          || ($line=~/.*株式.*分割.*(お知らせ|について).*/)||($line=~/.*株式.*併合.*(お知らせ|について).*/) #8
          || ($line=~/.*剰余金.*配当.*(お知らせ|について).*/) #9
          || ($line=~/.*合併契約.*締結.*(お知らせ|について).*/) #10
          || ($line=~/.*公開買付け.*開始.*(お知らせ|について).*/)||($line=~/.*意見表明報告書.*回答.*(お知らせ|について).*/)||($line=~/.*公開買付け.*結果.*(お知らせ|について).*/)||($line=~/.*自己株式.*公開買付け.*(お知らせ|について).*/) #11
          || ($line=~/.*公開買付け.*意見表明.*(お知らせ|について).*/)||($line=~/.*ＭＢＯ.*実施.*(お知らせ|について).*/) #12
          || ($line=~/.*事業.*譲渡.*(お知らせ|について).*/) || ($line=~/.*事業.*譲受け.*(お知らせ|について).*/) #13
          || ($line=~/.*会社.*解散.*(お知らせ|について).*/) #14
          || ($line=~/.*企業化.*(お知らせ|について).*/) #15
          || ($line=~/.*業務提携.*(お知らせ|について).*/) #16
          || ($line=~/.*株式.*譲渡.*(お知らせ|について).*/) || ($line=~/.*株式取得.*(子|孫)会社化.*(お知らせ|について).*/) #17
          || ($line=~/.*固定資産.*取得.*(お知らせ|について).*/)||($line=~/.*固定資産.*譲渡.*(お知らせ|について).*/)||($line=~/.*リース.*固定資産.*(お知らせ|について).*/) #18
          || ($line=~/.*事業.*休止.*(お知らせ|について).*/)||($line=~/.*部門.*廃止.*(お知らせ|について).*/) #19
          || ($line=~/.*当社株式.*上場廃止.*(お知らせ|について).*/) #20
          || ($line=~/.*破産手続開始.*申立.*(お知らせ|について).*/)||($line=~/.*再生手続開始.*申立.*(お知らせ|について).*/)||($line=~/.*更生手続開始.*申立.*(お知らせ|について).*/) #21
          || ($line=~/.*新.*事業.*開始.*(お知らせ|について).*/)#22
          || ($line=~/.*代表取締役.*異動.*(お知らせ|について).*/) || ($line=~/.*代表執行役.*異動.*(お知らせ|について).*/) #23
          || ($line=~/.*希望退職者.*募集.*(お知らせ|について).*/) #24
          || ($line=~/.*商号.*変更.*(お知らせ|について).*/) || ($line=~/.*名称.*変更.*(お知らせ|について).*/) #25
          || ($line=~/.*単元株式数.*変更.*(お知らせ|について).*/) #26
          || ($line=~/.*決算期.*変更.*(お知らせ|について).*/) #27
          || ($line=~/.*内閣総理大臣.*申出.*(お知らせ|について).*/)#28
          || ($line=~/.*調停開始.*申立.*(お知らせ|について).*/)#29
          || ($line=~/.*期限前償還.*(お知らせ|について).*/)||($line=~/.*社債権者集会.*招集.*(お知らせ|について).*/) #30
          || ($line=~/.*公認会計士.*異動.*(お知らせ|について).*/)#31
          || ($line=~/.*継続企業.*前提.*(お知らせ|について).*/)#32
          || ($line=~/.*提出期限延長.*承認申請書.*(お知らせ|について).*/) #33
          || ($line=~/.*株式事務.*委託.*取止め.*(お知らせ|について).*/) #34
          || ($line=~/.*内部統制報告書.*(お知らせ|について).*/) #35
          || ($line=~/.*定款.*変更.*(お知らせ|について).*/) #36
          || ($line=~/.*全部取得条項付種類株式.*取得.*(お知らせ|について).*/) #37
          || ($line=~/.*特別支配株主.*承認.*(お知らせ|について).*/)
          || ($line=~/.*合併契約.*締結.*(お知らせ|について).*/) #1 10 子会社決定事実  
        ) && $k<=5){print $out encode_utf8("$data[5],0 上場会社の決定事実\n"); $flag++; last;}
       } #while 1行

       if($japanese==0){next;}
       if($flag==0){print $out encode_utf8("$data[5],\n");}
   }
}
