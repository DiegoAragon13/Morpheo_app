#define EIDSP_QUANTIZE_FILTERBANK 0

#include <Morpheo_inferencing.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s.h"
#include <DHTesp.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <time.h>

// ============================================================================
// CONFIGURACIÓN WiFi, AWS y FIRESTORE
// ============================================================================
const char* ssid = "Ramón el largo";//
const char* password = "3FKrHas3qb"; //$Esta es la CL4V3$
const char* aws_api_url = "https://wmzcp7fbfa.execute-api.us-east-2.amazonaws.com/prod";
const char* user_id = "Diego";

// ✅ FIRESTORE REST API Configuration
const char* FIREBASE_PROJECT_ID = "sirs-7f9e3";  // Tu ID de proyecto
const char* FIRESTORE_BASE_URL = "https://firestore.googleapis.com/v1/projects/sirs-7f9e3/databases/(default)/documents";

// ⚠️ IMPORTANTE: Necesitas obtener tu API Key de Firebase
// Ve a: Firebase Console → Project Settings → General → Web API Key
const char* FIREBASE_API_KEY = "AIzaSyA_K85bJ-PQC3iqsd1q-8Qmk5vXR6l9eCE";  // ⚠️ CAMBIAR ESTO

// ============================================================================
// CONFIGURACIÓN DE SENSORES - PINES REALES
// ============================================================================
#define DHTPIN 4        // DHT11
#define LDR_PIN 45      // Fotoresistencia
#define BUZZER_PIN 5    // Buzzer
#define LED_R 10        // LED - Rojo
#define LED_G 11        // LED - Verde
#define LED_B 12        // LED - Azul

// I2S Microphone (INMP441)
#define I2S_BCK 9       // Bit Clock
#define I2S_WS 8        // Word Select
#define I2S_DATA 7      // Data In

#define UMBRAL_LUZ 2000

DHTesp dht;

// ============================================================================
// VARIABLES GLOBALES - LED RGB
// ============================================================================
struct LedState {
  bool enabled;
  int r;
  int g;
  int b;
};

LedState ledActual = {false, 0, 0, 0};
unsigned long ultimaLecturaLED = 0;
const unsigned long intervaloLecturaLED = 3000;  // Leer cada 3 segundos

// ============================================================================
// VARIABLES GLOBALES - ALARMAS
// ============================================================================
struct Alarm {
  String id;
  int hour;
  int minute;
  String label;
  bool isEnabled;
  int days[7];
  int numDays;
};

Alarm alarmas[10];
int numAlarmas = 0;
bool ronquidosDetectados = false;

// ============================================================================
// VARIABLES GLOBALES - TEMPORIZADORES
// ============================================================================
const unsigned long intervaloLecturaSensores = 30000;  // 30 segundos
const unsigned long intervaloEnvioAWS = 60000;         // 1 minuto
const unsigned long intervaloBuzzer = 500;             // 500ms
const unsigned long intervaloSincAlarmas = 300000;     // 5 minutos
const unsigned long intervaloActualizarConexion = 30000; // 30 segundos

unsigned long ultimaLecturaSensores = 0;
unsigned long ultimoEnvioAWS = 0;
unsigned long ultimoCambioBuzzer = 0;
unsigned long ultimaSincAlarmas = 0;
unsigned long ultimaActualizacionConexion = 0;

bool buzzerActivo = false;
bool alarmaActiva = false;
int minutoAlarmaActiva = -1;

// ============================================================================
// VARIABLES GLOBALES - DATOS DE SENSORES
// ============================================================================
float temperatura = 0;
float humedad = 0;
bool luzActiva = false;

// ============================================================================
// EDGE IMPULSE - ESTRUCTURAS
// ============================================================================
typedef struct {
    int16_t *buffer;
    uint8_t buf_ready;
    uint32_t buf_count;
    uint32_t n_samples;
} inference_t;

static inference_t inference;
static const uint32_t sample_buffer_size = 2048;
static signed short sampleBuffer[sample_buffer_size];
static bool debug_nn = false;
static bool record_status = true;

// ============================================================================
// ✅ FUNCIONES FIRESTORE - CONTROL LED RGB
// ============================================================================

// Aplicar color al LED RGB físico
void aplicarColorLED(int r, int g, int b) {
  analogWrite(LED_R, r);
  analogWrite(LED_G, g);
  analogWrite(LED_B, b);
}

