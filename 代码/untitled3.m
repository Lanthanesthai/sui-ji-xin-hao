% 参数定义
N = 256;            % 样本数
SNRs = [10, 20];    % 信噪比（以dB为单位）
num_experiments = 100; % 独立实验次数

% 实际传递函数 H(z) 的系数
h_true = [1, 0.75, 0.8, 0.5, 0.3];

% 生成二阶白信号 x(t)
x = rand(N, 1) - 0.5; % 生成[-0.5, 0.5]均匀分布的随机数，然后减去均值0.5

% 初始化存储功率谱密度的数组
PSD = cell(length(SNRs), 1);

for snr_idx = 1:length(SNRs)
    snr = SNRs(snr_idx);
    psd_sum = 0;
    
    for k = 1:num_experiments
        % 计算噪声方差
        noise_power = var(x) / (10^(snr/10));
        n = sqrt(noise_power) * randn(N, 1); % 具有零均值的高斯白噪声
        
        % 通过实际传递函数 H(z) 滤波
        y = filter(h_true, 1, x) + n;

        % 使用不同阶次的FIR滤波器估计 y(t) 的功率谱密度
        [pxx, f] = periodogram(y, [], [], 1);
        
        % 累加功率谱密度
        psd_sum = psd_sum + pxx;
    end

    % 计算平均功率谱密度
    PSD{snr_idx} = psd_sum / num_experiments;
end

% 绘制功率谱密度随频率变化的图
figure;
for snr_idx = 1:length(SNRs)
    subplot(length(SNRs), 1, snr_idx);
    plot(f, 10*log10(PSD{snr_idx}));
    title(['SNR = ', num2str(SNRs(snr_idx)), ' dB']);
    xlabel('Normalized Frequency');
    ylabel('Power/Frequency (dB/Hz)');
    grid on;
end
