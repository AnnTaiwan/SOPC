import torch
import torch.nn.functional as F
import numpy as np
# conv2d
# 定義輸入矩陣C和卷積核D
# C = torch.tensor([[7.674, 4.665, 5.142, 7.712, 8.254, 6.869],
#                   [5.548, 7.645, 2.663, 2.758, 0.038, 2.860],
#                   [8.724, 9.742, 7.530, 0.779, 2.317, 3.036],
#                   [2.191, 1.843, 0.289, 0.107, 9.041, 8.943],
#                   [9.265, 2.649, 7.447, 3.806, 5.891, 6.730],
#                   [4.371, 5.351, 5.007, 1.102, 4.394, 3.549]])

# D = torch.tensor([[9.630, 2.624, 4.085],
#                   [9.955, 8.757, 1.841],
#                   [4.967, 7.377, 3.932]])

# # 將C和D轉換為四維張量，因為conv2d函數需要的輸入是四維的
# C = C.view(1, 1, *C.shape)
# D = D.view(1, 1, *D.shape)

# # 執行卷積操作
# conv_result = torch.conv2d(C, D)

# # 印出結果
# print(conv_result)

# # self_attention
# # 輸入數據
# IN = torch.tensor([[6.309, 6.945, 2.440],
#                     [4.627, 1.324, 5.538],
#                     [1.539, 6.119, 2.083],
#                     [2.930, 6.542, 4.834],
#                     [1.116, 4.640, 9.659]])

# Wq = torch.tensor([[2.705, 9.931, 3.978, 2.307],
#                     [1.674, 2.387, 5.022, 8.746],
#                     [6.925, 9.073, 6.271, 5.830]])

# Wk = torch.tensor([[6.778, 5.574, 5.098, 6.513],
#                     [3.987, 3.291, 9.162, 8.637],
#                     [2.356, 4.768, 3.656, 5.575]])

# Wv = torch.tensor([[4.032, 2.053, 7.351, 1.151, 6.942, 1.725],
#                     [3.967, 3.431, 1.108, 0.192, 8.008, 1.338],
#                     [5.458, 2.288, 7.754, 0.384, 4.946, 8.910]])
# # 計算Q, K, V
# Q = torch.matmul(IN, Wq)
# K = torch.matmul(IN, Wk)
# V = torch.matmul(IN, Wv)

# # 計算注意力分數
# scores = torch.matmul(Q, torch.transpose(K, 0, 1)) / torch.sqrt(torch.tensor(Q.shape[-1]).float())

# # 對注意力分數進行softmax
# attention_weights = F.softmax(scores, dim=-1)

# # 使用注意力權重加權V
# output = torch.matmul(attention_weights, V)

# print(output)
# A = torch.arange(2).reshape(1, 2)
# B = torch.arange(2, 6).reshape(2, 2)
# Result = torch.matmul(A, B)
# print(Result)

# A = torch.arange(40).reshape(8, 5)
# B = torch.arange(40, 70).reshape(5, 6)
# Result = torch.matmul(A, B)
# print(Result)

A = torch.arange(169).reshape(13, 13)
B = torch.arange(169, 2*169).reshape(13, 13)
Result = torch.matmul(A, B)
print(Result)

A = torch.arange(16).reshape(4, 4)
B = torch.arange(16, 2*16).reshape(4, 4)
Result = torch.matmul(A, B)
print(Result)
# A = torch.arange(1023, 959, -1).reshape(8, 8)
# B = torch.arange(959, 895, -1).reshape(8, 8)
# Result = torch.matmul(A, B)
# print(Result)

# A = torch.arange(64).reshape(8, 8)
# B = torch.arange(64, 128).reshape(8, 8)
# Result = torch.matmul(A, B)
# print(Result)

# Test data for matrix A (3x3)
matrixA = np.array([
    [0, 0, 0],
    [2, 2, 2],
    [4, 4, 4]
])

# Test data for matrix B (3x3)
matrixB = np.array([
    [0, 0, 0],
    [4, 4, 4],
    [8, 8, 8]
])

# Perform matrix multiplication
result = np.dot(matrixA, matrixB)

# Print the result
print("Matrix A:")
print(matrixA)
print("\nMatrix B:")
print(matrixB)
print("\nResult:")
print(result)