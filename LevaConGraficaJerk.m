clc;
clear;
inc = 0.01; 

% --- PARÁMETROS DEL PROYECTO ---
h = 30; % Desplazamiento máximo
r_base = 40; % Radio base de 40 mm

% Coeficientes de tus cálculos matriciales (Polinomio grado 7)
% Subida
C4_s = 1050; C5_s = -2520; C6_s = 2100; C7_s = -600;
% Bajada
C4_b = -1050; C5_b = 2520; C6_b = -2100; C7_b = 600;

% --- SECCIÓN 1: 0 a 90 (Reposo en 0) ---
ss1=[]; tt1=[]; jj1=[];
for t=0 : inc : 90
    s1=0;
    j1=0; % Jerk es 0 en reposo
    ss1=[ss1 s1];
    tt1=[tt1 t];
    jj1=[jj1 j1];
end

% --- SECCIÓN 2: 90 a 180 (Subida de 0 a h) ---
beta2 = 90; 
ss2=[]; tt2=[]; jj2=[];
for t=(90 + inc) : inc : 180
    t_local = t - 90; 
    x = t_local / beta2; % X normalizada (0 a 1)
    
    % Posición (Código original: Cicloidal)
    s2 = h * ( (x) - (1/(2*pi)) * sin(2*pi*(x)) ); 
    
    % Jerk (De tus apuntes: Y''' de polinomio 4-5-6-7)
    % Se multiplica por (1/beta2)^3 por la regla de la cadena para derivar respecto al ángulo
    j2 = (24*C4_s*(x) + 60*C5_s*(x^2) + 120*C6_s*(x^3) + 210*C7_s*(x^4)) * (1/beta2)^3;
    
    ss2=[ss2 s2];
    tt2=[tt2 t];
    jj2=[jj2 j2];
end

% --- SECCIÓN 3: 180 a 270 (Reposo en compresión) ---
ss3=[]; tt3=[]; jj3=[];
for t=(180 + inc) : inc : 270
    s3 = h;
    j3 = 0; % Jerk es 0 en reposo
    ss3=[ss3 s3];
    tt3=[tt3 t];
    jj3=[jj3 j3];
end

% --- SECCIÓN 4: 270 a 360 (Bajada de h a 0) ---
beta4 = 90; 
ss4=[]; tt4=[]; jj4=[];
for t=(270 + inc) : inc : 360
    t_local = t - 270; 
    x = t_local / beta4; % X normalizada (0 a 1)
    
    % Posición (Código original: Cicloidal)
    s4 = h * ( 1 - (x) + (1/(2*pi)) * sin(2*pi*(x)) ); 
    
    % Jerk (De tus apuntes: Y''' de polinomio 4-5-6-7 para la bajada)
    j4 = (24*C4_b*(x) + 60*C5_b*(x^2) + 120*C6_b*(x^3) + 210*C7_b*(x^4)) * (1/beta4)^3;
    
    ss4=[ss4 s4]; 
    tt4=[tt4 t];
    jj4=[jj4 j4];
end

% --- CONCATENACIÓN ---
s=[ss1 ss2 ss3 ss4];
t=[tt1 tt2 tt3 tt4];
jerk=[jj1 jj2 jj3 jj4]; % Vector completo de Jerk analítico

% --- CÁLCULOS CINEMÁTICOS (Numéricos para V y A) ---
v=diff(s)./diff(t);
a=diff(v)./diff(t(1:end-1));

% --- GRÁFICAS LINEALES ---
figure(1)
subplot(4,1,1); plot(t,s, 'b', 'LineWidth', 2); ylabel("Desplazamiento"); grid on; title("Análisis de Movimiento");
subplot(4,1,2); plot(t(1:end-1), v, 'r', 'LineWidth', 2); ylabel("Velocidad"); grid on;
subplot(4,1,3); plot(t(1:end-2), a, 'g', 'LineWidth', 2); ylabel("Aceleración"); grid on;
subplot(4,1,4); plot(t, jerk, 'm', 'LineWidth', 2); ylabel("Jerk"); xlabel("Ángulo (grados)"); grid on;

% --- GRÁFICA POLAR ---
figure(2)
d = r_base + s; 
theta = (pi/180) * t; 
polarplot(theta, d, 'LineWidth', 2); 
title("Perfil de la Leva (Polar)");

% --- CONVERSIÓN A CARTESIANAS Y EXPORTACIÓN ---
[x_cart, y_cart] = pol2cart(theta, d); 
figure(3)
plot(x_cart, y_cart, 'LineWidth', 2); 
axis equal; 
grid on;
title("Perfil de la Leva (Cartesianas)");
xlabel("X (mm)"); ylabel("Y (mm)");

% Preparación de vectores columna
x_col = x_cart(:); 
y_col = y_cart(:);
z_col = zeros(length(x_col), 1); 

% Creación de la tabla y exportación
tabla = table(x_col, y_col, z_col, 'VariableNames', {'X', 'Y', 'Z'});
writetable(tabla, 'perfil_leva.txt', 'Delimiter', '\t'); 
fprintf('¡Listo! Archivo "perfil_leva.txt" generado correctamente.\n');