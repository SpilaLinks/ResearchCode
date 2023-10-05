#!/usr/bin/python3
import os
os.environ["http_proxy"] = "http://133.220.110.112:3128"
os.environ["https_proxy"] = "http://133.220.110.112:3128"
#os.environ["CUDA_VISIBLE_DEVICES"]="-1"

import sys
import transformers
transformers.BertTokenizer = transformers.BertJapaneseTokenizer

from sentence_transformers import SentenceTransformer
from sentence_transformers import models
from sentence_transformers.losses import TripletDistanceMetric, TripletLoss
from sentence_transformers.evaluation import TripletEvaluator
from sentence_transformers.readers import TripletReader
from sentence_transformers.datasets import SentencesDataset
from torch.utils.data import DataLoader

transformer = models.Transformer('cl-tohoku/bert-base-japanese-v3')

pooling = models.Pooling(
    transformer.get_word_embedding_dimension(), 
    pooling_mode_mean_tokens=True, 
    pooling_mode_cls_token=False, 
    pooling_mode_max_tokens=False
)

model = SentenceTransformer(modules=[transformer, pooling])


def main():
    
    BATCH_SIZE = 16
    NUM_EPOCHS = 10
    EVAL_STEPS = 500
    OUTPUT_PATH = "../../model"
    
    triplet_reader = TripletReader(".")
    train_examples = triplet_reader.get_examples('train.tsv')
    train_dataset = SentencesDataset(train_examples, model=model)
    train_dataloader = DataLoader(train_dataset, shuffle=True, batch_size=BATCH_SIZE)
    w_steps = int(len(train_examples) // BATCH_SIZE * 0.1)
    
    dev_examples = triplet_reader.get_examples('dev.tsv')
    evaluator = TripletEvaluator.from_input_examples(dev_examples)
    
    train_loss = TripletLoss(model=model, distance_metric=TripletDistanceMetric.EUCLIDEAN, triplet_margin=1)

    model.fit(
        train_objectives=[(train_dataloader, train_loss)],
        evaluator=evaluator,
        epochs=NUM_EPOCHS,
        evaluation_steps=EVAL_STEPS,
        warmup_steps=w_steps,
        output_path=OUTPUT_PATH
    )


        
if __name__ == "__main__":
    main()
