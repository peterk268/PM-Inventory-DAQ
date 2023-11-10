#include "accelerometer.h"
#include "ble.h"

void setup() {
  Serial.begin(115200);
  initAccel();
  bleSetup();
}

void loop() {
  if (deviceConnected) {
    // put your main code here, to run repeatedly:
    getAccel();
    String json = "{\"x\": " + String(x) + ", \"y\": " + String(y) + ", \"z\": " + String(z) + "}";
    sendData(json);
    delay(500);
  }
  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
      delay(500); // give the bluetooth stack the chance to get things ready
      pServer->startAdvertising(); // restart advertising
      Serial.println("start advertising");
      oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
      // do stuff here on connecting
      oldDeviceConnected = deviceConnected;
  }
}
