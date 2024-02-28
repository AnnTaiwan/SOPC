## HW1 
### **Code** : matrix.c conv2D.c attention.c
1. `matrix.c`請以 C 程式實現矩陣相乘的功能，完成 matrix_mul(A, B)的函數，回傳 A,B
矩陣相乘的結果。A 的矩陣大小為 MxW, B 的矩陣大小為 WxN。
2. `conv2D.c`利用上述矩陣相乘函數實現一個二維捲積函數 conv2D(C, D)，C 的矩陣大小
為 LxL, D矩陣為捲積核心，其大小為 KxK。
3. `attention.c`利用上述矩陣相乘函數實現一個self-attention的函數
attention(IN,Wq,Wk,Wv )，IN 的矩陣大小為 S1xS2, Wq 的矩陣大小為 S2xS3,
Wk 的矩陣大小為 S2xS3, Wv 的矩陣大小為 S2xS4。  

Note: 上述維度資訊參數（M, W, N, K, S1, S2, S3, S4）請以#define 方式定義，以
方便後續更改實際參數值
### self-attention示意圖
![alt text](image-1.png)
![alt text](image-2.png)