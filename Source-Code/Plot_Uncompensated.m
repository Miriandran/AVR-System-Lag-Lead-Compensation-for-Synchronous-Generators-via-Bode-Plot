clc; clear; close all;
s = tf('s');

% Component transfer functions sesuai diagram:
% Amplifier: 10 / (0.1 s + 1)
Amp = 10 / (0.1*s + 1);

% Exciter: 1 / (0.4 s + 1)
Exc = 1 / (0.4*s + 1);

% Generator: 1 / (s + 1)
Gen = 1 / (s + 1);

% Sensor (feedback path): 1 / (0.01 s + 1)
H_sensor = 1 / (0.01*s + 1);

% Open-loop forward path G(s)
G = Amp * Exc * Gen;

% Loop transfer L(s) = G(s) * H(s) 
L = G * H_sensor;

% Closed-loop transfer from reference to output:
T = feedback(G, H_sensor);   % = G/(1 + G*H)


figure('Name','Bode & Margins','NumberTitle','off');
margin(L);                % shows gain/phase margins on Bode
grid on;
title('Bode plot');

% get numeric margin values
[Gm,Pm,Wcg,Wcp] = margin(L);
Gm_db = 20*log10(Gm);     % optional: convert gain margin to dB
fprintf('Gain margin = %.3f (%.2f dB) at w = %.3f rad/s\n', Gm, Gm_db, Wcg);
fprintf('Phase margin = %.3f deg at w = %.3f rad/s\n', Pm, Wcp);

% Bandwidth of closed-loop
bw_T = bandwidth(T);
fprintf('Closed-loop bandwidth = %.3f rad/s\n', bw_T);

% ======= NYQUIST PLOT =======
figure('Name','Nyquist','NumberTitle','off');
nyquist(L);
grid on;
title('Nyquist plot');

% ======= ROOT LOCUS =======
% Root locus typically plotted for K*L(s) (varying loop gain K)
figure('Name','Root Locus','NumberTitle','off');
rlocus(L);
title('Root locus');
grid on;
ylim([-10 10]);
xlim ([-110 10]);
% ======= POLES & ZEROS =======
poles_T = pole(T);
zeros_T = zero(T);
disp('Closed-loop poles:'); disp(poles_T);
disp('Closed-loop zeros:'); disp(zeros_T);

% Compare step response and mark time response =======
figure('Name','Step Response with Time Response Markers','NumberTitle','off');
[y_step,t_step] = step(T, 0:0.01:10);   % sesuaikan durasi 0:0.01:10
plot(t_step, y_step, 'LineWidth', 1.5); grid on; hold on;
xlabel('Time (s)'); ylabel('Output'); title('Step response of closed-loop T(s)');

% time response metrics
info = stepinfo(y_step, t_step);

% mark peak and times
plot(info.PeakTime, info.Peak, 'ro', 'MarkerSize',8, 'LineWidth',1.5);
xline(info.RiseTime, '--', 'Rise Time', 'LabelVerticalAlignment','bottom');
xline(info.SettlingTime, '--', 'Settling Time', 'LabelVerticalAlignment','bottom');
yline(info.SettlingMin, ':', 'Settling Min'); 
yline(info.SettlingMax, ':', 'Settling Max'); 
legend('Step response','Peak','Location','best');
text(info.PeakTime, info.Peak, sprintf(' Peak=%.3f',info.Peak), 'VerticalAlignment','bottom');

hold off;

