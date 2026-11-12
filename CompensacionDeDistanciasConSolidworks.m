clc; clear; close all;

fprintf('Recogiendo a los niños\n');

try
    disp_sw = readtable('Desplazamiento.csv');
    vel_sw  = readtable('Velocidad.csv');
    acc_sw  = readtable('Aceleración.csv');
catch
    error('los niños no estan en el nido');
end

t = disp_sw{:, 1};
s_raw = disp_sw{:, 2};
v_raw = vel_sw{:, 2};
a_raw = acc_sw{:, 2};

ventana = 5; 

s_math = smoothdata(s_raw, 'movmean', ventana);
v_math = smoothdata(v_raw, 'movmean', ventana);
a_math = smoothdata(a_raw, 'movmean', ventana);

tabla_entrega = table(t, s_math, v_math, a_math, ...
    'VariableNames', {'Tiempo', 'Desplazamiento', 'Velocidad', 'Aceleracion'});

nombre_archivo = 'Compensacion_realizada.xlsx';
writetable(tabla_entrega, nombre_archivo);

fprintf('¡Listo! Archivo "%s" generado.\n', nombre_archivo);

% --- GRÁFICAS DE COMPROBACIÓN VISUAL ---
figure('Name', 'Datos compensados', 'Color', 'w');

subplot(3,1,1);
plot(t, s_math, 'b', 'LineWidth', 2); hold on;
plot(t, s_raw, 'r--', 'LineWidth', 1);
ylabel('Desplazamiento'); legend('MATLAB', 'SolidWorks', 'Location', 'best'); grid on;

subplot(3,1,2);
plot(t, v_math, 'b', 'LineWidth', 2); hold on;
plot(t, v_raw, 'r--', 'LineWidth', 1);
ylabel('Velocidad'); grid on;

subplot(3,1,3);
plot(t, a_math, 'b', 'LineWidth', 2); hold on;
plot(t, a_raw, 'r--', 'LineWidth', 1);
ylabel('Aceleración'); xlabel('Tiempo'); grid on;