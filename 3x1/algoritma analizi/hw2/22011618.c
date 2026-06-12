#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <limits.h>

/*
@brief 1-n arasi degerlerden olusan rastgele dagilmis bir dizi olusturan fonksyion

@param arr olusturulacak arrayin pointeri
@param size boyutu

@return
*/
void randomArray(int *arr, int size) {
    int i, j, temp;

    // 1-N arasi sayilarla sirali dizi olustur
    for (i = 0; i < size; i++) {
        arr[i] = i + 1;
    }

    // Fisher-Yates karistirma algoritmasiyla rastgele sirala
    for (i = size - 1; i > 0; i--) {
        j = rand() % (i + 1);

        // Elemanlari degistir
        temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

// Min-heap dügümü
typedef struct {
    int value;      // Dügümün degeri
    int chunk_index;  // Dügümün geldigi alt küme indeksi
    int elem_index;   // Alt kümede elemanin indeksi
} HeapNode;

// Min-heap yapisi
typedef struct {
    HeapNode *nodes;
    int size;
} MinHeap;

/*
@brief min heap icin yer ayiran fonksiyon

@param capacity heapin buyuklugu


@return heap arrayi pointeri
*/
MinHeap* create_min_heap(int capacity) {
    MinHeap *heap = (MinHeap *)malloc(sizeof(MinHeap));
    heap->nodes = (HeapNode *)malloc(capacity * sizeof(HeapNode));
    heap->size = 0;
    return heap;
}

/*
@brief heapi memoryden freeleyen fonksiyon

@param heap freelencek heap

@return
*/
void free_min_heap(MinHeap *heap) {
    free(heap->nodes);
    free(heap);
}

/*
@brief min heapify islemi yapan fonksiyon

@param heapin pointeri
@param index index degeri


@return
*/
void min_heapify(MinHeap *heap, int index) {
    int smallest = index;
    int left = 2 * index + 1;
    int right = 2 * index + 2;

    if (left < heap->size && heap->nodes[left].value < heap->nodes[smallest].value) {
        smallest = left;
    }
    if (right < heap->size && heap->nodes[right].value < heap->nodes[smallest].value) {
        smallest = right;
    }

    if (smallest != index) {
        HeapNode temp = heap->nodes[index];
        heap->nodes[index] = heap->nodes[smallest];
        heap->nodes[smallest] = temp;

        min_heapify(heap, smallest);
    }
}

/*
@brief heap'e deger ekleyen fonksiyon

@param heap heapin pointeri
@param node eklenecek node

@return
*/

void insert_min_heap(MinHeap *heap, HeapNode node) {
    int i = heap->size++;
    heap->nodes[i] = node;

    while (i != 0 && heap->nodes[(i - 1) / 2].value > heap->nodes[i].value) {
        HeapNode temp = heap->nodes[i];
        heap->nodes[i] = heap->nodes[(i - 1) / 2];
        heap->nodes[(i - 1) / 2] = temp;
        i = (i - 1) / 2;
    }
}

/*
@brief heapin kok dugumunu cikaran fonksyion

@param heap heapin pointeri

@return
*/
HeapNode extract_min(MinHeap *heap) {
    HeapNode root = heap->nodes[0];
    heap->nodes[0] = heap->nodes[--heap->size];
    min_heapify(heap, 0);
    return root;
}

/*
@brief k way merge yani bizden istenen seyin yapildigi asil kisim, parcalar siralanarak merge ediliyor

@param chunks parcalar dizisi
@param chunk_sizes chunklarin sizelarini tutan dizi
@param k bölünecek parca sayisi
@param result sonuc dizisi
@param total_size verinin toplam uzunlugu

@return
*/
void k_way_merge(int **chunks, int *chunk_sizes, int k, int *result, int total_size) {
    int i, result_index = 0;

    // min heapi baslat
    MinHeap *heap = create_min_heap(k);

    // ilk elemanlari heape ekle
    for (i = 0; i < k; i++) {
        if (chunk_sizes[i] > 0) {
            HeapNode node = {chunks[i][0], i, 0};
            insert_min_heap(heap, node);
        }
    }

    // Min heapten elemanlari cikararak birlestirme islemi
    while (result_index < total_size) {
        HeapNode min_node = extract_min(heap);
        result[result_index++] = min_node.value;

        // Cikarilan elemanin yerine ayni alt kümeden bir sonraki elemani ekle
        if (min_node.elem_index + 1 < chunk_sizes[min_node.chunk_index]) {
            min_node.value = chunks[min_node.chunk_index][min_node.elem_index + 1];
            min_node.elem_index += 1;
            insert_min_heap(heap, min_node);
        }
    }

    free_min_heap(heap);
}

/*
@brief quicksort icin karsilastirma fonksiyonu

@param a karsilastiriacak deger
@param b karsilastirilacak diger deger

@return
*/

int compare(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

/*
@brief diziyi parcalama ve siralama isleminin yapildigi fonksiyon, daha sonra merge'i cagirip birlestiriyor

@param arr array
@param N array uzunlugu
@param k bolunecek parca sayisi

@return
*/
void k_way_merge_sort(int *arr, int N, int k) {
    int i, j, start, end, size, chunk_size = N / k;
    int **chunks = (int **)malloc(k * sizeof(int *));
    int *chunk_sizes = (int *)malloc(k * sizeof(int));
    int *result = (int *)malloc(N * sizeof(int));

    // Dizi parçalarini olustur ve sirala
    for (i = 0; i < k; i++) {
        start = i * chunk_size;
        if (i == k-1){
            end = N;
        }
        else{
            end = (i + 1) * chunk_size;
        }
        size = end - start;

        chunks[i] = (int *)malloc(size * sizeof(int));
        chunk_sizes[i] = size;
        
        for (j = 0; j < size; j++) {
            chunks[i][j] = arr[start + j];
        }
        
        // Parçayi sirala
        qsort(chunks[i], size, sizeof(int), compare);
    }

    // k-yönlü birlestirme
    k_way_merge(chunks, chunk_sizes, k, result, N);

    // Siralanmis sonuç dizisini ana diziye kopyala
    for (i = 0; i < N; i++) {
        arr[i] = result[i];
    }

    // Bellek temizleme
    for (i = 0; i < k; i++) {
        free(chunks[i]);
    }
    free(chunks);
    free(chunk_sizes);
    free(result);
}


int main() {
    int N = 10000000; // Dizi boyutu
    int k = 2;  // k sayisi
    int i;
	clock_t start, end;
	double timef;
	
    srand((unsigned int)time(NULL));


    int *array = (int *)malloc(N * sizeof(int));
    int *temparray = (int *)malloc(N * sizeof(int));
    randomArray(array, N); // random array olusturma
	memcpy(temparray, array, N); // arrayi sakliyorum ki farkli k degerlerinde de
	

    for(k=2;k<11;k++){
    	printf("k = %d ",k);
    	memcpy(array,temparray,N);
		start = clock();
	    k_way_merge_sort(array, N, k);
		end = clock();
		timef = ((double) (end - start)) / CLOCKS_PER_SEC;
		printf("n:%d time: %f\n", N, timef);
    	
	}

    /*printf("Sirali Dizi: ");
    for (i = 0; i < N; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");*/
	
    free(array);
    return 0;
}

