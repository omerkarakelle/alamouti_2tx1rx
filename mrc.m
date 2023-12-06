%Omer Lutfu Karakelle

clc;
clear;
close all;


data = randi([0 1], 10^6, 1)';

snr_min = 0;
snr_max = 40;
snr_dB = [snr_min:1:snr_max];

sig = 1 - 2*data; %0 biti 1V ile, 1 biti ise -1V ile temsil edilecek
Ac = 1; %Genlik

x = Ac*sig;
Eb = Ac^2; %bit enerjisi
Nr = 4; %Alici anten sayisi
ber = [];
for snr_db = snr_min:snr_max
    pnoise = Eb./2./10.^(snr_db./10); %gurultu gucu
    n = []; %awgn 
    h = []; %kanallar
    r = []; %alicidaki isaretler bu matriste tutulacak (matrisin her bir satiri bir antenden alinan isareti tutacak)
    for i = 1:Nr
        n = [n; sqrt(pnoise) .* (randn(1, length(x)) + 1i*randn(1, length(x)))]; %awgn
        h = [h; 1/sqrt(2).*(randn(1, length(x)) + 1i*randn(1, length(x)))]; %kanal
    end
    r = h.*x + n; %antenlerden alinan isaretler r matrisinde tutuluyor. r matrisinin her bir satiri bir isareti temsil etmekte
    %a1 = abs(r).*exp(-1i.*angle(r)*180/pi); (Vucetic kitabindan ??)
    r = sum(conj(h).*r);
    decision = real(r) < 0;
    ber = [ber sum(xor(data, decision))/length(data)];
end

figure
semilogy(snr_dB, ber, 'LineWidth', 2)
title('Maximal Ratio Combining BER/SNR Egrisi')
xlabel('SNR_d_B')
ylabel('BER')
ylim([10^(-5) 1])