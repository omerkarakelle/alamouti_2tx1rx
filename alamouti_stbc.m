clc;
clear;
close all;

%Omer Lutfu Karakelle

data = randi([0 1], 10^6, 1)';

snr_min = 0;
snr_max = 40;
snr_dB = [snr_min:1:snr_max]; %incelenmek istenen snr araligi

sig = 1 - 2*data; %0 biti 1V ile, 1 biti ise -1V ile temsil edilecek
Ac = 2; %Genlik

x = Ac*sig;
Eb = Ac^2; %bit enerjisi

x1 = x(1:2:length(x))/sqrt(2);
x2 = x(2:2:length(x))/sqrt(2);

ber = [];
for snr_db = snr_min:snr_max
    pnoise = Eb./2./10.^(snr_db./10);
    n1 = sqrt(pnoise) .* (randn(1, length(x)/2) + 1i*randn(1, length(x)/2));
    n2 = sqrt(pnoise) .* (randn(1, length(x)/2) + 1i*randn(1, length(x)/2));
    h1 = 1/sqrt(2).*(randn(1, length(x)/2) + 1i*randn(1, length(x)/2)); %1. kanal
    h2 = 1/sqrt(2).*(randn(1, length(x)/2) + 1i*randn(1, length(x)/2)); %2. kanal

    %alinan isaretler
    r1 = h1.*x1 + h2.*x2 + n1; 
    r2 = -h1.*conj(x2) + h2.*conj(x1) + n2;

    xg1 = conj(h1).*r1 + h2.*conj(r2);
    xg2 = conj(h2).*r1 - h1.*conj(r2);

    %maximum likelihood decoding
    d1 = (real(xg1) - 1/sqrt(2)).^2 + imag(xg1).^2; %x1 icin 1. uzaklık
    d2 = (real(xg1) + 1/sqrt(2)).^2 + imag(xg1).^2; %x1 icin 2. uzaklık
    xdec1 = d1 > d2; %argmin d^2(x1, xg1) -> (vucetic kitabindan)
    d1 = (real(xg2) - 1/sqrt(2)).^2 + imag(xg2).^2; %x2 icin 1. uzaklik
    d2 = (real(xg2) + 1/sqrt(2)).^2 + imag(xg2).^2; %x2 icin 2. uzaklik
    xdec2 = d1 > d2; %argmin d^2(x1, xg1) -> (vucetic kitabindan)
    
    %iletilen isaretler 1 ya da -1 olabilir ve olasiliklar esit
    %maximum likehood decoding yerine bu sekilde de oluyor:
    %xdec1 = xg1 < 0; 
    %xdec2 = xg2 < 0;

    decision = zeros(1, length(data)); %karar
    decision(1:2:length(data)) = xdec1;
    decision(2:2:length(data)) = xdec2;

    ber = [ber sum(xor(data, decision))/length(data)];
end

figure
semilogy(snr_dB, ber, 'LineWidth', 2)
title('Alamouti Uzay Zaman Blok Kodu BER/SNR Egrisi')
xlabel('E_b/N_0')
ylabel('BER')
ylim([10^(-5) 1])
