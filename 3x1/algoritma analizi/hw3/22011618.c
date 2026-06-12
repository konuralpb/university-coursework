#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_NAME_LENGTH 100

// symbolTable icin veri yapisi
typedef struct {
    char name[MAX_NAME_LENGTH];
    char type[10];
    int isOccupied; // 0: bos, 1: dolu
} Symbol;



/*
@brief Çift hash fonksiyonu
@param key String'den elde edilen sayisal anahtar
@param i Çakisma çözümü için kullanilan artis
@param tableSize Tablo boyutu
@return Çift hash sonucu adresi döndürür
*/
int hashFunction(int key, int i, int tableSize) {
	int h1,h2;
	h1 = key % tableSize;
	h2 = 1 + (key % (tableSize -3));
	
    return (h1 + i * h2) % tableSize;
}

/*
@brief Horner Kurali ile string'i sayiya çevirir
@param str Çevrilecek string
@return String'in hash fonksiyonlari için kullanilacak sayisal anahtari
*/

int stringToKey(const char *str) {
	int i;
    int key = 0;
    for (i = 0; str[i] != '\0'; i++) {
        key = 31 * key + str[i];
    }
    return key;
}

/*
@brief Sembol tablosunun boyutunu hesaplar
@param varCount Deklare edilmis degisken sayisi
@return Ilk asal sayi olan tablo boyutu
*/
int calculateTableSize(int varCount) {
	int i,isPrime = 0;
    int size = 2 * varCount;
    while (isPrime == 0 ) {
        isPrime = 1;
        i=2;
        while(i * i <= size && isPrime == 1){
            if (size % i == 0) {
                isPrime = 0;
            }
            i++;
        }
        if (isPrime){
        	return size;
		} 
        size++;
    }
}

/*
@brief Sembol tablosuna degisken ekler
@param name Degiskenin adi
@param type Degiskenin tipi
@param symbolTable sembol tablosu
@param tableSize tablo uzunlugu
*/
void insert(const char *name, const char *type, Symbol *symbolTable, int tableSize) {
	int i;
    int key = stringToKey(name);
    for (i = 0; i < tableSize; i++) {
        int index = hashFunction(key, i, tableSize);
        if (symbolTable[index].isOccupied == 0 || strcmp(symbolTable[index].name, name) == 0) {
            if (symbolTable[index].isOccupied && strcmp(symbolTable[index].name, name) == 0) {
                printf("HATA: %s degiskeni daha once deklere edilmistir.\n", name);
            } else {
                strcpy(symbolTable[index].name, name);
                strcpy(symbolTable[index].type, type);
                symbolTable[index].isOccupied = 1;
            }
            return;
        }
    }
    printf("HATA: Tablo dolu, %s eklenemedi.\n", name);
}

/*
@brief Sembol tablosunda degisken arar
@param name Aranacak degiskenin adi
@param symbolTable sembol tablosu
@param tableSize tablo uzunlugu
@return Degisken bulunursa 1, bulunamazsa 0 döner
*/
int lookup(const char *name, Symbol *symbolTable, int tableSize) {
	int i;
    int key = stringToKey(name);
    for (i = 0; i < tableSize; i++) {
        int index = hashFunction(key, i, tableSize);
        if (symbolTable[index].isOccupied == 0){
        	return 0;
		} 
        if (strcmp(symbolTable[index].name, name) == 0){
        	return 1;
		} 
    }
    return 0;
}

/*
@brief Kod satirindaki degiskenleri kontrol eder
@param line Islenecek kod satiri
@param symbolTable sembol tablosu
@param tableSize tablo uzunlugu
*/
void checkVariableUsage(const char *line, Symbol *symbolTable, int tableSize) {
    char lineCopy[256];
    strcpy(lineCopy, line);
    char *token = strtok(lineCopy, " \t=+;(),");

    while (token) {
        if (token[0] == '_') { // Degisken kontrolü
            if (!lookup(token, symbolTable,tableSize)) { // Sembol tablosunda yoksa
                printf("HATA: %s degiskeni deklere edilmemistir.\n", token);
            }
        }
        token = strtok(NULL, " \t=+;(),");
    }
}


int main() {
    char fileName[256];
    int mode, tableSize;
	Symbol *symbolTable;
	
    printf("ODEV 3 HASHING\n");
    printf("1. NORMAL Mod\n");
    printf("2. DEBUG Mod\n");
    printf("Lutfen bir mod secin (1 veya 2): ");
    scanf("%d", &mode);
    getchar(); 

    printf("C program dosyasinin adini girin: ");
    fgets(fileName, sizeof(fileName), stdin);
    fileName[strcspn(fileName, "\n")] = '\0'; 

    if (!(mode == 1 || mode == 2)) {
        printf("Gecersiz secim.");
    }
     else {
       	int i;
	    FILE *file = fopen(fileName, "r");
	    if (!file) {
	        printf("Dosya acilamadi: %s\n", fileName);
	        return;
	    }
	
	    char line[256];
	    int varCount = 0;
	
	    // Ilk geçis: Degisken sayisini hesapla
	    while (fgets(line, sizeof(line), file)) {
	        char type[10], names[MAX_NAME_LENGTH];
	        if (sscanf(line, "%9s %[^\n]", type, names) == 2) {
	            if (strcmp(type, "int") == 0 || strcmp(type, "float") == 0 || strcmp(type, "char") == 0) {
	                char *token = strtok(names, " ,;");
	                while (token) {
	                	if(token[0] == '_' ){
	                    	varCount++;
	                    }
	                    token = strtok(NULL, " ,;");
	                }
	            }
	        }
	    }
	
	    // Sembol tablosunu olustur
	    tableSize = calculateTableSize(varCount);
	    symbolTable = (Symbol *)calloc(tableSize, sizeof(Symbol));
	
	    if (mode == 2) {
	        printf("Deklere edilmis degisken sayisi: %d\n", varCount);
	        printf("Sembol tablosu uzunlugu: %d\n", tableSize);
	    }
	
	    // Ikinci geçis: Degiskenleri ekle ve hatalari kontrol et
	    rewind(file);
	    while (fgets(line, sizeof(line), file)) {
	        char type[10], names[MAX_NAME_LENGTH];
	      
	            if (sscanf(line, " int %s", type) == 1 ||
	            sscanf(line, " float %s", type) == 1 ||
	            sscanf(line, " char %s", type) == 1) {
	            	sscanf(line, "%9s %[^\n]", type, names);
	                char *token = strtok(names, " ,;\n");
	                while (token) {
	                    if (token[0] != '_') {
	                        
	                    } else {
	                        insert(token, type, symbolTable, tableSize);
	                    }
	                    token = strtok(NULL, " ,;\n");
	                }
	            }
	        else { // Kullanim hatalarini kontrol et
	            checkVariableUsage(line, symbolTable,tableSize);
	        }
	    }
	
	    if (mode == 2) {
	        printf("Sembol Tablosu:\n");
	        for (i = 0; i < tableSize; i++) {
	            if (symbolTable[i].isOccupied) {
	                printf("[%d] %s (%s)\n", i, symbolTable[i].name, symbolTable[i].type);
	            }
	        }
	    }
	
	    fclose(file);
	    free(symbolTable);
    }
    return 0;
}

