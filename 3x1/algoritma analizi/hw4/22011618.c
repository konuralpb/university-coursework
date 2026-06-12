#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MAX_N 10 // Maksimum satranç tahtasi boyutu

/*
@brief boardi printler

@param board satranc alani
@param n satranc tahtasinin buyuklugu
*/
void print_board(int **board, int n) {
	int i,j;
    for (i = 0; i < n; i++) {
        for ( j = 0; j < n; j++) {
            printf(board[i][j] ? "Q " : ". ");
        }
        printf("\n");
    }
    printf("\n");
}

/*
@brief cozumu kayedetip printler

@param board oyun tahtasi
@param n oyun tahtasinin buyuklugu
@param solution_count counta pointer
*/
void save_solution(int **board, int n, int *solution_count) {
    printf("Solution %d:\n", ++(*solution_count));
    print_board(board, n);
}

/*
@brief brute force icin tahta gecerli mi degil mi kontrolu yapar

@param board oyun tahtasi
@param n oyun tahtasinin buyuklugu
@return eger guvenli ise 1 degilse 0 dondurur
*/
int is_valid_board(int **board, int n) {
	int row,col,i;
    for (row = 0; row < n; row++) {
        for (col = 0; col < n; col++) {
            if (board[row][col]) {
                // Check row and column
                for (i = 0; i < n; i++) {
                    if ((i != row && board[i][col]) || (i != col && board[row][i])) {
                        return 0;
                    }
                }
                // Check diagonals
                for (i = -n; i <= n; i++) {
                    if (i != 0 &&
                        ((row + i >= 0 && row + i < n && col + i >= 0 && col + i < n && board[row + i][col + i]) ||
                         (row + i >= 0 && row + i < n && col - i >= 0 && col - i < n && board[row + i][col - i]))) {
                        return 0;
                    }
                }
            }
        }
    }
    return 1;
}

/*
@brief olasi tum olasiliklari deneyen brute force metodu

@param board oyun tahtasi
@param n oyun tahtasinin buyuklugu
*/
void brute_force_all_boards(int **board, int n, int *solution_count) {
	int i,j,k;
    int max_combinations = 1 << (n * n); // 2^(n*n), toplam olasilik sayisi

    for (k = 0; k < max_combinations; k++) {
        for(i=0;i<n;i++){
        	for(j=0;j<n;j++){
        		board[i][j] = 0;
			}
        	
		}

        int count = 0;
        int temp = k;
        for (i = 0; i < n; i++) {
            for (j = 0; j < n; j++) {
                if (temp % 2 == 1) {
                    board[i][j] = 1;
                    count++;
                }
                temp /= 2;
            }
        }

        if (count == n && is_valid_board(board, n)) {
            save_solution(board, n, solution_count);
        }
    }
}

/*
@brief vezir yerlestirelebilir mi kontrol eder(optimizasyon 1 icin)

@param row Row indeksi
@param col Column indeksi
@param n oyun tahtasi buyuklugu
@param rows vezirlerin rowlarini tutan array
@return eger guvenli ise 1 degilse 0 dondurur
*/
int is_safe_optimized1(int row, int col, int n, int rows[]) {
	int i;
    for (i = 0; i < col; i++) {
        if (rows[i] == row || abs(rows[i] - row) == abs(i - col)) {
            return 0;
        }
    }
    return 1;
}

/*
@brief optimizasyon 1 icin cozum, ayni satirda veir olmayacagini dusunerek cozum arar

@param board oyun tahtasi
@param col mevcut column
@param n tahtanin buyuklugu
@param rows vezirlerin rowlarini tutan array
@param solution_count cozum sayisinin pointeri
*/
void optimized1(int **board, int col, int n, int rows[], int *solution_count) {
	int i;
    if (col >= n) {
        save_solution(board, n, solution_count);
        return;
    }

    for (i = 0; i < n; i++) {
        if (is_safe_optimized1(i, col, n, rows)) {
            rows[col] = i;
            board[i][col] = 1;
            optimized1(board, col + 1, n, rows, solution_count);
            board[i][col] = 0;
        }
    }
}

/*
@brief vezir yerlestirelebilir mi kontrol eder(optimizasyon 2 icin)

@param row Row indeksi
@param col Column indeksi
@param n oyun tahtasi buyuklugu
@param rows vezirlerin rowlarini tutan array
@return eger guvenli ise 1 degilse 0 dondurur
*/
int is_safe_optimized2(int row, int col, int n, int rows[]) {
	int i;
    for (i = 0; i < col; i++) {
        if (rows[i] == row || abs(rows[i] - row) == abs(i - col)) {
            return 0;
        }
    }
    return 1;
}