// Leer estado del LED desde Firestore usando REST API
void leerEstadoLED() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  
  // URL del documento: dispositivos/morpheo_01/config/led
  String url = String(FIRESTORE_BASE_URL) + "/dispositivos/morpheo_01/config/led";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.GET();
  
  if (httpCode == 200) {
    String payload = http.getString();
    
    DynamicJsonDocument doc(2048);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (!error) {
      // Extraer datos de Firestore (formato especial de Firestore)
      bool enabled = false;
      int r = 0, g = 0, b = 0;
      
      // Firestore devuelve valores en formato: {"fields": {"enabled": {"booleanValue": true}}}
      if (doc["fields"]["enabled"]["booleanValue"].is<bool>()) {
        enabled = doc["fields"]["enabled"]["booleanValue"];
      }
      
      if (doc["fields"]["color"]["mapValue"]["fields"]["r"]["integerValue"].is<const char*>()) {
        r = atoi(doc["fields"]["color"]["mapValue"]["fields"]["r"]["integerValue"]);
      }
      
      if (doc["fields"]["color"]["mapValue"]["fields"]["g"]["integerValue"].is<const char*>()) {
        g = atoi(doc["fields"]["color"]["mapValue"]["fields"]["g"]["integerValue"]);
      }
      
      if (doc["fields"]["color"]["mapValue"]["fields"]["b"]["integerValue"].is<const char*>()) {
        b = atoi(doc["fields"]["color"]["mapValue"]["fields"]["b"]["integerValue"]);
      }
      
      // Verificar si hubo cambios
      if (ledActual.enabled != enabled || 
          ledActual.r != r || 
          ledActual.g != g || 
          ledActual.b != b) {
        
        ledActual.enabled = enabled;
        ledActual.r = r;
        ledActual.g = g;
        ledActual.b = b;
        
        if (enabled) {
          aplicarColorLED(r, g, b);
          Serial.println("\n💡 LED actualizado desde Firestore:");
          Serial.printf("   RGB: (%d, %d, %d)\n", r, g, b);
        } else {
          aplicarColorLED(0, 0, 0);
          Serial.println("\n💡 LED apagado");
        }
      }
    } else {
      Serial.println("⚠️ Error al parsear respuesta de Firestore");
    }
  } else if (httpCode == 404) {
    Serial.println("⚠️ Documento LED no existe en Firestore. Creando...");
    // Opcionalmente, crear el documento con valores por defecto
  } else {
    Serial.printf("⚠️ Error al leer LED de Firestore: HTTP %d\n", httpCode);
  }
  
  http.end();
}

// Actualizar estado de conexión del dispositivo en Firestore
void actualizarConexion(bool conectado) {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  
  // URL del documento principal: dispositivos/morpheo_01
  String url = String(FIRESTORE_BASE_URL) + "/dispositivos/morpheo_01?updateMask.fieldPaths=connected&updateMask.fieldPaths=lastSeen";
  
  // Construir JSON en formato Firestore
  DynamicJsonDocument doc(512);
  doc["fields"]["connected"]["booleanValue"] = conectado;
  
  // Usar timestamp del servidor
  JsonObject lastSeen = doc["fields"]["lastSeen"].createNestedObject("timestampValue");
  
  // Obtener timestamp actual
  time_t now;
  time(&now);
  char timestamp[30];
  strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));
  doc["fields"]["lastSeen"]["timestampValue"] = timestamp;
  
  String jsonData;
  serializeJson(doc, jsonData);
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.PATCH(jsonData);
  
  if (httpCode == 200) {
    Serial.printf("✅ Conexión actualizada en Firestore: %s\n", conectado ? "CONECTADO" : "DESCONECTADO");
  } else if (httpCode == 404) {
    // Si no existe, crear el documento
    String createUrl = String(FIRESTORE_BASE_URL) + "/dispositivos/morpheo_01";
    http.begin(createUrl);
    http.addHeader("Content-Type", "application/json");
    httpCode = http.PATCH(jsonData);
    
    if (httpCode == 200) {
      Serial.println("✅ Documento de dispositivo creado en Firestore");
    }
  }
  
  http.end();
}

