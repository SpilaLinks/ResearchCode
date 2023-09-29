#!/usr/bin/perl

use strict;

# 文字コード関係
use Encode;
use Encode::Detect::Detector;
use Unicode::Normalize;
use utf8;

use File::Find;
use File::Basename;

use MeCab;
my $model = new MeCab::Model();
my $c = $model->createTagger();

# 半角全角変換
use Lingua::JA::Moji qw/ascii2wide/;

# 並列処理
use Parallel::ForkManager;
my $pm = Parallel::ForkManager->new(16);

`rm -r -f ../../TDNET/mk_txt/txt2`;
`mkdir ../../TDNET/mk_txt/txt2`;

main();

sub main
{
  my $pdf_dir = "../../TDNET/pdf/";

  my @PDF_List;
  find( sub{ push(@PDF_List,$File::Find::name) if(-f $_); },$pdf_dir);

  my $core = 16;
  for(my $i=0; $i<$core; $i++)
  {
    my @PDFSubList = extractSubList(\@PDF_List,$i,$core);

    $pm->start and next;   # プロセス開始

    foreach my $pdf_file (@PDFSubList)
    {
      my @e = split(/\//,$pdf_file);

      my @sentence = getSentence($pdf_file);

      my $date = $e[4];
      my($pdf) = split(/\./,$e[5]);

      my $out_file = "../../TDNET/mk_txt/txt2/".$date."_".$pdf.".txt";

      print "$out_file\n";

      open(my $OUT,">$out_file");

      my $t= 1;
      foreach my $sent (@sentence)
      {
        my $id = $pdf.":".$t;
        print $OUT encode_utf8("$id $sent\n");

        $t++;
      }
      close($OUT);

      undef @sentence;
    }
    $pm->finish;            # プロセス終了
  }
  $pm->wait_all_children;     # 全てのプロセスが終了するまで待機
}


sub getSentence
{
  my($pdf_data) = @_;

  my @text_list = `pdftotext -layout -nopgbrk $pdf_data -`;

  my $full_text = "";
  foreach my $text_utf8 (@text_list)
  {
    my $text = decode_utf8($text_utf8);
    chomp($text);

    # UTF8に変換
    my $str_utf;
    my $exp  = '$str_utf = to_utf8($text)';
    eval($exp);

    # 半角全角変換
    my $sent = ascii2wide($str_utf);

    #英語、数字のみの塊を除去
    my $sent=replaceEnglishAndNumber($sent);

    $sent =~ s/[\s　]+//g;
    $sent =~ s/ //g;
    $sent =~ s/　//g;

    # 固有表現置き換え
    $sent=replaceNamedEntity($sent);

    $sent =~ s/^　//;
    $sent =~ s/^△//;
    $sent =~ s/^○//;
    $sent =~ s/…//g;

    # 制御コードの除去
    $sent =~ s///;
    $sent =~ s///;
    $sent =~ s///;
    $sent =~ s///;
    $sent =~ s/[[:cntrl:]]//g;

    $sent = "。" if($sent eq "");

    $full_text .= $sent;
  }
  undef @text_list;

  my @sent_list = split(/。/,$full_text);

  my @sentence;
  foreach my $sent (@sent_list)
  {
    my $len = length($sent);
    next if($len > 500);
    next if($len < 5);

    push(@sentence,$sent);
  }
  undef @sent_list;

  return @sentence;
}

sub to_utf8
{
  my($contents) = @_;

  unless (utf8::is_utf8($contents))
  {
    my $charset = detect($contents);
    $contents = decode($charset || 'shift-jis', $contents);
  }

  return NFKC($contents);
}



sub extractSubList
{
  my($ref_NikkeiSubList,$section,$core) = @_;

  my @SubList;
  my $t=0;
  foreach my $file (@{$ref_NikkeiSubList})
  {
    if($t % $core == $section)
    {
      push(@SubList,$file);
    }
    $t++;
  }

  return @SubList;
}

sub replaceNamedEntity{
  my $sentence=$_[0];
  my $mecab_results = decode_utf8($c->parse($sentence));
  my @POS = split(/\n/,$mecab_results);
  foreach my $wordAndInfo(@POS){
    next if($wordAndInfo!~"固有名詞");
    my @wordAndInfoList=split(/\t/, $wordAndInfo);
    my $namedEntity=$wordAndInfoList[0];
    $sentence=~s/$namedEntity/*/;
  }
  return $sentence;
}

sub replaceEnglishAndNumber{
  my $sentence=$_[0];
  $sentence=~s/[\s　]+/ /g;
  my @lines=split(/\n/, $sentence);
  foreach my $line(@lines){
    my @words1=split(/ /, $line);
    foreach my $word(@words1){
      if($word!~/[\p{Han}\p{Hiragana}\p{Katakana}]/){$sentence=~s/$word//g;}
    }
  }
  return $sentence;
}