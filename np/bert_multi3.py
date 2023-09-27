#!/usr/bin/python3

import os
import shutil
os.environ["http_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
os.environ["https_proxy"] = "http://proxy.cc.seikei.ac.jp:8080"
# os.environ["CUDA_VISIBLE_DEVICES"]="-1"

from collections import defaultdict
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score

import torch
from transformers import BertConfig, BertJapaneseTokenizer
from transformers import BertForSequenceClassification
from transformers import Trainer, TrainingArguments
from transformers import pipeline
from tqdm import tqdm

BERT_MODEL = "cl-tohoku/bert-base-japanese-v3"
DATASET_PATH = "train_label0.list"
EPOCH = 10
BACH = 32
NUM_CLASS = 38  # クラス数（２値分類なら２）

tokenizer = BertJapaneseTokenizer.from_pretrained(BERT_MODEL)

class ClassifyDataset(torch.utils.data.Dataset):

    def __init__(self, encodings, labels):
        self.encodings = defaultdict(list)
        for encoding_dict in encodings:
            for key, value in encoding_dict.items():
                self.encodings[key].append(value)
        self.labels = labels

    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item

    def __len__(self):
        return len(self.labels)


def getTrainData():

    with open(DATASET_PATH) as reader:
        dataset = reader.read().split('\n')

    encoded_sequence_list = []
    label_list = []

    for line in tqdm(dataset):
        if line.strip() == '':
            continue

        label, sent_id, sequence = line.split(" ",maxsplit=2)
        token_list = tokenizer(sequence, padding=True)

        encoded_sequence_list.append(token_list)
        label_list.append(int(label))

    return label_list, encoded_sequence_list


def compute_metrics(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)
    f1 = f1_score(labels, preds, average="weighted")
    acc = accuracy_score(labels, preds)
    return {"accuracy": acc, "f1": f1}


def main():

    label_list, encoded_sequence_list = getTrainData()

    train_encoded_sequence_list, val_encoded_sequence_list, train_label_list, val_label_list = train_test_split(encoded_sequence_list, label_list, test_size=0.2, random_state=0)

    train_dataset = ClassifyDataset(train_encoded_sequence_list, train_label_list)
    val_dataset = ClassifyDataset(val_encoded_sequence_list, val_label_list)

    config = BertConfig.from_pretrained(BERT_MODEL,num_labels=NUM_CLASS)
    model = BertForSequenceClassification.from_pretrained(BERT_MODEL, config=config)

    print(config)

    training_args = TrainingArguments(
        output_dir='./checkpoint',
        num_train_epochs=EPOCH,
        per_device_train_batch_size=BACH,
        per_device_eval_batch_size=BACH*4,
        warmup_steps=500,
        weight_decay=0.01,
        logging_dir='logs',
        evaluation_strategy = "epoch",
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        tokenizer=tokenizer,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        # compute_metrics = compute_metrics,
    )

    trainer.train()
    shutil.rmtree("./checkpoint")

    tc_pipeline = pipeline("text-classification", model=model, tokenizer=tokenizer, config=config, device=0)

    with open('test_label0.list') as reader:
        lines = reader.read().split('\n')

    fp = open("output", mode="w")

    for line in lines:
        if line.strip() == '':
            continue
        sent_id, sequence = line.split(" ",maxsplit=1)

        try:
            pred = tc_pipeline(sequence)
        except:
            continue

        label = pred[0]['label']
        print(label,sent_id,sequence)
        fp.write(label+" "+sent_id+" "+sequence+"\n")


if __name__ == '__main__':
    main()
