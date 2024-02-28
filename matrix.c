#include <stdio.h>
#include <stdlib.h>
// define 參數
// matrix A(M*W)
// matrix B(W*N)    
#define M 10
#define W 9
#define N 8
#define K 2
#define S1 2
#define S2 2
#define S3 2
#define S4 2
// 輸入參數為兩個矩陣，接續是A的大小、B的大小
int** matrix_mul(int **A, int **B, int a1, int a2, int b1, int b2) {
    int **result = (int **)malloc(a1 * sizeof(int *)); // result is a1*b2 matrix.
    for (int i = 0; i < a1; i++) {
        result[i] = (int *)malloc(b2 * sizeof(int));
    }

    for (int i = 0; i < a1; i++) {
        for (int j = 0; j < b2; j++) {
            result[i][j] = 0;
            for (int k = 0; k < a2; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    return result;
}

int main() {
    // 配置空間
    int **A = (int **)malloc(M * sizeof(int *));
    int **B = (int **)malloc(W * sizeof(int *));
    for (int i = 0; i < M; i++) {
        A[i] = (int *)malloc(W * sizeof(int));
    }
    for (int i = 0; i < W; i++) {
        B[i] = (int *)malloc(N * sizeof(int));
    }

    // 輸入A B matrix
    int num = 0; // input number
    printf("Please input the matrix A(%d * %d):\n", M, W);
    for(int i = 0 ; i < M; i++)
    {
        for(int j = 0 ; j < W; j++)
        {
            scanf("%d", &num);
            A[i][j] = num;
        }
    }
    printf("Please input the matrix B(%d * %d):\n", W, N);
    for(int i = 0 ; i < W; i++)
    {
        for(int j = 0 ; j < N; j++)
        {
            scanf("%d", &num);
            B[i][j] = num;
        }
    }
    // A[0][0] = 1; A[0][1] = 2; A[0][2] = 3;
    // A[1][0] = 4; A[1][1] = 5; A[1][2] = 6;

    // B[0][0] = 7; B[0][1] = 8;
    // B[1][0] = 9; B[1][1] = 10;
    // B[2][0] = 11; B[2][1] = 12;

    int **result = matrix_mul(A, B, M, W, W, N);

    printf("\nResult:\n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", result[i][j]);
        }
        printf("\n");
    }

    for (int i = 0; i < M; i++) {
        free(A[i]);
    }
    for (int i = 0; i < W; i++) {
        free(B[i]);
    }
    for (int i = 0; i < M; i++) {
        free(result[i]);
    }
    free(A);
    free(B);
    free(result);

    return 0;
}
