#include <Arduino.h>
#include <NimBLEDevice.h>
#include <ArduinoJson.h>

static constexpr uint8_t LED_PIN = 2;

void setup() {
    Serial.begin(115200);
    pinMode(LED_PIN, OUTPUT);
    Serial.println("[himo] firmware started");
}

void loop() {
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
}
