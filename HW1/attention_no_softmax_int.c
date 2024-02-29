#include <stdio.h>
#include <stdlib.h>
// define 參數
// matrix A(M*W)
// matrix B(W*N)    
#define M 10
#define W 9
#define N 10
#define L 4
#define K 2
// IN(S1*S2)
// Wq(S2*S3)
// Wk(S2*S3)
// Wv(S2*S3) ???? 題目上是寫(S2*S4)
#define S1 2
#define S2 3
#define S3 4
#define S4 3

// 轉置矩陣B = A^T
// A is a1 * a2 matrix, and B is a2 * a1 matrix.
void transpose_matrix(int **A, int **B, int a1, int a2)
{
    for(int i = 0; i < a1; i++)
    {
        for(int j = 0; j < a2; j++)
        {
            B[j][i] = A[i][j];
        }
    }
}
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

// 輸入參數為4個矩陣
// 返回參數為矩陣
int** attention(int **IN, int **Wq, int **Wk, int **Wv)
{
    // // Q(S1*S3)
    // int **mat_Q = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_Q[i] = (int *)malloc(S3 * sizeof(int));
    // }
    // // K(S1*S3)
    // int **mat_K = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_K[i] = (int *)malloc(S3 * sizeof(int));
    // }
    // // K-Transpose(S3*S1)
    int **mat_Kt = (int **)malloc(S3 * sizeof(int *));
    for (int i = 0; i < S3; i++) 
    {
        mat_Kt[i] = (int *)malloc(S1 * sizeof(int));
    }
    // // V(S1*S4)
    // int **mat_V = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_V[i] = (int *)malloc(S4 * sizeof(int));
    // }
    // // A(S1*S1)
    // int **mat_A = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_A[i] = (int *)malloc(S1 * sizeof(int));
    // }
    // // A(S1*S1)
    // int **mat_A = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_A[i] = (int *)malloc(S1 * sizeof(int));
    // }
    // // mat_O是欲返回的輸出矩陣(S1*S4)，配置空間
    // int **mat_O = (int **)malloc(S1 * sizeof(int *));
    // for (int i = 0; i < S1; i++) 
    // {
    //     mat_O[i] = (int *)malloc(S4 * sizeof(int));
    // }
    // 第一階段
    // Q = IN * Wq (S1 * S3)
    int **mat_Q = matrix_mul(IN, Wq, S1, S2, S2, S3);
    // K = IN * Wk (S1 * S3)
    int **mat_K = matrix_mul(IN, Wk, S1, S2, S2, S3);
    // transpose K, and get mat_Kt(S3 * S1)
    transpose_matrix(mat_K, mat_Kt, S1, S3);
    // V = IN * Wv (S1 * S4)
    int **mat_V = matrix_mul(IN, Wv, S1, S2, S2, S4);
    // 第二階段
    // A = Q * K^T (S1 * S1)
    int **mat_A = matrix_mul(mat_Q, mat_Kt, S1, S3, S3, S1);
    // 第三階段
    // O(result) = A' * V (S1 * S4)
    int **mat_O = matrix_mul(mat_A, mat_V, S1, S1, S1, S4);


    // 釋放矩陣乘法結果矩陣的空間，除了mat_O(在main中會被釋放)
    for (int i = 0; i < S1; i++) {
        free(mat_Q[i]);
        free(mat_K[i]);
        free(mat_V[i]);
        free(mat_A[i]);
    }
    for (int i = 0; i < S3; i++) {
        free(mat_Kt[i]);
    }
    free(mat_Q);
    free(mat_K);
    free(mat_V);
    free(mat_Kt);
    free(mat_A);

    
    return mat_O;
}
int main() {
    // 配置初始所需矩陣空間
    // IN(S1*S2)
    int **IN = (int **)malloc(S1 * sizeof(int *));
    for (int i = 0; i < S1; i++) 
    {
        IN[i] = (int *)malloc(S2 * sizeof(int));
    }
    // Wq(S2*S3)
    int **Wq = (int **)malloc(S2 * sizeof(int *));
    for (int i = 0; i < S2; i++) 
    {
        Wq[i] = (int *)malloc(S3 * sizeof(int));
    }
    // Wk(S2*S3)
    int **Wk = (int **)malloc(S2 * sizeof(int *));
    for (int i = 0; i < S2; i++) 
    {
        Wk[i] = (int *)malloc(S3 * sizeof(int));
    }
    // Wv(S2*S4)
    int **Wv = (int **)malloc(S2 * sizeof(int *));
    for (int i = 0; i < S2; i++) 
    {
        Wv[i] = (int *)malloc(S4 * sizeof(int));
    }

    // 輸入matrix data
    int num = 0; // input number
    printf("Please input the matrix IN(%d * %d):\n", S1, S2);
    for(int i = 0 ; i < S1; i++)
    {
        for(int j = 0 ; j < S2; j++)
        {
            scanf("%d", &num);
            IN[i][j] = num;
        }
    }
    printf("Please input the kernel Wq(%d * %d):\n", S2, S3);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S3; j++)
        {
            scanf("%d", &num);
            Wq[i][j] = num;
        }
    }
    printf("Please input the kernel Wk(%d * %d):\n", S2, S3);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S3; j++)
        {
            scanf("%d", &num);
            Wk[i][j] = num;
        }
    }
    printf("Please input the kernel Wv(%d * %d):\n", S2, S4);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S4; j++)
        {
            scanf("%d", &num);
            Wv[i][j] = num;
        }
    }
    
    // 做self-attention
    int **attention_result = attention(IN, Wq, Wk, Wv);

    printf("\nResult:\n");
    for (int i = 0; i < S1; i++) {
        for (int j = 0; j < S4; j++) {
            printf("%d ", attention_result[i][j]);
        }
        printf("\n");
    }
    // 釋放空間
    for (int i = 0; i < S1; i++) {
        free(IN[i]);
        free(attention_result[i]);
    }
    for (int i = 0; i < S2; i++) {
        free(Wq[i]);
        free(Wk[i]);
        free(Wv[i]);
    }
    free(IN);
    free(Wq);
    free(Wk);
    free(Wv);
    free(attention_result);

    return 0;
}
