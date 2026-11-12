clc;
clear;
inc = 0.01; 

% --- PARÁMETROS DEL PROYECTO ---
h = 30; % Desplazamiento máximo (40 mm) para formato A3/A2
r_base = 40; % Radio base de 40 mm

% --- SECCIÓN 1: 0 a 90 (Reposo en 0) ---
ss1=[]; tt1=[];
for t=0 : inc : 90
    s1=0;
    ss1=[ss1 s1];
    tt1=[tt1 t];
end

% --- SECCIÓN 2: 90 a 180 (Subida de 0 a h) ---
% Se usa ECUACIÓN CICLOIDAL para evitar picos de aceleración al infinito
beta2 = 90; % Grados que dura la subida (180 - 90 = 90)
ss2=[]; tt2=[];
for t=(90 + inc) : inc : 180
    t_local = t - 90; % Ángulo relativo para esta sección
    s2 = h * ( (t_local/beta2) - (1/(2*pi)) * sin(2*pi*(t_local/beta2)) ); 
    ss2=[ss2 s2];
    tt2=[tt2 t];
end

% --- SECCIÓN 3: 180 a 270 (Reposo en compresión) ---
ss3=[]; tt3=[];
for t=(180 + inc) : inc : 270
    s3 = h;
    ss3=[ss3 s3];
    tt3=[tt3 t];
end

% --- SECCIÓN 4: 270 a 360 (Bajada de h a 0) ---
% Se usa ECUACIÓN CICLOIDAL para retorno suave
beta4 = 90; % Grados que dura la bajada (360 - 270 = 90)
ss4=[]; tt4=[];
for t=(270 + inc) : inc : 360
    t_local = t - 270; % Ángulo relativo para esta sección
    s4 = h * ( 1 - (t_local/beta4) + (1/(2*pi)) * sin(2*pi*(t_local/beta4)) ); 
    ss4=[ss4 s4]; 
    tt4=[tt4 t];
end

% --- CONCATENACIÓN ---
s=[ss1 ss2 ss3 ss4];
t=[tt1 tt2 tt3 tt4];

% --- CÁLCULOS CINEMÁTICOS ---
v=diff(s)./diff(t);
a=diff(v)./diff(t(1:end-1));

% --- GRÁFICAS LINEALES ---
figure(1)
subplot(3,1,1); plot(t,s, 'b', 'LineWidth', 2); ylabel("Desplazamiento (mm)"); grid on; title("Análisis de Movimiento (Sin Picos al Infinito)");
subplot(3,1,2); plot(t(1:end-1), v, 'r', 'LineWidth', 2); ylabel("Velocidad"); grid on;
subplot(3,1,3); plot(t(1:end-2), a, 'g', 'LineWidth', 2); ylabel("Aceleración"); xlabel("Ángulo (grados)"); grid on;

% --- GRÁFICA POLAR ---
figure(2)
d = r_base + s; % Radio base + desplazamiento
theta = (pi/180) * t; 
polarplot(theta, d, 'LineWidth', 2); 
title("Perfil de la Leva (Polar)");

% --- CONVERSIÓN A CARTESIANAS Y EXPORTACIÓN ---
[x, y] = pol2cart(theta, d); 
figure(3)
plot(x, y, 'LineWidth', 2); 
axis equal; % Evita que la leva se vea deformada
grid on;
title("Perfil de la Leva (Cartesianas)");
xlabel("X (mm)"); ylabel("Y (mm)");

% Preparación de vectores columna para evitar el error de "Table Variables"
x_col = x(:); 
y_col = y(:);
z_col = zeros(length(x_col), 1); 

% Creación de la tabla y exportación
tabla = table(x_col, y_col, z_col, 'VariableNames', {'X', 'Y', 'Z'});
writetable(tabla, 'perfil_leva.txt', 'Delimiter', '\t'); 
fprintf('¡Listo! Archivo "perfil_leva.txt" generado correctamente.\n');