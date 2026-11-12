#include <WiFi.h>
#include <WebServer.h>

// ==========================================
// 1. CONFIGURACIÓN DEL NUEVO WIFI (TÚ LO CREAS)
// ==========================================
const char* ssid = "Motor_ESP32";     // Nombre de la red que creará el ESP32
const char* password = "password123"; // Contraseña (mínimo 8 caracteres)

// ==========================================
// 2. DEFINICIÓN DE PINES (ESP32)
// ==========================================
#define LED_PIN 2   // El LED azul integrado
#define IN1_PIN 26  // Conectar a IN1 del L298N
#define IN2_PIN 27  // Conectar a IN2 del L298N
#define ENA_PIN 14  // Conectar a ENA del L298N

WebServer server(80);

// Variables de estado del motor
bool motorState = false;
bool motorDirection = true; 
int motorSpeed = 128; // Rango para ESP32 es 0 - 255

// ==========================================
// 3. INTERFAZ GRÁFICA (HTML, CSS, JS)
// ==========================================
const char webpage[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard ESP32 - Motor</title>
  <style>
    :root {
      --bg: #0f172a; --card-bg: #1e293b; --text: #f8fafc;
      --primary: #3b82f6; --danger: #ef4444;
    }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      background-color: var(--bg); color: var(--text);
      display: flex; justify-content: center; align-items: center;
      height: 100vh; margin: 0;
    }
    .dashboard {
      background-color: var(--card-bg); padding: 40px;
      border-radius: 20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.5);
      text-align: center; width: 100%; max-width: 350px;
    }
    h2 { margin-top: 0; margin-bottom: 30px; letter-spacing: 1px; }
    button {
      width: 100%; padding: 15px; border: none; border-radius: 10px;
      font-size: 16px; font-weight: bold; color: white; cursor: pointer;
      margin-bottom: 15px; transition: 0.3s;
    }
    #powerBtn { background-color: var(--primary); }
    #powerBtn.active { background-color: var(--danger); }
    #dirBtn { background-color: #475569; }
    
    .slider-container { margin-top: 30px; text-align: left; }
    .slider-container label { display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 15px;}
    
    input[type=range] { -webkit-appearance: none; width: 100%; background: transparent; }
    input[type=range]::-webkit-slider-thumb {
      -webkit-appearance: none; height: 24px; width: 24px;
      border-radius: 50%; background: var(--primary); cursor: pointer;
      margin-top: -8px; box-shadow: 0 0 10px rgba(59, 130, 246, 0.5);
    }
    input[type=range]::-webkit-slider-runnable-track {
      width: 100%; height: 8px; cursor: pointer; background: #334155; border-radius: 5px;
    }
  </style>
</head>
<body>
  <div class="dashboard">
    <h2>CONTROL DE MOTOR</h2>
    <button id="powerBtn" onclick="togglePower()">ENCENDER MOTOR</button>
    <button id="dirBtn" onclick="toggleDirection()">Sentido: ADELANTE</button>
    
    <div class="slider-container">
      <label>Velocidad (0-255): <span id="speedVal">128</span></label>
      <input type="range" id="speedRange" min="0" max="255" value="128" 
             oninput="updateUI(this.value)" onchange="sendSpeed(this.value)">
    </div>
  </div>

  <script>
    let power = false;
    let direction = true;

    function togglePower() {
      power = !power;
      const btn = document.getElementById('powerBtn');
      btn.innerText = power ? "APAGAR MOTOR" : "ENCENDER MOTOR";
      btn.classList.toggle('active');
      sendCommand('power', power ? 1 : 0);
    }

    function toggleDirection() {
      direction = !direction;
      document.getElementById('dirBtn').innerText = direction ? "Sentido: ADELANTE" : "Sentido: ATRÁS";
      sendCommand('dir', direction ? 1 : 0);
    }

    function updateUI(val) { document.getElementById('speedVal').innerText = val; }
    function sendSpeed(val) { sendCommand('speed', val); }

    function sendCommand(param, value) {
      fetch(`/update?${param}=${value}`)
        .then(response => { if(!response.ok) console.error("Error en conexión"); });
    }
  </script>
</body>
</html>
)rawliteral";

// ==========================================
// 4. LÓGICA DEL SERVIDOR Y HARDWARE
// ==========================================

void handleRoot() {
  server.send(200, "text/html", webpage);
}

void applyMotorState() {
  if (!motorState) {
    digitalWrite(IN1_PIN, LOW);
    digitalWrite(IN2_PIN, LOW);
    analogWrite(ENA_PIN, 0);
    return;
  }

  analogWrite(ENA_PIN, motorSpeed);

  if (motorDirection) {
    digitalWrite(IN1_PIN, HIGH);
    digitalWrite(IN2_PIN, LOW);
  } else {
    digitalWrite(IN1_PIN, LOW);
    digitalWrite(IN2_PIN, HIGH);
  }
}

void handleUpdate() {
  if (server.hasArg("power")) { motorState = server.arg("power").toInt(); }
  if (server.hasArg("dir")) { motorDirection = server.arg("dir").toInt(); }
  if (server.hasArg("speed")) { motorSpeed = server.arg("speed").toInt(); }
  
  applyMotorState();
  server.send(200, "text/plain", "OK");
}

void setup() {
  Serial.begin(115200);
  
  // Configuración de pines
  pinMode(LED_PIN, OUTPUT);
  pinMode(IN1_PIN, OUTPUT);
  pinMode(IN2_PIN, OUTPUT);
  pinMode(ENA_PIN, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  applyMotorState();

  // === INICIAR MODO ACCESS POINT (VERSIÓN REFORZADA) ===
  Serial.println("\nConfigurando Punto de Acceso (AP)...");
  
  // 1. Borramos cualquier configuración vieja que se haya quedado pegada
  WiFi.disconnect(true);
  WiFi.softAPdisconnect(true);
  delay(100);

  // 2. Le ordenamos explícitamente ser SOLO un emisor de WiFi
  WiFi.mode(WIFI_AP); 
  
  // 3. Levantamos la red (recuerda: password de 8 caracteres mínimo)
  WiFi.softAP(ssid, password); 
  
  IPAddress IP = WiFi.softAPIP(); 
  digitalWrite(LED_PIN, HIGH); 
  
  Serial.print("Red creada: ");
  Serial.println(ssid);
  Serial.print("Dirección IP para entrar: http://");
  Serial.println(IP);

  server.on("/", handleRoot);
  server.on("/update", handleUpdate);
  server.begin();
}

void loop() {
  server.handleClient();
}