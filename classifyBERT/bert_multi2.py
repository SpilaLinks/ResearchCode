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
    num_classes = 8  # クラス数（２値分類なら２）
    batch_size = 32
    epochs = 5   # 十分に学習できていれば、3くらいに減らしてもよい
    MAX = 80     # 80以上にするには 8GB以上のVRAMが必要

    train_labels, train_texts = get_tuples_label_sentence("../makeTrainData/train.list")
    max_length = max([len(sent) for sent in train_texts])

    if max_length > MAX:
        max_length = MAX

    x_train = to_features(train_texts, max_length)

    y_train = tf.keras.utils.to_categorical(train_labels, num_classes=num_classes)
    model = build_model(model_name, num_classes=num_classes, max_length=max_length)

    # 訓練
    model.fit(x_train,y_train,batch_size=batch_size,epochs=epochs)

    # 予測
    sent_id, test_texts = get_sentence("../makeTestData/test.list")
    x_test = to_features(test_texts, max_length)
    y_predicts = model.predict(x_test)

    # create output
    fp = open("output", mode='w')

    for result, s_id, sentence in zip(y_predicts, sent_id, test_texts):

        out_str = ""
        for score in result:
            out_str += str(score)+" "

        fp.write(out_str+"\n")

    fp.close()


# テキストのリストをtransformers用の入力データに変換
def to_features(texts, max_length):
    shape = (len(texts), max_length)

    input_ids = np.zeros(shape, dtype="int32")
    attention_mask = np.zeros(shape, dtype="int32")
    token_type_ids = np.zeros(shape, dtype="int32")

    for i, text in enumerate(texts):
        encoded_dict = tokenizer.encode_plus(text, max_length=max_length, padding='max_length', truncation=True)
        input_ids[i] = encoded_dict["input_ids"]

        attention_mask[i] = encoded_dict["attention_mask"]
        token_type_ids[i] = encoded_dict["token_type_ids"]

    return [input_ids, attention_mask, token_type_ids]

# 単一テキストをクラス分類するモデルの構築
def build_model(model_name, num_classes, max_length):
    input_shape = (max_length, )

    input_ids = tf.keras.layers.Input(input_shape, dtype=tf.int32)
    attention_mask = tf.keras.layers.Input(input_shape, dtype=tf.int32)
    token_type_ids = tf.keras.layers.Input(input_shape, dtype=tf.int32)

    bert_model = transformers.TFBertModel.from_pretrained(model_name)

    # last_hidden_state, pooler_output = bert_model(input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids)
    # output = tf.keras.layers.Dense(num_classes, activation="softmax")(pooler_output)

    info_model = bert_model(input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids)
    output = tf.keras.layers.Dense(num_classes, activation="softmax")(info_model[1])

    model = tf.keras.Model(inputs=[input_ids, attention_mask, token_type_ids], outputs=[output])

    optimizer = tf.keras.optimizers.Adam(learning_rate=3e-5, epsilon=1e-08, clipnorm=1.0)

    model.compile(optimizer=optimizer, loss="categorical_crossentropy", metrics=["acc"])

    return model


def get_tuples_label_sentence(input_file):

    labels = []
    sentences = []
    with open(input_file) as fp:

        for line in fp:
            #print(line)
            label,s_id,sentence = line.rstrip().split(" ")

            labels.append(int(label))
            sentences.append(sentence)

    return labels, sentences

def get_sentence(input_file):

    labels = []
    sentences = []
    with open(input_file) as fp:

        for line in fp:
            label,sent = line.rstrip().split(" ")

            labels.append(label)
            sentences.append(sent)

    return labels, sentences


if __name__ == '__main__':
    main()
