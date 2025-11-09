# 🌙 **Morpheo App**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev/)
[![AWS](https://img.shields.io/badge/AWS-Lambda%20%7C%20Cognito%20%7C%20DynamoDB-orange?logo=amazonaws)](https://aws.amazon.com/)
[![ESP32](https://img.shields.io/badge/ESP32--S3-IoT%20Device-blueviolet?logo=espressif)](https://www.espressif.com/)
[![AI](https://img.shields.io/badge/AI-Edge%20Impulse%20%7C%20Gemini%20API-success?logo=google)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/license-Educational-lightgrey)](LICENSE)

---

## 🧠 **Project Description**

**Morpheo** is an intelligent sleep monitoring system that detects **sleep apnea** and **chronic snoring** using an **INMP441 microphone**, an **ESP32-S3 microcontroller**, and **AI models**.  
The device collects acoustic and environmental data, processes them through **AWS Cloud** and **Gemini API**, and displays personalized reports in a **Flutter mobile app**.

This project combines **embedded hardware**, **cloud computing**, and **mobile development** to create an accessible, private, and scalable digital health solution.

---

## 🧩 **Repository Structure**

```plaintext
morpheo_app/
│
├── Esp32/                          # ESP32-S3 firmware code
│   └── CodigoDeESP32               # Arduino sketch
│
├── android/                        # Android native project files
├── lib/                            # Flutter source code (UI + logic)
├── test/                           # Flutter test files
├── web/                            # Web configuration (optional)
│
├── ei-morpheo-arduino-1.0.11.zip   # AI model library for Arduino IDE
├── pubspec.yaml                    # Flutter dependencies
├── README.md                       # This file
└── .gitignore / .metadata / etc.   


---

## ⚙️ **ESP32-S3 Setup**

### 1️⃣ Extract the required files
- **Folder `Esp32/`** → contains the main ESP32-S3 code.  
- **File `ei-morpheo-arduino-1.0.11.zip`** → library containing the AI model for Arduino.

### 2️⃣ Open the code in Arduino IDE
1. Open the `.ino` file inside `Esp32/CodigoDeESP32`.  
2. Check the **pin configuration** for sensors and components (DHT11, LDR, INMP441 mic, LEDs, etc.).  
3. Connect your components according to the pin definitions in the code.

### 3️⃣ Add the AI library
In **Arduino IDE** go to:  
`Sketch → Include Library → Add .ZIP Library...`  
Then select **`ei-morpheo-arduino-1.0.11.zip`**.

### 4️⃣ Upload the firmware
1. Connect your **ESP32-S3** via USB.  
2. Select the correct **board** and **COM port**.  
3. Upload the sketch.  
4. Check the **Serial Monitor** — you should see sensor data being sent successfully.

---

## 📱 **Flutter Mobile App Setup**

1. Open the project folder in **VS Code** or **Android Studio**.  
2. Make sure Flutter is installed:
   ```bash
   flutter doctor
Create and configure your own API keys:

AWS → Cognito, Lambda, API Gateway, DynamoDB

Gemini API → for sleep pattern analysis

Firebase → optional for auth or storage

Run the app:
flutter pub get
flutter run

System Workflow

ESP32-S3 reads sound, temperature, and light sensors.

Sends data securely via HTTPS to AWS API Gateway.
🧰 Technologies Used
Component	Technology	Purpose
Hardware	ESP32-S3 + INMP441	Captures sound and environmental signals
AI / ML	Edge Impulse · Gemini API	Detects snoring and apnea patterns
Backend	AWS Lambda, DynamoDB, API Gateway, Cognito	Serverless data processing
Frontend	Flutter	Cross-platform mobile application
Security	IAM · HTTPS · JWT Tokens	Encrypted and authenticated communication
🧑‍💻 Developer

👨‍💻 Diego Felipe Aragón García
Developed as part of the Cloud Computing and Digital Security course.
Integrates AI, IoT, and cloud technologies into a fully functional, privacy-first, and cost-efficient sleep monitoring system.

💡 How It Works

The ESP32-S3 acts as a smart sensor node.

Data is analyzed using on-device AI (Edge Impulse) and cloud AI (Gemini).

The app visualizes sleep quality, snoring events, and personalized insights.

The system is non-invasive, affordable, and scalable.

💤 License

This project is for educational and research purposes only.
You may reuse or modify the code by giving proper credit to the original author.

“Morpheo aims to democratize sleep health technology — making early detection of sleep apnea accessible to everyone, without expensive medical equipment.”

AWS Lambda processes and stores data in DynamoDB.

EventBridge triggers a daily analysis at 7:00 AM using Gemini AI.

The Flutter app retrieves reports and displays Sleep Scores, trends, and alerts.