// ============================================================================
// FUNCIONES WiFi
// ============================================================================
void conectarWiFi() {
  Serial.println("\n📡 Conectando a WiFi...");
  WiFi.begin(ssid, password);
  
  int intentos = 0;
  while (WiFi.status() != WL_CONNECTED && intentos < 20) {
    delay(500);
    Serial.print(".");
    intentos++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi conectado");
    Serial.print("📍 IP: ");
    Serial.println(WiFi.localIP());
    
    Serial.println("✅ Firestore REST API configurado");
    Serial.printf("   Project ID: %s\n", FIREBASE_PROJECT_ID);
    
    // Actualizar estado de conexión
    actualizarConexion(true);
    
    // Configurar hora (NTP)
    configTime(-6 * 3600, 0, "pool.ntp.org", "time.nist.gov");
    
    Serial.println("⏰ Sincronizando hora con NTP...");
    struct tm timeinfo;
    int intentosNTP = 0;
    while (!getLocalTime(&timeinfo) && intentosNTP < 10) {
      Serial.print(".");
      delay(1000);
      intentosNTP++;
    }
    
    if (getLocalTime(&timeinfo)) {
      Serial.println("\n✅ Hora sincronizada");
      Serial.printf("📅 Fecha/Hora: %02d/%02d/%04d %02d:%02d:%02d\n",
        timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900,
        timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
    } else {
      Serial.println("\n⚠️ No se pudo sincronizar la hora");
    }
  } else {
    Serial.println("\n❌ Error al conectar WiFi");
  }
}

// ============================================================================
// FUNCIONES AWS - ALARMAS
// ============================================================================
void descargarAlarmas() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  String url = String(aws_api_url) + "/alarms?userId=" + String(user_id);
  
  Serial.println("\n📥 Descargando alarmas desde AWS...");
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.GET();
  
  if (httpCode == 200) {
    String payload = http.getString();
    
    DynamicJsonDocument responseDoc(4096);
    DeserializationError error = deserializeJson(responseDoc, payload);
    
    if (error) {
      Serial.println("❌ Error al parsear respuesta JSON");
      http.end();
      return;
    }
    
    JsonArray alarms;
    
    if (responseDoc.is<JsonArray>()) {
      alarms = responseDoc.as<JsonArray>();
    } else if (responseDoc.containsKey("body")) {
      String bodyStr = responseDoc["body"].as<String>();
      DynamicJsonDocument bodyDoc(4096);
      deserializeJson(bodyDoc, bodyStr);
      
      if (bodyDoc.containsKey("alarms")) {
        alarms = bodyDoc["alarms"];
      }
    } else if (responseDoc.containsKey("alarms")) {
      alarms = responseDoc["alarms"];
    }
    
    numAlarmas = 0;
    Serial.println("✅ Alarmas recibidas:");
    
    for (JsonObject alarm : alarms) {
      if (numAlarmas >= 10) break;
      
      alarmas[numAlarmas].id = alarm["alarmId"].as<String>();
      alarmas[numAlarmas].hour = alarm["time"]["hour"];
      alarmas[numAlarmas].minute = alarm["time"]["minute"];
      alarmas[numAlarmas].label = alarm["label"].as<String>();
      alarmas[numAlarmas].isEnabled = alarm["isEnabled"];
      
      JsonArray days = alarm["days"];
      alarmas[numAlarmas].numDays = days.size();
      for (int i = 0; i < days.size() && i < 7; i++) {
        alarmas[numAlarmas].days[i] = days[i];
      }
      
      Serial.printf("  ⏰ [%d] %02d:%02d - %s %s\n", 
        numAlarmas + 1,
        alarmas[numAlarmas].hour, 
        alarmas[numAlarmas].minute,
        alarmas[numAlarmas].label.c_str(),
        alarmas[numAlarmas].isEnabled ? "✓" : "✗");
      
      numAlarmas++;
    }
    
    Serial.printf("📋 Total de alarmas activas: %d\n", numAlarmas);
  } else {
    Serial.printf("❌ Error al descargar alarmas: HTTP %d\n", httpCode);
  }
  
  http.end();
}

// ============================================================================
// FUNCIONES AWS - SENSORES
// ============================================================================
void enviarDatosAWS() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠️ Sin conexión WiFi");
    return;
  }
  
  HTTPClient http;
  String url = String(aws_api_url);
  
  Serial.println("\n📤 Enviando datos a AWS...");
  
  DynamicJsonDocument doc(512);
  doc["userId"] = user_id;
  doc["temperature"] = temperatura;
  doc["humidity"] = humedad;
  doc["light"] = luzActiva;
  doc["ronquidos"] = ronquidosDetectados;
  
  String jsonData;
  serializeJson(doc, jsonData);
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(10000);
  
  int httpCode = http.POST(jsonData);
  
  if (httpCode == 200 || httpCode == 201) {
    Serial.println("✅ Datos enviados a AWS");
  } else {
    Serial.printf("❌ Error AWS: HTTP %d\n", httpCode);
  }
  
  http.end();
  ronquidosDetectados = false;
}

