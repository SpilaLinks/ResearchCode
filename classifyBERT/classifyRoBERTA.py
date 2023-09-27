#!/usr/bin/python3

import os
os.environ["http_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
os.environ["https_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
# os.environ["CUDA_VISIBLE_DEVICES"]="-1"

from collections import defaultdict
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support

import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer, AutoConfig
from transformers import pipeline

BERT_MODEL = "rinna/japanese-roberta-base"

tokenizer = AutoTokenizer.from_pretrained(BERT_MODEL,use_fast=False)

config = AutoConfig.from_pretrained(BERT_MODEL)
model = AutoModelForSequenceClassification.from_pretrained(BERT_MODEL, config=config)
model = model.from_pretrained("./modelR/")

def main():

    tc_pipeline = pipeline("text-classification", model=model, tokenizer=tokenizer, config=config, truncation=True, device=0)

    with open('test.list') as reader:
        lines = reader.read().split('\n')

    fp = open("output", mode="w")

    for line in lines:
        if line.strip() == '':
            fp.write("FINE\n")
            continue
        sent_id, sequence = line.split(" ",maxsplit=1)

        try:
            pred = tc_pipeline(sequence)
        except:
            fp.write("GOOG\n")
            continue

        label = pred[0]['label']

        # For Binary Classification
        #if label == "LABEL_1":
            #fp.write(sent_id+" "+sequence+"\n")

        # For Multi LABEL Classification
        fp.write(label+" "+sent_id+" "+sequence+"\n")

if __name__ == '__main__':
    main()
