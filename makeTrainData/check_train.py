#!/usr/bin/python3

import os
os.environ["http_proxy"] = "http://133.220.149.120:8080"
os.environ["https_proxy"] = "http://133.220.149.120:8080"
# os.environ["CUDA_VISIBLE_DEVICES"]="-1"

import numpy as np
import tensorflow as tf
import transformers

model_name = "cl-tohoku/bert-base-japanese-v2"

from transformers import BertJapaneseTokenizer
# from transformers.tokenization_bert_japanese import BertJapaneseTokenizer
tokenizer = BertJapaneseTokenizer.from_pretrained(model_name)

def main():
    sent_id, test_texts = get_sentence("train.list")

def get_sentence(input_file):

    labels = []
    sentences = []
    with open(input_file) as fp:

        for line in fp:
            print(line)
            label,sent = line.rstrip().split(" ")

            labels.append(label)
            sentences.append(sent)

    return labels, sentences


if __name__ == '__main__':
    main()