// ============================================================================
// FUNCIONES DE SENSORES
// ============================================================================
void leerSensores() {
  TempAndHumidity data = dht.getTempAndHumidity();
  temperatura = data.temperature;
  humedad = data.humidity;
  
  int valor_ldr = analogRead(LDR_PIN);
  luzActiva = (valor_ldr > UMBRAL_LUZ);
  
  if (!isnan(temperatura) && !isnan(humedad)) {
    Serial.println("\n📊 ========== Sensores ==========");
    Serial.printf("🌡️  Temp: %.1f°C | 💧 Hum: %.1f%%\n", temperatura, humedad);
    Serial.printf("💡 Luz: %s [%d]\n", luzActiva ? "ON" : "OFF", valor_ldr);
    Serial.println("================================");
  }
}

// ============================================================================
// FUNCIONES DE ALARMAS
// ============================================================================
void verificarAlarmas() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return;
  
  int horaActual = timeinfo.tm_hour;
  int minutoActual = timeinfo.tm_min;
  int diaActual = timeinfo.tm_wday == 0 ? 7 : timeinfo.tm_wday;
  
  if (alarmaActiva && minutoActual != minutoAlarmaActiva) {
    alarmaActiva = false;
    digitalWrite(BUZZER_PIN, LOW);
    buzzerActivo = false;
  }
  
  for (int i = 0; i < numAlarmas; i++) {
    if (!alarmas[i].isEnabled) continue;
    
    bool diaValido = false;
    for (int j = 0; j < alarmas[i].numDays; j++) {
      if (alarmas[i].days[j] == diaActual) {
        diaValido = true;
        break;
      }
    }
    
    if (!diaValido) continue;
    
    if (alarmas[i].hour == horaActual && alarmas[i].minute == minutoActual && !alarmaActiva) {
      alarmaActiva = true;
      minutoAlarmaActiva = minutoActual;
      Serial.println("\n🔔 ALARMA! 🔔");
    }
  }
}

// ============================================================================
// EDGE IMPULSE - FUNCIONES (mantener igual)
// ============================================================================
static void audio_inference_callback(uint32_t n_bytes) {
    for(int i = 0; i < n_bytes>>1; i++) {
        inference.buffer[inference.buf_count++] = sampleBuffer[i];
        if(inference.buf_count >= inference.n_samples) {
          inference.buf_count = 0;
          inference.buf_ready = 1;
        }
    }
}

static void capture_samples(void* arg) {
  const int32_t i2s_bytes_to_read = (uint32_t)arg;
  size_t bytes_read = i2s_bytes_to_read;

  while (record_status) {
    i2s_read((i2s_port_t)0, (void*)sampleBuffer, i2s_bytes_to_read, &bytes_read, 100);
    
    if (bytes_read > 0) {
        for (int x = 0; x < i2s_bytes_to_read/2; x++) {
            sampleBuffer[x] = (int16_t)(sampleBuffer[x]) * 8;
        }
        if (record_status) {
            audio_inference_callback(i2s_bytes_to_read);
        }
    }
  }
  vTaskDelete(NULL);
}

static bool microphone_inference_start(uint32_t n_samples) {
    inference.buffer = (int16_t *)malloc(n_samples * sizeof(int16_t));
    if(inference.buffer == NULL) return false;

    inference.buf_count = 0;
    inference.n_samples = n_samples;
    inference.buf_ready = 0;

    if (i2s_init(EI_CLASSIFIER_FREQUENCY)) {
        ei_printf("Failed to start I2S!");
    }

    ei_sleep(100);
    record_status = true;
    xTaskCreate(capture_samples, "CaptureSamples", 1024 * 32, (void*)sample_buffer_size, 10, NULL);
    return true;
}

static bool microphone_inference_record(void) {
    while (inference.buf_ready == 0) {
        delay(10);
    }
    inference.buf_ready = 0;
    return true;
}

static int microphone_audio_signal_get_data(size_t offset, size_t length, float *out_ptr) {
    numpy::int16_to_float(&inference.buffer[offset], out_ptr, length);
    return 0;
}

static void microphone_inference_end(void) {
    i2s_deinit();
    ei_free(inference.buffer);
}

static int i2s_init(uint32_t sampling_rate) {
  i2s_config_t i2s_config = {
      .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
      .sample_rate = sampling_rate,
      .bits_per_sample = (i2s_bits_per_sample_t)16,
      .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
      .communication_format = I2S_COMM_FORMAT_I2S,
      .intr_alloc_flags = 0,
      .dma_buf_count = 8,
      .dma_buf_len = 512,
      .use_apll = false,
      .tx_desc_auto_clear = false,
      .fixed_mclk = -1,
  };
  
  i2s_pin_config_t pin_config = {
      .bck_io_num = I2S_BCK,
      .ws_io_num = I2S_WS,
      .data_out_num = -1,
      .data_in_num = I2S_DATA,
  };
  
  esp_err_t ret = i2s_driver_install((i2s_port_t)0, &i2s_config, 0, NULL);
  if (ret != ESP_OK) ei_printf("Error in i2s_driver_install");

  ret = i2s_set_pin((i2s_port_t)0, &pin_config);
  if (ret != ESP_OK) ei_printf("Error in i2s_set_pin");

  ret = i2s_zero_dma_buffer((i2s_port_t)0);
  if (ret != ESP_OK) ei_printf("Error in initializing dma buffer");

  return int(ret);
}

