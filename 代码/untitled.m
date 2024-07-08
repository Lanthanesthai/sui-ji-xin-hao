% 定义参数
N = 256;             % 样本数
SNRs = [10, 20];     % 信噪比（以dB为单位）

% 定义传递函数 H(z)
z = tf('z', 1);                      % 定义 z 作为 z 域中的变量
H = 1 / ((z - (0.65 + 0.65i)) * (z - (0.65 - 0.65i)));  % 传递函数 H(z)

% 生成二阶白信号 x(t)
x = rand(N, 1) - 0.5;   % 生成[-0.5, 0.5]均匀分布的随机数，然后减去均值0.5

% 初始化结果数组
autocorr_x = cell(length(SNRs), 1);
autocorr_y = cell(length(SNRs), 1);
crosscorr_xy = cell(length(SNRs), 1);

% 遍历每个 SNR 值
for i = 1:length(SNRs)
    % 计算给定 SNR 的噪声方差
    snr = SNRs(i);
    noise_power = var(x) / (10^(snr/10));
    n = sqrt(noise_power) * randn(N, 1); % 具有零均值的高斯白噪声
    
    % 信号通过 H(z) 滤波
    y = lsim(H, x, 0:(N-1)) + n;    % 使用 lsim 进行时域仿真
    
    % 计算 x(t) 的自相关函数
    autocorr_x{i} = my_xcorr(x, x);  
    
    % 计算 y(t) 的自相关函数
    autocorr_y{i} = my_xcorr(y, y);
    
    % 计算 x(t) 和 y(t) 之间的互相关函数
    crosscorr_xy{i} = my_xcorr(x, y);
end

% 绘制结果
figure;
for i = 1:length(SNRs)
    lags = -(N-1):(N-1);
    
    % 绘制 x(t) 的自相关函数
    subplot(length(SNRs), 3, (i-1)*3 + 1);
    plot(lags, autocorr_x{i});
    title(['SNR = ', num2str(SNRs(i)), ' dB 时 x(t) 的自相关函数']);
    xlabel('滞后');
    ylabel('自相关');
    legend(['SNR = ', num2str(SNRs(i))]); % Add legend

    % 绘制 y(t) 的自相关函数
    subplot(length(SNRs), 3, (i-1)*3 + 2);
    plot(lags, autocorr_y{i});
    title(['SNR = ', num2str(SNRs(i)), ' dB 时 y(t) 的自相关函数']);
    xlabel('滞后');
    ylabel('自相关');
    legend(['SNR = ', num2str(SNRs(i))]); % Add legend

    % 绘制 x(t) 和 y(t) 之间的互相关函数
    subplot(length(SNRs), 3, (i-1)*3 + 3);
    plot(lags, crosscorr_xy{i});
    title(['SNR = ', num2str(SNRs(i)), ' dB 时 x(t) 和 y(t) 之间的互相关函数']);
    xlabel('滞后');
    ylabel('互相关');
    legend(['SNR = ', num2str(SNRs(i))]); % Add legend
end

% 保存图形
saveas(gcf, ['correlations_SNR' num2str(SNRs(1)) '_SNR' num2str(SNRs(2)) '.png']); 

% 定义自相关和互相关函数的计算函数
function r = my_xcorr(x, y)
    N = length(x);
    r = zeros(2*N-1, 1);
    for lag = -(N-1):(N-1)
        idx = lag + N;
        if lag < 0
            r(idx) = sum(x(1:end+lag) .* y(1-lag:end)) / N;
        else
            r(idx) = sum(x(1+lag:end) .* y(1:end-lag)) / N;
        end
    end
end
