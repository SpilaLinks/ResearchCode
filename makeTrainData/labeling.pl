#!/usr/bin/perl
#最終更新日：

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main()
{
   #my $home = $ENV{"HOME"};
   my $TextDir = "../../TDNET/mk_txt/";
   my @TextList;
   find( sub{ push(@TextList,$File::Find::name) if(-f $_); },$TextDir);

   my $kessan=0;

   open(my $out, ">kessan.list");

   foreach my $file (sort @TextList){     #file単位のループ
       my @data=split(/\//, $file);      #filename
       #print encode_utf8("$data[7],");

       open(my $in, $file);

       my $k=0;        #先頭15行のみ探索
       my $flag=0;     #ラベル付いたならループ終了のflag
       my $sflag=0;    #子会社のflag
       my $japanese=0; #日本語が含まれているかどうか

       while(my $line=decode_utf8(<$in>)){       #1行単位のループ、ラベル付
         if($k==15){last;}
         if($line==""){last;}
	       chomp($line);
         if($line=~/[\p{Han}\p{Hiragana}\p{Katakana}]/){$japanese=1;}
         else{next;}

	       #[文字列マッチング]

	       #"子会社"のワードがあればsflagをたてる
         if($line=~/子会社/ &&($line=~/お知らせ$/ || $line=~/ついて$/)){
           if($line!~"子会社化"){$sflag=1;}
         }

    	   #    〜上場会社の情報〜
         if($sflag==0){
  	       #[1] 上場会社の決定事実
  	       if(
           ($line=~"新株式発行" && $line=~"お知らせ") || ($line=~"株式の売出し") || ($line=~"新株予約権付社債"&&$line=~"発行条件")
           || ($line=~"第三者割当"&&$line=~"発行") || ($line=~"第三者割当"&&$line=~"処分")
           || ($line=~"株式報酬"&&$line=~"新株式発行")#1
           || ($line=~"新株式発行"&&$line=~"発行登録")||($line=~"需要状況"&&$line=~"調査開始") #2
           || ($line=~"資本金"&&$line=~"減少")||($line=~"減資"&&$line=~"お知らせ") #3
           || ($line=~"資本準備金"&&$line=~"減少") || ($line=~"利益準備金"&&$line=~"減少") #4
           || ($line=~"自己株式"&&$line=~"取得")||($line=~"自己株式"&&$line=~"買付け") #5
           || ($line=~"株式"&&$line=~"無償割当て")||($line=~"新株予約権"&&$line=~"無償割当て")||($line=~"ライツ・オファリング") #6
           || ($line=~"新株予約権無償割当て"&&$line=~"発行登録")
           || ($line=~"需要状況"&&$line=~"見込み"&&$line=~"調査")||($line=~"権利行使"&&$line=~"見込み"&&$line=~"調査") #7
           || ($line=~"株式"&&$line=~"分割")||($line=~"株式"&&$line=~"併合") #8
           || ($line=~"剰余金"&&$line=~"配当") #9
           || ($line=~"合併契約"&&$line=~"締結") #10
           || ($line=~"公開買付け"&&$line=~"開始")||($line=~"意見表明報告書"&&$line=~"回答")||($line=~"公開買付け"&&$line=~"結果")||($line=~"自己株式"&&$line=~"公開買付け") #11
           || ($line=~"公開買付け"&&$line=~"意見表明")||($line=~"ＭＢＯ"&&$line=~"実施") #12
           || ($line=~"事業"&&$line=~"譲渡") || ($line=~"事業"&&$line=~"譲受け") #13
           || ($line=~"会社"&&$line=~"解散") #14
           || ($line=~"企業化") #15
           || ($line=~"業務提携") #16
           || ($line=~"株式譲渡") || ($line=~"株式取得"&&$line=~"子会社化") #17
           || ($line=~"固定資産"&&$line=~"取得")||($line=~"固定資産"&&$line=~"譲渡")||($line=~"リース"&&$line=~"固定資産") #18
           || ($line=~"事業"&&$line=~"休止")||($line=~"部門"&&$line=~"廃止") #19
           || ($line=~"当社株式"&&$line=~"上場廃止") #20
           || ($line=~"破産手続開始"&&$line=~"申立")||($line=~"再生手続開始"&&$line=~"申立")||($line=~"更生手続開始"&&$line=~"申立") #21
           || ($line=~"新"&&$line=~"事業"&&$line=~"開始")#22
           || ($line=~"代表取締役"&&$line=~"異動") || ($line=~"代表執行役"&&$line=~"異動") #23
           || ($line=~"希望退職者"&&$line=~"募集") #24
           || ($line=~"商号の変更") || ($line=~"名称変更") #25
           || ($line=~"単元株式数"&&$line=~"変更") #26
           || ($line=~"決算期"&&$line=~"変更") #27
           || ($line=~"内閣総理大臣"&&$line=~"申出")#28
           || ($line=~"調停開始"&&$line=~"申立")#29
           || ($line=~"期限前償還")||($line=~"社債権者集会"&&$line=~"招集") #30
           || ($line=~"公認会計士"&&$line=~"異動")#31
           || ($line=~"継続企業の前提")#32
           || ($line=~"提出期限延長"&&$line=~"承認申請書") #33
           || ($line=~"株式事務"&&$line=~"委託"&&$line=~"取止め") #34
           || ($line=~"内部統制報告書") #35
           || ($line=~"定款"&&$line=~"変更") #36
           || ($line=~"全部取得条項付種類株式"&&$line=~"取得") #37
           || ($line=~"特別支配株主"&&$line=~"承認")
           ){print encode_utf8("$data[7],0 上場会社の決定事実\n"); $flag++; last;}

  	       #2 上場会社の発生事実
  	       if(
           ($line=~"損失"&&$line=~"計上")||($line=~"損害"&&$line=~"発生")||($line=~"不具合"&&$line=~"自主回収")||($line=~"有価証券評価損")#1
           ||($line=~"主要株主"&&$line=~"異動") #2
           ||($line=~"上場廃止基準抵触") #3
           ||($line=~"損害賠償請求訴訟"&&$line=~"提起")||($line=~"損害賠償請求訴訟"&&$line=~"解決")#4
           ||($line=~"仮処分命令"&&$line=~"申立")||($line=~"仮処分命令"&&$line=~"決定")#5
           ||($line=~"行政処分")#6
           ||($line=~"親会社"&&$line=~"異動")||($line=~"支配株主"&&$line=~"異動")||($line=~"関係会社"&&$line=~"異動")#7
           ||($line=~"破産手続開始")||($line=~"再生手続開始")||($line=~"更生手続開始")||($line=~"企業担保権"&&$line=~"実行")#8
           ||($line=~"約束手形"&&$line=~"不渡り")#9
           ||($line=~"親会社"&&$line=~"破産手続開始")||($line=~"親会社"&&$line=~"再生手続開始")||($line=~"親会社"&&$line=~"更生手続開始")||($line=~"親会社"&&$line=~"企業担保権"&&$line=~"実行")#10
           ||($line=~"債権"&&$line=~"取立不能")||($line=~"債権"&&$line=~"取立遅延")#11
           ||($line=~"取引先"&&$line=~"取引停止")#12
           ||($line=~"債務免除"&&$line=~"金融支援")#13
           ||($line=~"資源の発見")#14
           ||($line=~"特別支配株主"&&$line=~"株式等売渡請求")#15
           ||($line=~"新株式発行"&&$line=~"差止め") #16
           ||($line=~"株主総会"&&$line=~"招集") #17
           ||($line=~"有価証券含み損") #18
           ||($line=~"社債"&&$line=~"利益"&&$line=~"喪失") #19
           ||($line=~"報告書"&&$line=~"提出遅延") #22
           ||($line=~"報告書"&&$line=~"提出期限延長申請") #23
           ||($line=~"監査報告書"&&$line=~"不適正意見") #24
           ||($line=~"内部統制監査報告書"&&$line=~"意見不表明")#25
           ||($line=~"株式事務代行委託契約の解除通知") #26
           ){print encode_utf8("$data[7],1 上場会社の発生事実\n"); $flag++; last;}

  	       #3 上場会社の決算情報
  	       if($line=~"決算短信"){
             if($kessan>=100){print encode_utf8("$data[7],2 上場会社の決算情報\n"); $flag++; last;}
             $kessan++;
             print $out encode_utf8("$data[7]\n");
             last;
           }

  	       #4 上場会社の業績予想、配当予想の修正
  	       if(
           ($line=~"業績予想"&&$line=~"修正") #1
           ||($line=~"配当予想"&&$line=~"修正") #2
           ){print encode_utf8("$data[7],3 上場会社の業績予想、配当予想の修正等\n"); $flag++; last;}

  	       #5 その他の情報
  	       if(
           ($line=~"投資単位"&&$line=~"引下げ") #1
           ||($line=~"財務会計基準機構"&&"加入") #2
           ||($line=~"ＭＳＣＢ"&&$line=~"転換")||($line=~"ＭＳＣＢ"&&$line=~"行使") #3
           ||($line=~"支配株主等"&&$line=~"事項")#4
           ||($line=~"非上場の親会社") #5
           ||($line=~"事業計画"&&$line=~"事項")||($line=~"成長可能性"&&$line=~"事項") #6
           ||($line=~"上場維持基準"&&$line=~"計画") #7
           ){print encode_utf8("$data[7],4 その他の情報\n"); $flag++; last;}

           $k++;
         }
         else{       #〜子会社等の情報〜
	           #6 子会社等の決定事実
           if(
           ($line=~"合併契約"&&$line=~"締結") #1 10
           ||($line=~"公開買付け"&&$line=~"開始")||($line=~"意見表明報告書"&&$line=~"回答")||($line=~"公開買付け"&&$line=~"結果")||($line=~"自己株式"&&$line=~"公開買付け")#2 11
           ||($line=~"事業"&&$line=~"譲渡") || ($line=~"事業"&&$line=~"譲受け") #3 13
           ||($line=~"子会社"&&$line=~"解散") #4 14
           ||($line=~"企業化") #5 15
           ||($line=~"業務提携") #6 16
           ||($line=~"株式譲渡")||($line=~"株式取得"&&$line=~"孫会社化")#7 17
           ||($line=~"固定資産"&&$line=~"取得")||($line=~"固定資産"&&$line=~"譲渡")||($line=~"リース"&&$line=~"固定資産")#8 18
           ||($line=~"事業"&&$line=~"休止")||($line=~"部門"&&$line=~"廃止")#9 19
           ||($line=~"破産手続開始"&&$line=~"申立")||($line=~"再生手続開始"&&$line=~"申立")||($line=~"更生手続開始"&&$line=~"申立")#10 21
           ||($line=~"新"&&$line=~"事業"&&$line=~"開始")#11 22
           ||($line=~"商号の変更") || ($line=~"名称変更")#12 25
           ||($line=~"内閣総理大臣"&&$line=~"申出")#13 28
           ||($line=~"調停開始"&&$line=~"申立")#14 29
           ){print encode_utf8("$data[7],5 子会社等の決定事実\n"); $flag++; last;}

             #7 子会社等の発生事実
           if(
           ($line=~"損失"&&$line=~"計上")||($line=~"損害"&&$line=~"発生")||($line=~"不具合"&&$line=~"自主回収")||($line=~"有価証券評価損")#1 1
           ||($line=~"損害賠償請求訴訟"&&$line=~"提起")||($line=~"損害賠償請求訴訟"&&$line=~"解決")#2 4
           ||($line=~"仮処分命令"&&$line=~"申立")||($line=~"仮処分命令"&&$line=~"決定")#3 5
           ||($line=~"行政処分")#4 6
           ||($line=~"破産手続開始")||($line=~"再生手続開始")||($line=~"更生手続開始")||($line=~"企業担保権"&&$line=~"実行")#5 8
           ||($line=~"約束手形"&&$line=~"不渡り")#6 9
           ||($line=~"孫会社"&&$line=~"破産手続開始")||($line=~"孫会社"&&$line=~"再生手続開始")||($line=~"孫会社"&&$line=~"更生手続開始")||($line=~"孫会社"&&$line=~"企業担保権の実行")#7 10
           ||($line=~"債権"||$line=~"取立不能")||($line=~"債権"&&$line=~"取立遅延")#8 11
           ||($line=~"取引先"&&$line=~"取引停止")#9 12
           ||($line=~"債務免除"&&$line=~"金融支援")#10 13
           ||($line=~"資源の発見")#1 14
           ){print encode_utf8("$data[7],6 子会社等の発生事実\n"); $flag++; last;}

	           #8 子会社等の業績予想
           if(
           ($line=~"業績予想"&&$line=~"修正") #1
           ||($line=~"配当予想"&&$line=~"修正")#2
           ){print encode_utf8("$data[7],7 子会社等の業績予想の修正等\n"); $flag++; last;}

           $k++;
	       } #else sflag
       } #while 1行

       if($japanese==0){next;}
       if($flag==0){print encode_utf8("$data[7],\n");}
   }
}
