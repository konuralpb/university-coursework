import numpy as np
import random
import deap.base
import deap.creator
import deap.tools
import deap.algorithms
import os
from PIL import Image
import matplotlib.pyplot as plt

# Parametreler
IMG_SIZE = 24  # 24x24'lük resimler
PATCH_SIZE = 3  # 3x3'lük patchler
NUM_PATTERNS = 7  # 7 farklı pattern
POP_SIZE = 50  # Popülasyon büyüklüğü
GENERATIONS = 5000  # Nesil sayısı
MUTATION_RATE = 0.2  # Mutasyon oranı
INPUT_IMAGE = "blm.png"  # Tek giriş resmi

# 24x24'lük binary tek bir resmi yükleme
def load_image(filename):
    img = Image.open(filename).convert("L")  # Gri tonlamaya çevir
    img = img.resize((IMG_SIZE, IMG_SIZE))
    img = np.array(img)
    img = (img > 128).astype(int)  # Binary hale getir
    return img

image = load_image(INPUT_IMAGE)

def decode_patterns(individual):
    """ 7 adet 3x3'lük pattern'ı bireyden çıkartır."""
    return [np.array(individual[i * 9:(i + 1) * 9]).reshape((3, 3)) for i in range(NUM_PATTERNS)]

def match_image_to_patterns(image, patterns):
    """ Verilen görüntü için en iyi pattern eşleşmesini yapar ve toplam loss'u döndürür."""
    reconstructed_image = np.zeros_like(image)
    for i in range(0, IMG_SIZE, PATCH_SIZE):
        for j in range(0, IMG_SIZE, PATCH_SIZE):
            patch = image[i:i + PATCH_SIZE, j:j + PATCH_SIZE]
            best_match = min(patterns, key=lambda p: np.sum(np.abs(p - patch)))
            reconstructed_image[i:i + PATCH_SIZE, j:j + PATCH_SIZE] = best_match
    return np.sum(np.abs(reconstructed_image - image)), reconstructed_image

def fitness(individual):
    """ Tek resim için loss hesaplar."""
    patterns = decode_patterns(individual)
    total_loss, _ = match_image_to_patterns(image, patterns)
    return (total_loss,)

# Genetik Algoritma Kurulumu
deap.creator.create("FitnessMin", deap.base.Fitness, weights=(-1.0,))  # Minimize etmek istiyoruz
deap.creator.create("Individual", list, fitness=deap.creator.FitnessMin)

toolbox = deap.base.Toolbox()
toolbox.register("attr_bool", random.randint, 0, 1)
toolbox.register("individual", deap.tools.initRepeat, deap.creator.Individual, toolbox.attr_bool, NUM_PATTERNS * PATCH_SIZE * PATCH_SIZE)
toolbox.register("population", deap.tools.initRepeat, list, toolbox.individual)
toolbox.register("mate", deap.tools.cxTwoPoint)
toolbox.register("mutate", deap.tools.mutFlipBit, indpb=MUTATION_RATE)
toolbox.register("select", deap.tools.selTournament, tournsize=3)
toolbox.register("evaluate", fitness)

# Algoritmayı Çalıştırma
def run_ga():
    pop = toolbox.population(n=POP_SIZE)
    deap.tools.Statistics()
    stats = deap.tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("min", np.min)
    stats.register("mean", np.mean)
    
    pop, log = deap.algorithms.eaSimple(pop, toolbox, cxpb=0.5, mutpb=0.2, ngen=GENERATIONS, stats=stats, verbose=True)
    
    best_ind = deap.tools.selBest(pop, 1)[0]
    best_patterns = decode_patterns(best_ind)
    return best_patterns

best_patterns = run_ga()

# Rekonstrüksiyon ve Görselleştirme
loss, reconstructed = match_image_to_patterns(image, best_patterns)
fig, axes = plt.subplots(1, 2, figsize=(8, 4))

axes[0].imshow(image, cmap='gray')
axes[0].set_title('Original Image')
axes[0].axis('off')

axes[1].imshow(reconstructed, cmap='gray')
axes[1].set_title('Reconstructed Image')
axes[1].axis('off')

plt.show()

print("Best patterns found:")
for i, p in enumerate(best_patterns):
    print(f"Pattern {i+1}:\n", p)
