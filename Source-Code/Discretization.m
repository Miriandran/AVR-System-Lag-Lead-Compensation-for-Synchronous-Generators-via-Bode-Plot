clc; clear; close all;
s = tf('s');

Ts =0.001; %variasiin bebas


% Component transfer functions sesuai diagram:
% Amplifier: 10 / (0.1 s + 1)


Gain_system = 2;
Amp = 10 / (0.1*s + 1);
Ampz = c2d(Amp, Ts, 'zoh'); % Diskritisasi Amp

% Exciter: 1 / (0.4 s + 1)
Exc = 1 / (0.4*s + 1);
Excz = c2d(Exc, Ts, 'zoh');

% Generator: 1 / (s + 1)
Gen = 1 / (s + 1);
Genz = c2d(Gen, Ts, 'zoh'); % Diskritisasi Gen
 
% Sensor (feedback path): 1 / (0.01 s + 1)
H_sensor = 1 / (0.01*s + 1);
Hz = c2d(H_sensor, Ts, 'zoh'); % Diskritisasi H_sensor

% Compensator

Gain_lagc=0.1702; % Gain Lag Compensator
lagc = (s+0.5)/(s+0.085); % Lag Compensator
Gain_leadc =14.05; % Gain Lead Compensator
leadc = (s+1.3367)/(s+18.745); % Lead Compensator
lagcz = c2d(Gain_lagc/lagc, Ts, 'zoh'); %Diskritisasi Lag Compensator
leadcz = c2d(Gain_leadc/leadc, Ts, 'zoh'); % Diskritisasi Lead Compensator

% Open-loop forward path G(s)
G = Gain_system * Amp * Exc * Gen* Gain_lagc * lagc * Gain_leadc * leadc;
Gz = c2d(G, Ts, 'zoh');
% Loop transfer L(s) = G(s) * H(s) 
L = G * H_sensor;
Lz = Gz*Hz;

% Closed-loop transfer from reference to output:
T = feedback(G, H_sensor);   % = G/(1 + G*H)
Tz = feedback (Gz, Hz);


% ========= Time Response=======
figure
step(T, 'b')
hold on
step (Tz, 'r--');
legend ('Continuous', 'Discrete');
grid on;

info_kontinyu = stepinfo(T, 'SettlingTimeThreshold', 0.05);
info_diskrit= stepinfo(Tz, 'SettlingTimeThreshold', 0.05);

fprintf("----Diskrit-----\n")
disp(info_diskrit);

fprintf("-----Kontinyu-----\n")
disp(info_kontinyu);


% ========= Steady-State Error =========

% DC gain
dc_continuous = dcgain(T);
dc_discrete   = dcgain(Tz);

% Steady-state error untuk input step satuan
ess_continuous = abs(1 - dc_continuous);
ess_discrete   = abs(1 - dc_discrete);

fprintf("===== Steady-State Error =====\n");
fprintf("Kontinyu  ess = %.6f\n", ess_continuous);
fprintf("Diskrit   ess = %.6f\n", ess_discrete);


% ====== CARI RENTANG Ts STABIL ======
Ts_min = 0.001;
Ts_max = 0.5;
Ts_step = 0.001;

Ts_stable = [];

for Ts = Ts_min:Ts_step:Ts_max

    % Diskritisasi
    Gz = c2d(G, Ts, 'zoh');
    Hz = c2d(H_sensor, Ts, 'zoh');

    % Closed-loop
    Tz = feedback(Gz, Hz);

    % Ambil pole
    poles = pole(Tz);

    % Kriteria stabilitas diskrit
    if max(abs(poles)) < 1
        Ts_stable = [Ts_stable Ts];
    end
end


% ====== HASIL ======
fprintf("======Kriteria Ts=======\n");
if isempty(Ts_stable)
    disp('Tidak ada Ts yang stabil dalam rentang ini')
else
    fprintf('Ts stabil pada %.4f s <= Ts <= %.4f s\n', ...
            min(Ts_stable), max(Ts_stable));
end

