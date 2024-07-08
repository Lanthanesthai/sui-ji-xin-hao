% 清除工作空间和命令窗口
clear;
clc;

% 参数定义
N = 256;               % 信号长度
num_experiments = 100; % 实验次数
SNR_dB = [0, 10, 20, 30];  % SNR的dB值
H_actual = [1, 0.75, 0.8, 0.5, 0.3]; % 系统H(z)的实际系数
num_coefficients = length(H_actual); % 系统H(z)的系数数量

% 预分配MSE数组
MSE = zeros(num_experiments, num_coefficients, length(SNR_dB));

% 开始仿真
for idx = 1:length(SNR_dB)
    SNR_linear = 10^(SNR_dB(idx) / 10); % 将SNR从dB转换为线性值
    for k = 1:num_experiments
        % 生成零均值，2阶白噪声信号x(t)
        x = wgn(N, 1, 0, 'complex'); % 复高斯白噪声
        x = filter(1, [1 -0.75 0.82], x); % AR(2)过程
        % 通过系统H(z)
        y_clean = filter(H_actual, 1, x);
        % 添加高斯白噪声
        sigma_n = sqrt(mean(y_clean.^2) / SNR_linear); % 依据SNR计算噪声标准差
        n = sigma_n * randn(N, 1);
        % 含噪声的输出信号
        y_noisy = y_clean + n;
        % 利用互相关估计系统H(z)的系数
        Rxy = xcorr(y_noisy, x, num_coefficients - 1, 'unbiased'); % 互相关函数
        Rxx = xcorr(x, num_coefficients - 1, 'unbiased');          % 自相关函数
        Rxx_matrix = toeplitz(Rxx(num_coefficients:end));          % 构造Toeplitz矩阵
        H_estimated = Rxx_matrix \ Rxy(num_coefficients:end);      % 最小二乘估计  
        % 计算每个系数的MSE
        for coef_idx = 1:num_coefficients
            MSE(k, coef_idx, idx) = (abs(H_actual(coef_idx) - H_estimated(coef_idx))^2) / (abs(H_actual(coef_idx))^2);
        end
    end
end

% 计算每个SNR下的平均MSE
mean_MSE = mean(MSE, 1);

% 打印结果
disp('不同SNR下每个系数的平均MSE：');
for idx = 1:length(SNR_dB)
    fprintf('SNR = %d dB:\n', SNR_dB(idx));
    disp(array2table(squeeze(mean_MSE(:,:,idx)), 'VariableNames', strcat('Coef', string(1:num_coefficients))));
end
