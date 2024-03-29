#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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
void transpose_matrix(float **A, float **B, int a1, int a2)
{
    for(int i = 0; i < a1; i++)
    {
        for(int j = 0; j < a2; j++)
        {
            B[j][i] = A[i][j];
        }
    }
}
// 對matrix做softmax，對"各列"
void softmax(float **matrix, int rows, int cols) {
    for (int i = 0; i < rows; i++)  // 對"各列"
    {
        // Find maximum value in the row
        float max_val = matrix[i][0];
        for (int j = 1; j < cols; j++) 
        {
            if (matrix[i][j] > max_val) 
            {
                max_val = matrix[i][j];
            }
        }
        // printf("AAA: %f\n", max_val);
        // for (int j = 0; j < cols; j++)
        // {
        //     printf("BBB: %f ", matrix[i][j]);

        // }
        // printf("----\n");

        // Subtract maximum value to avoid overflow
        float sum = 0.0;
        for (int j = 0; j < cols; j++) 
        {
            matrix[i][j] = exp(matrix[i][j] - max_val);
            sum += matrix[i][j];
        }

        // Normalize the row
        for (int j = 0; j < cols; j++) 
        {
            matrix[i][j] /= sum;
        }
    }
}

// 輸入參數為兩個矩陣，接續是A的大小、B的大小
float** matrix_mul(float **A, float **B, int a1, int a2, int b1, int b2) {
    float **result = (float **)malloc(a1 * sizeof(float *)); // result is a1*b2 matrix.
    for (int i = 0; i < a1; i++) {
        result[i] = (float *)malloc(b2 * sizeof(float));
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
float** attention(float **IN, float **Wq, float **Wk, float **Wv)
{
    // K-Transpose(S3*S1)
    float **mat_Kt = (float **)malloc(S3 * sizeof(float *));
    for (int i = 0; i < S3; i++) 
    {
        mat_Kt[i] = (float *)malloc(S1 * sizeof(float));
    }
    // 第一階段
    // Q = IN * Wq (S1 * S3)
    float **mat_Q = matrix_mul(IN, Wq, S1, S2, S2, S3);
    // K = IN * Wk (S1 * S3)
    float **mat_K = matrix_mul(IN, Wk, S1, S2, S2, S3);
    // transpose K, and get mat_Kt(S3 * S1)
    transpose_matrix(mat_K, mat_Kt, S1, S3);
    // V = IN * Wv (S1 * S4)
    float **mat_V = matrix_mul(IN, Wv, S1, S2, S2, S4);
    // 第二階段
    // A = Q * K^T (S1 * S1)
    float **mat_A = matrix_mul(mat_Q, mat_Kt, S1, S3, S3, S1);
    // 對mat_A做softmax
    softmax(mat_A, S1, S1);
    // 第三階段
    // O(result) = A' * V (S1 * S4)
    float **mat_O = matrix_mul(mat_A, mat_V, S1, S1, S1, S4);


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
    float **IN = (float **)malloc(S1 * sizeof(float *));
    for (int i = 0; i < S1; i++) 
    {
        IN[i] = (float *)malloc(S2 * sizeof(float));
    }
    // Wq(S2*S3)
    float **Wq = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        Wq[i] = (float *)malloc(S3 * sizeof(float));
    }
    // Wk(S2*S3)
    float **Wk = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        Wk[i] = (float *)malloc(S3 * sizeof(float));
    }
    // Wv(S2*S4)
    float **Wv = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        Wv[i] = (float *)malloc(S4 * sizeof(float));
    }

    // 輸入matrix data
    float num = 0; // input number
    printf("Please input the matrix IN(%d * %d):\n", S1, S2);
    for(int i = 0 ; i < S1; i++)
    {
        for(int j = 0 ; j < S2; j++)
        {
            scanf("%f", &num);
            IN[i][j] = num;
        }
    }
    printf("Please input the kernel Wq(%d * %d):\n", S2, S3);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S3; j++)
        {
            scanf("%f", &num);
            Wq[i][j] = num;
        }
    }
    printf("Please input the kernel Wk(%d * %d):\n", S2, S3);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S3; j++)
        {
            scanf("%f", &num);
            Wk[i][j] = num;
        }
    }
    printf("Please input the kernel Wv(%d * %d):\n", S2, S4);
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S4; j++)
        {
            scanf("%f", &num);
            Wv[i][j] = num;
        }
    }
    
    // 做self-attention
    float **attention_result = attention(IN, Wq, Wk, Wv);

    printf("\nResult:\n");
    for (int i = 0; i < S1; i++) {
        for (int j = 0; j < S4; j++) {
            printf("%f ", attention_result[i][j]);
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
