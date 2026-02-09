clc; clear; close all;
s = tf('s');

% Component transfer functions sesuai diagram:
% Amplifier: 10 / (0.1 s + 1)

Gain_system = 2;
Amp = 10 / (0.1*s + 1);


% Exciter: 1 / (0.4 s + 1)
Exc = 1 / (0.4*s + 1);

% Generator: 1 / (s + 1)
Gen = 1 / (s + 1);

% Sensor (feedback path): 1 / (0.01 s + 1)
H_sensor = 1 / (0.01*s + 1);


% Compensator

Gain_lagc=0.1702; % Gain Lag Compensator
lagc = (s+0.5)/(s+0.085); % Lag Compensator
Gain_leadc =14.05; % Gain Lead Compensator
leadc = (s+1.3367)/(s+18.745); % Lead Compensator


% Open-loop forward path G(s)
G = Gain_system * Amp * Exc * Gen* Gain_lagc * lagc * Gain_leadc * leadc;

% Loop transfer L(s) = G(s) * H(s) 
L = G * H_sensor;

% Closed-loop transfer from reference to output:
T = feedback(G, H_sensor);   % = G/(1 + G*H)

rlocus(L);
figure('Name','Bode & Margins','NumberTitle','off');
margin(L);                % shows gain/phase margins on Bode
grid on;
title('Bode plot');


% get numeric margin values
[Gm,Pm,Wcg,Wcp] = margin(L);
Gm_db = 20*log10(Gm);     % convert gain margin to dB
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

% ========= Time Response=======

figure
step(T, 'b')
grid on;