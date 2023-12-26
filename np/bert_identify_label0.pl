#!/usr/bin/perl

use strict;
use Encode;
use utf8;

use File::Find;

main();

sub main(){

  my %chash;
  $chash{0}="0:発行する株式、処分する自己株式、発行する新株予約権、処分する自己新株予約権を引き受ける者の募集又は株式、新株予約権の売出し"; $chash{1}="1:発行登録及び需要状況調査の開始"; $chash{2}="2:資本金の額の減少"; $chash{3}="3:資本準備金又は利益準備金の額の減少"; $chash{4}="4:自己株式の取得"; $chash{5}="5:株式無償割当て又は新株予約権無償割当て"; $chash{6}="6:新株予約権無償割当てに係る発行登録及び需要状況・権利行使の見込み調査の開始"; $chash{7}="7:株式の分割又は併合"; $chash{8}="8:剰余金の配当";
  $chash{9}="9:合併等の組織再編行為"; $chash{10}="10:公開買付け又は自己株式の公開買付け"; $chash{11}="11:公開買付け等に関する意見表明等"; $chash{12}="12:事業の全部又は一部の譲渡又は譲受け"; $chash{13}="13:解散（合併による解散を除く。）"; $chash{14}="14:新製品又は新技術の企業化"; $chash{15}="15:業務上の提携又は業務上の提携の解消"; $chash{16}="16:子会社等の異動を伴う株式又は持分の譲渡又は取得その他の子会社等の異動を伴う事項"; $chash{17}="17:固定資産の譲渡又は取得、リースによる固定資産の賃貸借"; $chash{18}="18:事業の全部又は一部の休止又は廃止";
  $chash{19}="19:上場廃止申請"; $chash{20}="20:破産手続開始、再生手続開始又は更生手続開始の申立て"; $chash{21}="21:新たな事業の開始"; $chash{22}="22:代表取締役又は代表執行役の異動"; $chash{23}="23:人員削減等の合理化"; $chash{24}="24:商号又は名称の変更"; $chash{25}="25:単元株式数の変更又は単元株式数の定めの廃止若しくは新設"; $chash{26}="26:決算期変更（事業年度の末日の変更）"; $chash{27}="27:債務超過又は預金等の払戻の停止のおそれがある旨の内閣総理大臣への申出（預金保険法第74条第5項の規定による申出）";
  $chash{28}="28:特定調停法に基づく特定調停手続による調停の申立て"; $chash{29}="29:上場債券等の繰上償還又は社債権者集会の招集その他上場債券等に関する権利に係る重要な事項"; $chash{30}="30:公認会計士等の異動"; $chash{31}="31:継続企業の前提に関する事項の注記"; $chash{32}="32:有価証券報告書・四半期報告書の提出期限延長に関する承認申請書の提出"; $chash{33}="33:株式事務代行機関への株式事務の委託の取止め"; $chash{34}="34:開示すべき重要な不備、評価結果不表明の旨を記載する内部統制報告書の提出"; $chash{35}="35:定款の変更";
  $chash{36}="36:全部取得条項付種類株式の全部の取得"; $chash{37}="37:特別支配株主による株式等売渡請求に係る承認又は不承認";

  open(my $out, ">", "../../data.list/bert_label_label0.list");
  open(my $in, "<", "../../data.list/test_label0.list");
  my @bunsuu;
  my @id;
  my $i=-1;

  while(my $line=decode_utf8(<$in>)){
    chomp($line);
    my @d1=split(/ /, $line);
    my @d2=split(/:/, $d1[0]);
    if($d2[1]==1){$i++; $id[$i]=$d2[0];}
    $bunsuu[$i]++;
  }
  close($in);


  open(my $in, "<", "../../data.list/output_label0");
  my %yudo;
  my $flag=1; my $idnum=0;

  while(my $line=decode_utf8(<$in>)){
      chomp($line);
	#尤度の足し算
	    my @data=split(/ /, $line);
	    for(my $j=0; $j<=$#data; $j++){$yudo{$j}+=$data[$j];}

	    if($flag==$bunsuu[$idnum]){
        foreach my $key(keys %yudo){  #平均値の計算
          $yudo{$key}/=$flag;
        }

	      for my $key(reverse sort{$yudo{$a}<=>$yudo{$b}}keys %yudo){  #分類結果
		      print $out encode_utf8("$id[$idnum] $chash{$key}\n");
		      last;
        }

	    #値のリセット
	      %yudo=();
	      $flag=1;
	      $idnum++;
	      next;
      }
	    $flag++;
    }


=pod
  while(my $line=decode_utf8(<$in>)){
    chomp($line);

    my @tmp=split(/ /, $line);
    my $label;
    if($tmp[0]eq"LABEL_0"){$label=0;}
    elsif($tmp[0]eq"LABEL_1"){$label=1;}
    elsif($tmp[0]eq"LABEL_2"){$label=2;}
    elsif($tmp[0]eq"LABEL_3"){$label=3;}
    elsif($tmp[0]eq"LABEL_4"){$label=4;}
    elsif($tmp[0]eq"LABEL_5"){$label=5;}
    elsif($tmp[0]eq"LABEL_6"){$label=6;}
    elsif($tmp[0]eq"LABEL_7"){$label=7;}
    elsif($tmp[0]eq"LABEL_8"){$label=8;}
    elsif($tmp[0]eq"LABEL_9"){$label=9;}
    elsif($tmp[0]eq"LABEL_10"){$label=10;}
    elsif($tmp[0]eq"LABEL_11"){$label=11;}
    elsif($tmp[0]eq"LABEL_12"){$label=12;}
    elsif($tmp[0]eq"LABEL_13"){$label=13;}
    elsif($tmp[0]eq"LABEL_14"){$label=14;}
    elsif($tmp[0]eq"LABEL_15"){$label=15;}
    elsif($tmp[0]eq"LABEL_16"){$label=16;}
    elsif($tmp[0]eq"LABEL_17"){$label=17;}
    elsif($tmp[0]eq"LABEL_18"){$label=18;}
    elsif($tmp[0]eq"LABEL_19"){$label=19;}
    elsif($tmp[0]eq"LABEL_20"){$label=20;}
    elsif($tmp[0]eq"LABEL_21"){$label=21;}
    elsif($tmp[0]eq"LABEL_22"){$label=22;}
    elsif($tmp[0]eq"LABEL_23"){$label=23;}
    elsif($tmp[0]eq"LABEL_24"){$label=24;}
    elsif($tmp[0]eq"LABEL_25"){$label=25;}
    elsif($tmp[0]eq"LABEL_26"){$label=26;}
    elsif($tmp[0]eq"LABEL_27"){$label=27;}
    elsif($tmp[0]eq"LABEL_28"){$label=28;}
    elsif($tmp[0]eq"LABEL_29"){$label=29;}
    elsif($tmp[0]eq"LABEL_30"){$label=30;}
    elsif($tmp[0]eq"LABEL_31"){$label=31;}
    elsif($tmp[0]eq"LABEL_32"){$label=32;}
    elsif($tmp[0]eq"LABEL_33"){$label=33;}
    elsif($tmp[0]eq"LABEL_34"){$label=34;}
    elsif($tmp[0]eq"LABEL_35"){$label=35;}
    elsif($tmp[0]eq"LABEL_36"){$label=36;}
    elsif($tmp[0]eq"LABEL_37"){$label=37;}

    #label足し算
    $hindo{$label}++;

    if($flag==$bunsuu[$idnum]){
      #文書の分類結果
      for my $key(sort{$hindo{$b}<=>$hindo{$a}}keys %hindo){
        print encode_utf8("$id[$idnum] $chash{$key}\n");
        last;
      }

      #パラメータリセット
      %hindo=();
      $flag=1;
      $idnum++;
      next;
    }
    $flag++;

  }#while

=cut
}
