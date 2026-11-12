# Prototipo de compactadora de papel con leva

Máquina que compacta papel con un pistón movido por una leva. Un motor de CD se controla con una ESP32 desde una interfaz web.

Proyecto integrador de Ingeniería en Mecatrónica (mecanismos), Universidad Tecnológica Metropolitana (UTM), Mérida, 2026. Proyecto en equipo.

## Qué se hizo
- **Diseño de la leva:** perfil calculado en MATLAB (desplazamiento, velocidad, aceleración y jerk) y comparado con el modelo en SolidWorks.
- **Diseño mecánico:** piezas en SolidWorks e impresas en 3D con Bambu Studio.
- **Control:** ESP32 + puente H L298N con encendido, sentido de giro y velocidad (PWM) desde una página web servida por la ESP32 en modo Access Point.

## Archivos
| Archivo | Contenido |
|---|---|
| `compactadora.ino` | Firmware de la ESP32: control del motor e interfaz web |
| `levaParaGenerarPerfil.m` | Genera el perfil de la leva |
| `LevaConGraficaJerk.m` | Gráficas de desplazamiento, velocidad, aceleración y jerk |
| `CompensacionDeDistanciasConSolidworks.m` | Comparación de distancias con el modelo de SolidWorks |