static int i2s_deinit(void) {
    i2s_driver_uninstall((i2s_port_t)0);
    return 0;
}

// ============================================================================
// SETUP
// ============================================================================
void setup() {
    Serial.begin(115200);
    while (!Serial);
    
    Serial.println("\n╔═══════════════════════════════════════════════╗");
    Serial.println("║   ESP32 SLEEP TRACKER + FIRESTORE            ║");
    Serial.println("║   AWS + Firestore REST API v4.0              ║");
    Serial.println("╚═══════════════════════════════════════════════╝\n");

    dht.setup(DHTPIN, DHTesp::DHT11);
    pinMode(LDR_PIN, INPUT);
    pinMode(BUZZER_PIN, OUTPUT);
    digitalWrite(BUZZER_PIN, LOW);

    // Configurar LED RGB como salidas PWM
    pinMode(LED_R, OUTPUT);
    pinMode(LED_G, OUTPUT);
    pinMode(LED_B, OUTPUT);
    aplicarColorLED(0, 0, 0);
    
    Serial.println("✓ Hardware configurado");

    conectarWiFi();
    delay(1000);
    
    descargarAlarmas();
    leerEstadoLED();

    Serial.println("\n🎤 Iniciando Edge Impulse...");
    
    if (microphone_inference_start(EI_CLASSIFIER_RAW_SAMPLE_COUNT) == false) {
        ei_printf("❌ ERROR: Buffer de audio\r\n");
        return;
    }

    Serial.println("\n✅ Sistema listo\n");
}

// ============================================================================
// LOOP PRINCIPAL
// ============================================================================
void loop() {
    unsigned long tiempoActual = millis();

    if (WiFi.status() != WL_CONNECTED) {
        conectarWiFi();
    }

    // Leer LED desde Firestore
    if (tiempoActual - ultimaLecturaLED >= intervaloLecturaLED) {
        ultimaLecturaLED = tiempoActual;
        leerEstadoLED();
    }

    // Actualizar estado de conexión
    if (tiempoActual - ultimaActualizacionConexion >= intervaloActualizarConexion) {
        ultimaActualizacionConexion = tiempoActual;
        actualizarConexion(true);
    }

    verificarAlarmas();

    if (alarmaActiva && tiempoActual - ultimoCambioBuzzer >= intervaloBuzzer) {
        ultimoCambioBuzzer = tiempoActual;
        buzzerActivo = !buzzerActivo;
        digitalWrite(BUZZER_PIN, buzzerActivo ? HIGH : LOW);
    }

    if (tiempoActual - ultimaLecturaSensores >= intervaloLecturaSensores) {
        ultimaLecturaSensores = tiempoActual;
        leerSensores();
    }

    if (tiempoActual - ultimoEnvioAWS >= intervaloEnvioAWS) {
        ultimoEnvioAWS = tiempoActual;
        enviarDatosAWS();
    }

    if (tiempoActual - ultimaSincAlarmas >= intervaloSincAlarmas) {
        ultimaSincAlarmas = tiempoActual;
        descargarAlarmas();
    }

    // Detección de ronquidos
    bool m = microphone_inference_record();
    if (!m) return;

    signal_t signal;
    signal.total_length = EI_CLASSIFIER_RAW_SAMPLE_COUNT;
    signal.get_data = &microphone_audio_signal_get_data;
    ei_impulse_result_t result = { 0 };

    EI_IMPULSE_ERROR r = run_classifier(&signal, &result, debug_nn);
    if (r != EI_IMPULSE_OK) return;

    if (EI_CLASSIFIER_LABEL_COUNT >= 2) {
        float confianza = result.classification[1].value;
        if (confianza > 0.70 && !ronquidosDetectados) {
            Serial.printf("\n😴💤 RONQUIDO! Confianza: %.2f%%\n", confianza * 100);
            ronquidosDetectados = true;
        }
    }
}

#if !defined(EI_CLASSIFIER_SENSOR) || EI_CLASSIFIER_SENSOR != EI_CLASSIFIER_SENSOR_MICROPHONE
#error "Invalid model for current sensor."
#endif