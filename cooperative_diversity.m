%Omer Lutfu Karakelle

clc;
clear;
close all;


data = randi([0 1], 10^6, 1)';

snr_min = 0;
snr_max = 40;
snr_dB = [snr_min:1:snr_max];

s = 1 - 2*data;
a = ['b' 'g' 'o' 'p'];
for m = 1:4
    %kaynakla alici arasindaki kanallar
    pd = makedist('nakagami',mu=m, omega=1);
    h_sd = random(pd, 1, length(s)).*exp(1i.*unifrnd(0, 2*pi, 1, length(s)));
    
    %röle ile alici arasindaki kanallar
    h_rd = random(pd, 1, length(s)).*exp(1i.*unifrnd(0, 2*pi, 1, length(s)));
    
    %kaynakla röle arasindaki kanal
    h_sr = random(pd, 1, length(s)).*exp(1i.*unifrnd(0, 2*pi, 1, length(s)));
    
    ber = [];
    for snr_db = snr_min:snr_max
        pnoise = 1./10.^(snr_db./10); %noise power N0
        
        n1 = sqrt(pnoise) .* (randn(1, length(s)) + 1i*randn(1, length(s))); %awgn
        n2 = sqrt(pnoise) .* (randn(1, length(s)) + 1i*randn(1, length(s))); %awgn
        n3 = sqrt(pnoise) .* (randn(1, length(s)) + 1i*randn(1, length(s))); %awgn
    
        %faz1
        x_r = h_sr.*s + n1;
        x_d = h_sd.*s + n2;
    
        %faz2
    
        s_r = x_r ./ sqrt(pnoise + abs(h_sr).^2);
    
        y_d = h_rd.*s_r + n3;
    
        h_srd = h_sr.*h_rd./sqrt(pnoise + abs(h_sr).^2);
        g = abs(h_rd).^2*pnoise./(pnoise + abs(h_sr).^2) + pnoise;
    
        a = conj(h_sd).*x_d/pnoise;
        b = conj(h_srd).*y_d./g;
        z = a + b;
        %karar
        decision = real(z) < 0;
        ber = [ber sum(xor(data, decision))/length(data)];
    end
    
    semilogy(snr_dB, ber, 'LineWidth', 2)
    hold on
    grid on
    title('Amplify and Forward BER/SNR Egrisi')
    xlabel('SNR_d_B')
    ylabel('BER')
    ylim([10^(-5) 1])
end
legend('m = 1', 'm = 2', 'm = 3', 'm = 4')
hold off