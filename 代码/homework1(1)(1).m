% 设置题目的基本参数
N = 256;  % 信号长度
t = 1:N;  % 时间范围
SNRs = [10, 20];  % 题目要求的信噪比

% 生成零均值二阶白信号 x(t)
x = randn(1, N);  % 生成长度为 N 的零均值二阶白信号

% 定义系统 H(z) 的传递函数
b = [1];  % H(z) 的分子系数
a = [1, -1.3, 0.845];  % H(z) 的分母系数

% 生成 x(t) 经过滤波器 H(z) 后的信号 y_clean（无噪声）
y_clean = filter(b, a, x);  % 滤波

% 画图
figure;

% 循环两次，分别是 SNR=10 和 SNR=20 的情况
for i = 1:length(SNRs)
    SNR = SNRs(i);

    % 计算噪声功率
    signal_power = var(y_clean);  % 信号的功率
    noise_power = signal_power / (10^(SNR/10));  % 计算噪声功率
    
    % 生成零均值高斯白噪声干扰
    noise = sqrt(noise_power) * randn(1, N);

    % 加上白噪声后的系统输出信号
    y = y_clean + noise;

    % 计算自相关和互相关
    [Rxx, lags_xx] = xcorr(x, 'biased');
    [Ryy, lags_yy] = xcorr(y, 'biased');
    [Rxy, lags_xy] = xcorr(x, y, 'biased');

    % 绘制自相关函数和互相关函数的图像
    subplot(2, length(SNRs), i)
    plot(lags_xx, Rxx);
    hold on;
    plot(lags_yy, Ryy);
    title(['SNR = ', num2str(SNR), ' dB']);
    legend('Rxx', 'Ryy');
    xlabel('滞后时间');
    ylabel('自相关');

    subplot(2, length(SNRs), i + length(SNRs));
    plot(lags_xy, Rxy);
    title(['SNR = ', num2str(SNR), ' dB']);
    legend('Rxy');
    xlabel('滞后时间');
    ylabel('互相关');
end
