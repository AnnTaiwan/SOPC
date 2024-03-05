#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "SOPC_HW1.h"
// 輸入矩陣大小
// matrix A(M*W)
// matrix B(W*N) 
// matrix C(L*L)   
// matrix D(K*K)     
// IN(S1*S2)
// Wq(S2*S3)
// Wk(S2*S3)
// Wv(S2*S4)

// 轉置矩陣B = A^T
// M1 is a1 * a2 matrix
float **transpose_matrix(float **M1, int a1, int a2)
{
    // M2 = M1^T(a2*a1)
    float **M2 = (float **)malloc(a2 * sizeof(float *));
    for (int i = 0; i < a2; i++) 
    {
        M2[i] = (float *)malloc(a1 * sizeof(float));
    }
    for(int i = 0; i < a1; i++)
    {
        for(int j = 0; j < a2; j++)
        {
            M2[j][i] = M1[i][j];
        }
    }
    return M2;
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
float** matrix_mul(float **M1, float **M2, int a1, int a2, int b1, int b2) {
    float **result = (float **)malloc(a1 * sizeof(float *)); // result is a1*b2 matrix.
    for (int i = 0; i < a1; i++) {
        result[i] = (float *)malloc(b2 * sizeof(float));
    }

    for (int i = 0; i < a1; i++) {
        for (int j = 0; j < b2; j++) {
            result[i][j] = 0;
            for (int k = 0; k < a2; k++) {
                result[i][j] += M1[i][k] * M2[k][j];
            }
        }
    }
    return result;
}
// a : L, b : K
float** conv2D(float **M1, float **M2, int a, int b) {
    int final_size = a - b + 1; // 結果矩陣大小
    // 動態配置returned matrix
    float **conv2D_result = (float **)malloc(final_size * sizeof(float *));
    for (int i = 0; i < final_size; i++) 
    {
        conv2D_result[i] = (float *)malloc(final_size * sizeof(float));
    }
    // 把subspace of C(K*K)轉為一直線(1*(K^2))，存入C_sub_flat
    float **C_sub_flat  = (float **)malloc(1 * sizeof(float *));
    // 把kernel D(K*K)轉為一直線((K^2)*1)，存入D_flat
    float **D_flat = (float **)malloc(b * b * sizeof(float *));
    for (int i = 0; i < 1; i++) {
        C_sub_flat[i] = (float *)malloc(b * b * sizeof(float));
    }
    for (int i = 0; i < b * b; i++) {
        D_flat[i] = (float *)malloc(1 * sizeof(float));
    }
    // 把kernel D(K*K)轉為一直線((K*K)*1)
    int count = 0; // 計當前格數
    for (int q = 0; q < b; q++)  
    {
        for (int u = 0; u < b; u++) 
        {
            D_flat[count++][0] = M2[q][u];;
        }
    }
    int x = 0, y = 0; // 紀錄當前視窗最左上角的座標
    for(int h = 0; h < final_size; h++)
    {
        for(int p = 0; p < final_size; p++)
        {
            // 把subspace of C(K*K)轉為一直線(1*(K*K))
            count = 0;
            for (int q = 0; q < b; q++) 
            {
                for (int u = 0; u < b; u++) 
                {
                    C_sub_flat[0][count++] = M1[x + q][y + u];
                }
            }
            // C_sub_flat(1 * K) * D_flat(K * 1) 做矩陣乘法
            float **result = matrix_mul(C_sub_flat, D_flat, 1, b * b, b * b, 1); // r is 1*1 matrix.
            conv2D_result[h][p] = result[0][0];
            for (int i = 0; i < 1; i++) 
            {
                free(result[i]);
            }
            free(result);
            y++;
        }
        x++;
        y = 0;
    }
    for (int i = 0; i < 1; i++) {
        free(C_sub_flat[i]);
    }
    for (int i = 0; i < b * b; i++) {
        free(D_flat[i]);
    }
    free(C_sub_flat);
    free(D_flat);
    return conv2D_result;
}
// 輸入參數為4個矩陣
// 返回參數為矩陣
float** attention(float **in, float **wq, float **wk, float **wv)
{
    // 第一階段
    // Q = IN * Wq (S1 * S3)
    float **mat_Q = matrix_mul(in, wq, S1, S2, S2, S3);
    // K = IN * Wk (S1 * S3)
    float **mat_K = matrix_mul(in, wk, S1, S2, S2, S3);
    // transpose K, and get mat_Kt(S3 * S1)
    float **mat_Kt = transpose_matrix(mat_K, S1, S3);
    // V = IN * Wv (S1 * S4)
    float **mat_V = matrix_mul(in, wv, S1, S2, S2, S4);
    // 第二階段
    // A = Q * K^T (S1 * S1)
    float **mat_A = matrix_mul(mat_Q, mat_Kt, S1, S3, S3, S1);
    // 除以特徵維度d_k ^ 1/2， 縮放注意力分數，使其不受特徵維度大小的影響。
    for(int i = 0 ; i < S1; i++)
    {
        for(int j = 0 ; j < S1; j++)
        {
            mat_A[i][j] /= sqrt(S3);
        }
    }
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
    //Q1 A(M*W) B(W*N)
    float **a = (float **)malloc(M * sizeof(float *));
    float **b = (float **)malloc(W * sizeof(float *));
    for (int i = 0; i < M; i++) {
        a[i] = (float *)malloc(W * sizeof(float));
    }
    for (int i = 0; i < W; i++) {
        b[i] = (float *)malloc(N * sizeof(float));
    }
    //Q2 配置C(L*L) D(K*K)空間
    float **c = (float **)malloc(L * sizeof(float *));
    float **d = (float **)malloc(K * sizeof(float *));
    for (int i = 0; i < L; i++) {
        c[i] = (float *)malloc(L * sizeof(float));
    }
    for (int i = 0; i < K; i++) {
        d[i] = (float *)malloc(K * sizeof(float));
    }
    //Q3
    // IN(S1*S2)
    float **in = (float **)malloc(S1 * sizeof(float *));
    for (int i = 0; i < S1; i++) 
    {
        in[i] = (float *)malloc(S2 * sizeof(float));
    }
    // Wq(S2*S3)
    float **wq = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        wq[i] = (float *)malloc(S3 * sizeof(float));
    }
    // Wk(S2*S3)
    float **wk = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        wk[i] = (float *)malloc(S3 * sizeof(float));
    }
    // Wv(S2*S4)
    float **wv = (float **)malloc(S2 * sizeof(float *));
    for (int i = 0; i < S2; i++) 
    {
        wv[i] = (float *)malloc(S4 * sizeof(float));
    }
    // 複製輸入矩陣到動態陣列
    // Q1
    for(int i = 0 ; i < M; i++)
    {
        for(int j = 0 ; j < W; j++)
        {
            a[i][j] = A[i][j];
        }
    }
    for(int i = 0 ; i < W; i++)
    {
        for(int j = 0 ; j < N; j++)
        {
            b[i][j] = B[i][j];
        }
    }
    // Q2
    for(int i = 0 ; i < L; i++)
    {
        for(int j = 0 ; j < L; j++)
        {
            c[i][j] = C[i][j];
        }
    }
    for(int i = 0 ; i < K; i++)
    {
        for(int j = 0 ; j < K; j++)
        {
            d[i][j] = D[i][j];
        }
    }
    // Q3
    for(int i = 0 ; i < S1; i++)
    {
        for(int j = 0 ; j < S2; j++)
        {
            in[i][j] = IN[i][j];
        }
    }
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S3; j++)
        {
            wq[i][j] = Wq[i][j];
            wk[i][j] = Wk[i][j];
        }
    }
    for(int i = 0 ; i < S2; i++)
    {
        for(int j = 0 ; j < S4; j++)
        {
            wv[i][j] = Wv[i][j];
        }
    }
    
    //寫結果到Result_HW1.txt
    //開始使用前，設定file文件指針並以w模式開檔
    FILE *fptr;
    fptr = fopen("Result_HW1.txt","w");
    
    // Q1: 做matrix_mul
    float **matrix_mul_result = matrix_mul(a, b, M, W, W, N);
    //寫入檔案
    fprintf(fptr,"Q1\n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            fprintf(fptr,"%f ", matrix_mul_result[i][j]);

        }
        fprintf(fptr,"\n");
    }

    for (int i = 0; i < M; i++) {
        free(a[i]);
    }
    for (int i = 0; i < W; i++) {
        free(b[i]);
    }
    for (int i = 0; i < M; i++) {
        free(matrix_mul_result[i]);
    }
    free(a);
    free(b);
    free(matrix_mul_result);
    // Q2: 做conv2D
    float **conv2D_result = conv2D(c, d, L, K);
    //寫入檔案
    fprintf(fptr,"\nQ2\n");
    int t = L - K + 1; // 卷積完的size
    for (int i = 0; i < t; i++) {
        for (int j = 0; j < t; j++) {
            fprintf(fptr,"%f ", conv2D_result[i][j]);

        }
        fprintf(fptr,"\n");
    }

    for (int i = 0; i < L; i++) {
        free(c[i]);
    }
    for (int i = 0; i < K; i++) {
        free(d[i]);
    }
    for (int i = 0; i < t; i++) {
        free(conv2D_result[i]);
    }
    free(c);
    free(d);
    free(conv2D_result);
    // Q3: 做self-attention
    float **attention_result = attention(in, wq, wk, wv);
    //寫入檔案
    fprintf(fptr,"\nQ3\n");
    for (int i = 0; i < S1; i++) {
        for (int j = 0; j < S4; j++) {
            fprintf(fptr,"%f ", attention_result[i][j]);

        }
        fprintf(fptr,"\n");
    }
    // 釋放空間
    for (int i = 0; i < S1; i++) {
        free(in[i]);
        free(attention_result[i]);
    }
    for (int i = 0; i < S2; i++) {
        free(wq[i]);
        free(wk[i]);
        free(wv[i]);
    }
    free(in);
    free(wq);
    free(wk);
    free(wv);
    free(attention_result);
    //程式結束前閉檔
    fclose(fptr);
    return 0;
}
