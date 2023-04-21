import numpy as np
import matplotlib.pyplot as plt

# 信号生成
t = np.arange(0.1, 1.01, 0.01)
L = len(t)
x = np.zeros(L)
y = np.zeros((2, L))
for i in range(L):
    x[i] = t[i] ** 2
    y[0, i] = x[i] + np.random.normal(0, 0.1)
    y[1, i] = x[i] + np.random.normal(0, 0.1)

# 绘制图像
plt.plot(t, x, 'r', t, y[0, :], 'g', t, y[1, :], 'b', linewidth=2)
plt.show()

# 滤波算法
dt = t[1] - t[0]
F = np.array([[1, dt, 0.5 * dt ** 2], [0, 1, dt], [0, 0, 1]])
H = np.array([[1, 0, 0], [1, 0, 0]])
Q = np.array([[1, 0, 0], [0, 0.01, 0], [0, 0, 0.0001]])
R = np.array([[20, 0], [0, 20]])
Xplus = np.zeros((3, L))
Xplus[0, 0] = 0.1 ** 2
Xplus[1, 0] = 0
Xplus[2, 0] = 0
Pplus = np.array([[0.01, 0, 0], [0, 0.01, 0], [0, 0, 0.0001]])

for i in range(1, L):
    # 预测步
    Xminus = F @ Xplus[:, i - 1]
    Pminus = F @ Pplus @ F.T + Q
    # 更新步
    K = Pminus @ H.T @ np.linalg.inv(H @ Pminus @ H.T + R)
    Xplus[:, i] = Xminus + K @ (y[:, i] - H @ Xminus)
    Pplus = (np.eye(3) - K @ H) @ Pminus

# 绘制图像
plt.plot(t, x, 'r', t, y[0, :], 'g', t, y[1, :], 'b', t, Xplus[0, :], 'y', linewidth=2)
plt.show()
