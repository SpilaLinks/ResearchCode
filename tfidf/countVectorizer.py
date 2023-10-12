#!/usr/bin/python3
import numpy as np
import os
os.environ["http_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
os.environ["https_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
#os.environ["CUDA_VISIBLE_DEVICES"]="-1"

from sklearn.feature_extraction.text import TfidfVectorizer
import glob

def main():
    filepaths=glob.glob('../../TDNET/mk_txt/txt2/*')
    docs=[]
    for path in filepaths:
        oneFileTxt=[]
        with open(path) as f:
            for inputLine in f:
                splitLine=inputLine.split(' ', 1)
                oneFileTxt+=(splitLine[1]+'\n')
        docs.append(oneFileTxt)
    vectorizer=TfidfVectorizer(max_df=0.9)
    X=vectorizer.fit_transform(docs)

    print('feature_names:', vectorizer.get_feature_names())
    words=vectorizer.get_feature_names()
    for doc_id, vec in zip(range(len(docs)), X.toarray()):
        print('doc_id:', doc_id)
        for w_id, tfidf in sorted(enumerate(vec), key=lambda x: x[1], reverse=True):
            if tfidf<=0:
                continue
            lemma=words[w_id]
            print('\t{0:s}: {1:f}'.format(lemma, tfidf))

if __name__=="__main__":
    main()