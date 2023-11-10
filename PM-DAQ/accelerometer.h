#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL343.h>

Adafruit_ADXL343 accel = Adafruit_ADXL343(12345);

sensors_event_t event; 

int x = 0;
int y = 0;
int z = 0;

void initAccel() {
  if (!accel.begin()) {
    Serial.println("Failed to find MSA311 chip");
    while (1) { delay(10); }
  }
  accel.setRange(ADXL343_RANGE_16_G);
  accel.setDataRate(ADXL343_DATARATE_1600_HZ);
  accel.printSensorDetails();
  Serial.println("");
}

void getAccel() {
  /* Get new sensor events */
  sensors_event_t event1;
  accel.getEvent(&event1);

  x = event1.acceleration.x;
  y = event1.acceleration.y;
  z = event1.acceleration.z;
  /* Display the results (acceleration is measured in m/s^2) */
  Serial.print(x); Serial.print(",");
  Serial.print(y); Serial.print(",");
  Serial.print(z); Serial.print(",\n");

}