/*
@brief optimizasyon 2 icin cozum, ayni satirda ve sutunda veir olmayacagini dusunerek cozum arar

@param board oyun tahtasi
@param col mevcut column
@param n tahtanin buyuklugu
@param rows vezirlerin rowlarini tutan array
@param solution_count cozum sayisinin pointeri
*/
void optimized2(int **board, int col, int n, int rows[], int columns[], int *solution_count) {
	int i;
    if (col >= n) {
        save_solution(board, n, solution_count);
        return;
    }

    for (i = 0; i < n; i++) {
        if (columns[i] == 0 && is_safe_optimized2(i, col, n, rows)) {
            rows[col] = i;
            columns[i] = 1;
            board[i][col] = 1;
            optimized2(board, col + 1, n, rows, columns, solution_count);
            board[i][col] = 0;
            columns[i] = 0;
        }
    }
}

/*
@brief backtracking ile cozum

@param board oyun tahtasi
@param col mevcut column
@param n tahtanin buyuklugu
@param solution_count cozum sayisinin pointeri
*/
void backtracking(int **board, int col, int n, int *solution_count) {
    int i, j, safe;
    if (col >= n) {
        save_solution(board, n,solution_count);
        return;
    }

    for (i = 0; i < n; i++) {
        safe = 1;
        
        j=0;
		// Check for conflicts in previous columns
       while (j < col && safe) {
            if (board[j][i] || 
                (i - (col - j) >= 0 && board[j][i - (col - j)]) || 
                (i + (col - j) < n && board[j][i + (col - j)])) {
                safe = 0;
                
            }
            j++;
        }

        if (safe) {
            board[col][i] = 1;
            backtracking(board, col + 1, n,solution_count);
            board[col][i] = 0;
        }
    }
}

/*
@brief metodlari calistirir

@param mode metod modu
@param n tahtanin buyuklugu
*/

void run_mode(int mode, int n) {
	int i,j;
    clock_t start, end;
    int **board = (int **)malloc(n * sizeof(int *));
    for (i = 0; i < n; i++) {
        board[i] = (int *)malloc(n * sizeof(int));
    }
    int rows[MAX_N], columns[MAX_N];
    int solution_count = 0;

    memset(rows, -1, sizeof(rows));
    memset(columns, 0, sizeof(columns));

    start = clock();
    switch (mode) {
        case 1:
            printf("BRUTE FORCE MODE:\n");
                    for(i=0;i<n;i++){
        		for(j=0;j<n;j++){
        			board[i][j] = 0;
				}
			}	
            brute_force_all_boards(board, n, &solution_count);
            break;
        case 2:
            printf("OPTIMIZED_1 MODE:\n");
                    for(i=0;i<n;i++){
        		for(j=0;j<n;j++){
        			board[i][j] = 0;
				}
			}
            optimized1(board, 0, n, rows, &solution_count);
            break;
        case 3:
            printf("OPTIMIZED_2 MODE:\n");
                    for(i=0;i<n;i++){
        		for(j=0;j<n;j++){
        			board[i][j] = 0;
				}
			}
            optimized2(board, 0, n, rows, columns, &solution_count);
            break;
        case 4:
            printf("BACKTRACKING MODE:\n");
            for(i=0;i<n;i++){
        		for(j=0;j<n;j++){
        			board[i][j] = 0;
				}
			}
            backtracking(board, 0, n, &solution_count);
            break;
        default:
            printf("Invalid mode!\n");
            break;
    }
    end = clock();

    printf("Total Solutions: %d\n", solution_count);
    printf("Execution Time: %.5f seconds\n\n", (double)(end - start) / CLOCKS_PER_SEC);

    for ( i = 0; i < n; i++) {
        free(board[i]);
    }
    free(board);
}
int main() {
    int n, mode;

    printf("Enter the value of N (maximum %d): ", MAX_N);
    scanf("%d", &n);

    if (n > MAX_N || n <= 0) {
        printf("Invalid N value. N should be between 1 and %d.\n", MAX_N);
        return 1;
    }

    printf("Select Mode:\n");
    printf("1 - BRUTE FORCE\n");
    printf("2 - OPTIMIZED_1\n");
    printf("3 - OPTIMIZED_2\n");
    printf("4 - BACKTRACKING\n");
    printf("5 - ALL MODES\n");
    printf("Enter your choice: ");
    scanf("%d", &mode);

    if (mode == 5) {
        int i;	
        for (i = 1; i <= 4; i++) {
            run_mode(i, n);
        }
    } else {
        run_mode(mode, n);
    }

    return 0;
}
