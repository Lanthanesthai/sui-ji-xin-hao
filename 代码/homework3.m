% 参数定义
N = 256; % 信号长度
SNR1 = 10; % 信噪比1（以dB为单位）
SNR2 = 20; % 信噪比2（以dB为单位）
Fs = 1000; % 采样频率
% 定义H(z)传递函数
b = [0, 0, 1]; % 传递函数分子系数
a = [1, -1.3, 0.845]; % 传递函数分母系数
H = filter(b, a, 1); % 生成传递函数
% 生成高斯白噪声n(t)
n = randn(1, N); % 高斯白噪声
% 生成输入信号x(t)
x = randn(1, N); % 高斯白噪声信号
% 将x(t)通过传递函数H(z)进行滤波，得到滤波信号x_filt
x_filt = filter(b, a, x); % 滤波后的信号
% 计算给定信噪比情况下的噪声方差
signal_power = var(x_filt); % 信号功率
noise_pow1 = signal_power / 10^(SNR1 / 10); % 噪声功率1
noise_pow2 = signal_power / 10^(SNR2 / 10); % 噪声功率2
% 生成含噪声的输出信号y(t)
y1 = x_filt + sqrt(noise_pow1) * n; % SNR = 10dB时的含噪声信号
y2 = x_filt + sqrt(noise_pow2) * n; % SNR = 20dB时的含噪声信号
%% 周期图法（Periodogram method）
[py1, f] = periodogram(y1, [], [], Fs); % 周期图法功率谱估计 SNR = 10dB
[py2, ~] = periodogram(y2, [], [], Fs); % 周期图法功率谱估计 SNR = 20dB
%% 自相关函数法（Bartlett方法）
Ry1 = xcorr(y1, 'biased'); % 自相关函数 SNR = 10dB
Ry2 = xcorr(y2, 'biased'); % 自相关函数 SNR = 20dB
[Py1, f_bartlett] = periodogram(Ry1, [], [], Fs); % 自相关函数法功率谱估计 SNR = 10dB
[Py2, ~] = periodogram(Ry2, [], [], Fs); % 自相关函数法功率谱估计 SNR = 20dB
%% 现代功率谱估计方法（Burg方法）
order = 4; % AR模型阶数
[arPy1, f_burg] = pburg(y1, order, [], Fs); % Burg方法功率谱估计 SNR = 10dB
[arPy2, ~] = pburg(y2, order, [], Fs); % Burg方法功率谱估计 SNR = 20dB
%% 转换为dB/Hz
py1_dB = 10 * log10(py1); % 周期图法 SNR = 10dB
py2_dB = 10 * log10(py2); % 周期图法 SNR = 20dB
Py1_dB = 10 * log10(Py1); % 自相关函数法 SNR = 10dB
Py2_dB = 10 * log10(Py2); % 自相关函数法 SNR = 20dB
arPy1_dB = 10 * log10(arPy1); % Burg方法 SNR = 10dB
arPy2_dB = 10 * log10(arPy2); % Burg方法 SNR = 20dB
%% SNR = 10dB 时的功率谱密度图
figure;
plot(f, py1_dB, 'r'); % 绘制周期图法的功率谱密度
title('SNR = 10dB 周期图法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签

figure;
plot(f_bartlett, Py1_dB, 'r'); % 绘制自相关函数法的功率谱密度
title('SNR = 10dB 自相关函数法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签

figure;
plot(f_burg, arPy1_dB, 'r'); % 绘制Burg方法的功率谱密度
title('SNR = 10dB Burg方法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签
%% SNR = 20dB 时的功率谱密度图
figure;
plot(f, py2_dB, 'r'); % 绘制周期图法的功率谱密度
title('SNR = 20dB 周期图法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签

figure;
plot(f_bartlett, Py2_dB, 'r'); % 绘制自相关函数法的功率谱密度
title('SNR = 20dB 自相关函数法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签

figure;
plot(f_burg, arPy2_dB, 'r'); % 绘制Burg方法的功率谱密度
title('SNR = 20dB Burg方法'); % 标题
xlabel('归一化频率'); % x轴标签
ylabel('功率/频率 (dB/Hz)'); % y轴标签


