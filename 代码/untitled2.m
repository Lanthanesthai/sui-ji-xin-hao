% 定义参数
N = 256;            % 样本数
SNRs = [0, 10, 20, 30]; % 信噪比（以dB为单位）
num_experiments = 100; % 独立实验次数

% 定义实际传递函数 H(z) 的系数
h_true = [1, 0.75, 0.8, 0.5, 0.3];

% 初始化存储MSE的数组
MSE = zeros(length(SNRs), 1);

% 生成二阶白信号 x(t)
x = rand(N, 1) - 0.5; % 生成[-0.5, 0.5]均匀分布的随机数，然后减去均值0.5

for snr_idx = 1:length(SNRs)
    snr = SNRs(snr_idx);
    mse_sum = 0;

    for k = 1:num_experiments
        % 计算噪声方差
        noise_power = var(x) / (10^(snr/10));
        n = sqrt(noise_power) * randn(N, 1); % 具有零均值的高斯白噪声
        
        % 通过实际传递函数 H(z) 滤波
        y = filter(h_true, 1, x) + n;

        % 使用互相关估计 H(z) 的系数
        rxy = xcorr(x, y, 'biased');
        rxx = xcorr(x, 'biased');
        
        % 计算 Rxx 矩阵
        Rxx = toeplitz(rxx(N:N+4));
        
        % 估计 H(z) 的系数
        h_est = Rxx \ rxy(N:N+4);
        
        % 计算每个系数的相对误差平方和
        mse_sum = mse_sum + sum((abs(h_true' - h_est) .^ 2) ./ abs(h_true') .^ 2);
    end

    % 计算平均MSE
    MSE(snr_idx) = mse_sum / num_experiments;
end

% 打印MSE结果
fprintf('SNR (dB) | MSE\n');
fprintf('-----------------\n');
for i = 1:length(SNRs)
    fprintf('%6d | %.6f\n', SNRs(i), MSE(i));
end

% 绘制MSE随SNR变化的图
figure;
plot(SNRs, MSE, '-o');
title('MSE vs SNR');
xlabel('SNR (dB)');
ylabel('MSE');
grid on;
