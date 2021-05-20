clear;
clc;

Fs = 1e6;            % 采样率
BW = 5e5;            % 带宽
SF = 12;             % 扩频因子
M = 2^SF*Fs/BW;      % 采样点数
a(1:1:M)=0;          % 频率累加器
b(1:1:M)=0;          % 相位累加器
upchirp_I(1:1:M)=0;  % I 路输出
upchirp_Q(1:1:M)=0;  % Q 路输出
K = 2^(22 - SF);     % 调频斜率(调SF，每一个chirp中的点数)
Kc = 0;              % 频率控制字
N = 22;              % 幅度量化位数（调整幅度能量）
L = 24;              % 相位累加器位数

% 设置频率步进量
a(1) = -0.5*K; 
for i = 2:1:M
    a(i) = a(i-1)+K;
end

% 设置相位步进量
b(1) = Kc+a(1);
for i=2:1:M
    b(i) = b(i-1)+(Kc+a(i));
end

for i=1:1:M
    b(i) = mod(2*pi/(2^L)*b(i), 2 * pi);
end

% upchirp 两路信号
for i = 1:1:M
   upchirp_I(i) = floor(2^N*cos(b(i)));
end

for i = 1:1:M
   upchirp_Q(i) = floor(2^N*sin(b(i)));
end

% 生成归一化复信号 upchirp
upchirp = complex(upchirp_I, upchirp_Q);
upchirp = upchirp / mean(abs(upchirp));

% 生成标准 downchirp
down_chirp = chirp(0:1/Fs:2^SF/BW - 1/Fs, 0, 2^SF/BW, -BW,'linear',0,'complex');

% dechirp
dechirp = upchirp .* down_chirp;

% dechirp FFT
figure;
plot(abs(fft(dechirp)));
xlabel('FFT bin'); ylabel('amplitude');
title('FFT of dechirp');

% dechirp 相位
figure;
plot(unwrap(angle(dechirp)));
xlabel('Time (Seconds)'); ylabel('phase');
title('unwrap phase of dechirp');

% 时频图
figure;
[~,F,T,P] = spectrogram(dechirp,100,99,100,Fs);
surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');
title('dechirp');

figure;
[~,F,T,P] = spectrogram(upchirp,100,99,100,Fs);
surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');
title('upchirp(DDS generate)');

figure;
[~,F,T,P] = spectrogram(down_chirp,100,99,100,Fs);
surf(T,F,10*log10(P),'edgecolor','none'); axis tight;
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');
title('downchirp(matlab lib func)');


