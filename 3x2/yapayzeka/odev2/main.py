from transformers import AutoTokenizer, AutoModel
import torch
import pandas as pd
from tqdm import tqdm
import numpy as np
import os

MODEL_NAME = "intfloat/multilingual-e5-large-instruct"
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Modeli ve tokenizer'ı yükle
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModel.from_pretrained(MODEL_NAME).to(device)
model.eval()

def get_embeddings(texts, tokenizer, model):
    embeddings = []
    with torch.no_grad():
        for text in tqdm(texts, desc="Embedding alınıyor"):
            inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512)
            inputs = {k: v.to(device) for k, v in inputs.items()}
            outputs = model(**inputs)
            last_hidden_state = outputs.last_hidden_state
            attention_mask = inputs['attention_mask']
            mask_expanded = attention_mask.unsqueeze(-1).expand(last_hidden_state.size()).float()
            sum_embeddings = torch.sum(last_hidden_state * mask_expanded, 1)
            sum_mask = torch.clamp(mask_expanded.sum(1), min=1e-9)
            mean_pooled = sum_embeddings / sum_mask
            embeddings.append(mean_pooled.squeeze().cpu().numpy())
    return np.array(embeddings)

# Veriyi oku
df = pd.read_excel("data/ogrenci_sorular_2025.xlsx")

sorular = df["Soru"].astype(str).tolist()
gpt4o = df["gpt4o cevabı"].astype(str).tolist()
deepseek = df["deepseek cevabı"].astype(str).tolist()

# Embedding işlemi
soru_embeddings = get_embeddings(sorular, tokenizer, model)
gpt4o_embeddings = get_embeddings(gpt4o, tokenizer, model)
deepseek_embeddings = get_embeddings(deepseek, tokenizer, model)

# Kaydet
os.makedirs("embeddings", exist_ok=True)
np.save("embeddings/soru_embeddings_e5.npy", soru_embeddings)
np.save("embeddings/gpt4o_embeddings_e5.npy", gpt4o_embeddings)
np.save("embeddings/deepseek_embeddings_e5.npy", deepseek_embeddings)
