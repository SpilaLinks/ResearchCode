#!/usr/bin/python3
from math import log
#import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
import os
os.environ["http_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
os.environ["https_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
#os.environ["CUDA_VISIBLE_DEVICES"]="-1"
import glob
import MeCab
mecab=MeCab.Tagger('')
import re
import pandas as pd
#PATH='../../TDNET/mk_txt/txt2/*'
PATH='txt2/*'

def main():
    doc_id={}
    docs=makeDocs(doc_id)
    # モデルを生成
    vectorizer = TfidfVectorizer(smooth_idf=False)
    X = vectorizer.fit_transform(docs)

    # データフレームに表現
    values = X.toarray()
    feature_names = vectorizer.get_feature_names_out()
    pd.DataFrame(values, columns = feature_names)

    for doc_id_key, vec in zip(range(len(docs)), X.toarray()):
        print('doc_id:', doc_id[doc_id_key])
        for w_id, tfidf in sorted(enumerate(vec), key=lambda x: x[1], reverse=True):
            if tfidf==0: continue
            lemma=feature_names[w_id]
            print('\t{0:s}: {1:f}'.format(lemma, tfidf))

def makeDocs(doc_id):
    docs=[]
    doc_id_num=0

    file=open("label.list")
    for l in file:     #file単位のループ
        line=l.rstrip()
        filename_label=line.split(',')
        if filename_label[1]=="" : continue
        doc_id[doc_id_num]=filename_label[0]
        doc_id_num+=1

        #print(doc_id[doc_id_num])
        file2=open("txt2/"+doc_id[doc_id_num-1])
        oneFileWords=""
        for inputLine in file2:              #文単位
            splitLine=inputLine.split(' ', 1)
            txt=splitLine[1]
            if not re.search(r'[ぁ-ん]+|[ァ-ヴー]+|[一-龠]+', txt) : continue
            txt=txt.rstrip();       #改行削除
            txt.replace('　', '')   #制御文字削除
            txt.replace('\a', '')
            txt.replace('\f', '')
            txt.replace('\r', '')
            txt.replace('\0', '')
            txt.replace('\v', '')
            txt.replace('\b', '')
            txt.replace('\t', '')
            txt.replace('\n', '')
            if not txt : continue
            #形態素解析
            mecab_results=mecab.parse(txt)
            results=mecab_results.split('\n')
            for splitResult in results:
                if not("名詞" in splitResult): continue
                if "固有名詞" in splitResult: continue
                if not re.search(r'[ぁ-ん]+|[ァ-ヴー]+|[一-龠]+', splitResult.split('\t')[0]) : continue
                #oneFileWords.append(splitResult.split('\t')[0])
                oneFileWords+=splitResult.split('\t')[0]+" "
        oneFileWords=oneFileWords.rstrip()
        docs.append(oneFileWords)
    return docs

if __name__=="__main__":
    main()