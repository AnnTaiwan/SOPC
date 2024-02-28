#include <stdio.h>
#include <stdlib.h>
// define 參數
// matrix A(M*W)
// matrix B(W*N)    
#define M 10
#define W 9
#define N 10
#define L 6
#define K 3
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

int** conv2D(int **C, int **D) {
    int final_size = L - K + 1; // 結果矩陣大小
    int **conv2D_result = (int **)malloc(final_size * sizeof(int *));
    for (int i = 0; i < final_size; i++) 
    {
        conv2D_result[i] = (int *)malloc(final_size * sizeof(int));
    }

    // 把subspace of C(K*K)轉為一直線(1*(K^2))，存入C_sub_flat
    int **C_sub_flat  = (int **)malloc(1 * sizeof(int *));
    // 把kernel D(K*K)轉為一直線((K^2)*1)，存入D_flat
    int **D_flat = (int **)malloc(K * K * sizeof(int *));
    for (int i = 0; i < 1; i++) {
        C_sub_flat[i] = (int *)malloc(K * K * sizeof(int));
    }
    for (int i = 0; i < K * K; i++) {
        D_flat[i] = (int *)malloc(1 * sizeof(int));
    }
    // 把kernel D(K*K)轉為一直線(K*1)
    int count = 0; // 計當前格數
    for (int q = 0; q < K; q++)  
    {
        for (int u = 0; u < K; u++) 
        {
            D_flat[count++][0] = D[q][u];
        }
    }
    int x = 0, y = 0; // 紀錄當前視窗最左上角的座標
    for(int h = 0; h < final_size; h++)
    {
        for(int p = 0; p < final_size; p++)
        {
            // 把subspace of C(K*K)轉為一直線(1*K)
            count = 0;
            for (int q = 0; q < K; q++) 
            {
                for (int u = 0; u < K; u++) 
                {
                    C_sub_flat[0][count++] = C[x + q][y + u];
                }
            }
            // C_sub_flat(1 * K) * D_flat(K * 1) 做矩陣乘法
            int **result = matrix_mul(C_sub_flat, D_flat, 1, K * K, K * K, 1); // r is 1*1 matrix.
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
    for (int i = 0; i < K * K; i++) {
        free(D_flat[i]);
    }
    free(C_sub_flat);
    free(D_flat);


    return conv2D_result;
}
int main() {
    // 配置C D空間
    int **A = (int **)malloc(L * sizeof(int *));
    int **B = (int **)malloc(K * sizeof(int *));
    for (int i = 0; i < L; i++) {
        A[i] = (int *)malloc(L * sizeof(int));
    }
    for (int i = 0; i < K; i++) {
        B[i] = (int *)malloc(K * sizeof(int));
    }

    // 輸入A B matrix
    int num = 0; // input number
    printf("Please input the matrix C(%d * %d):\n", L, L);
    for(int i = 0 ; i < L; i++)
    {
        for(int j = 0 ; j < L; j++)
        {
            scanf("%d", &num);
            A[i][j] = num;
        }
    }
    printf("Please input the kernel D(%d * %d):\n", K, K);
    for(int i = 0 ; i < K; i++)
    {
        for(int j = 0 ; j < K; j++)
        {
            scanf("%d", &num);
            B[i][j] = num;
        }
    }
    
    // 做卷積乘法
    int **conv2D_result = conv2D(A, B);

    printf("\nResult:\n");
    for (int i = 0; i < L - K + 1; i++) {
        for (int j = 0; j < L - K + 1; j++) {
            printf("%d ", conv2D_result[i][j]);
        }
        printf("\n");
    }

    for (int i = 0; i < L; i++) {
        free(A[i]);
    }
    for (int i = 0; i < K; i++) {
        free(B[i]);
    }
    for (int i = 0; i < L - K + 1; i++) {
        free(conv2D_result[i]);
    }
    free(A);
    free(B);
    free(conv2D_result);

    return 0;
}
