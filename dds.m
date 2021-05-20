clear;
clc;

Fs = 1e6;            % ������
BW = 5e5;            % ����
SF = 12;             % ��Ƶ����
M = 2^SF*Fs/BW;      % ��������
a(1:1:M)=0;          % Ƶ���ۼ���
b(1:1:M)=0;          % ��λ�ۼ���
upchirp_I(1:1:M)=0;  % I ·���
upchirp_Q(1:1:M)=0;  % Q ·���
K = 2^(22 - SF);     % ��Ƶб��(��SF��ÿһ��chirp�еĵ���)
Kc = 0;              % Ƶ�ʿ�����
N = 22;              % ��������λ������������������
L = 24;              % ��λ�ۼ���λ��

% ����Ƶ�ʲ�����
a(1) = -0.5*K; 
for i = 2:1:M
    a(i) = a(i-1)+K;
end

% ������λ������
b(1) = Kc+a(1);
for i=2:1:M
    b(i) = b(i-1)+(Kc+a(i));
end

for i=1:1:M
    b(i) = mod(2*pi/(2^L)*b(i), 2 * pi);
end

% upchirp ��·�ź�
for i = 1:1:M
   upchirp_I(i) = floor(2^N*cos(b(i)));
end

for i = 1:1:M
   upchirp_Q(i) = floor(2^N*sin(b(i)));
end

% ���ɹ�һ�����ź� upchirp
upchirp = complex(upchirp_I, upchirp_Q);
upchirp = upchirp / mean(abs(upchirp));

% ���ɱ�׼ downchirp
down_chirp = chirp(0:1/Fs:2^SF/BW - 1/Fs, 0, 2^SF/BW, -BW,'linear',0,'complex');

% dechirp
dechirp = upchirp .* down_chirp;

% dechirp FFT
figure;
plot(abs(fft(dechirp)));
xlabel('FFT bin'); ylabel('amplitude');
title('FFT of dechirp');

% dechirp ��λ
figure;
plot(unwrap(angle(dechirp)));
xlabel('Time (Seconds)'); ylabel('phase');
title('unwrap phase of dechirp');

% ʱƵͼ
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


