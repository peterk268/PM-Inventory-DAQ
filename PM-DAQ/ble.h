#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t value = 0;

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

void bleSetup() {
  // Create the BLE Device
  BLEDevice::init("PM-DAQ");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  pServer->getAdvertising()->start();
  
  Serial.println("Waiting a client connection to notify...");
}

//#include <BLEDevice.h>
//#include <BLEServer.h>
//#include <BLEUtils.h>
//#include <BLECharacteristic.h>
//
//static BLEUUID ancsServiceUUID("7905F431-B5CE-4E99-A40F-4B1E122D00D0");
//
//BLECharacteristic* pCharacteristic;
//bool deviceConnected = false;
//
////Setup callbacks onConnect and onDisconnect
//class MyServerCallbacks: public BLEServerCallbacks {
//  void onConnect(BLEServer* pServer) {
//    deviceConnected = true;
//  };
//  void onDisconnect(BLEServer* pServer) {
//    deviceConnected = false;
//  }
//};
//
//void bleSetup() {
//  BLEDevice::init("PM-DAQ");
//  BLEServer* pServer = BLEDevice::createServer();
//  pServer->setCallbacks(new MyServerCallbacks());
//  
//  BLEService* pService = pServer->createService(ancsServiceUUID);
//  pCharacteristic = pService->createCharacteristic(
//      ancsServiceUUID,
//      BLECharacteristic::PROPERTY_NOTIFY
//  );
//  
//  pService->start();
//
//  // start advertising
//  BLEAdvertising* pAdvertising = pServer->getAdvertising();
//  pAdvertising->addServiceUUID(ancsServiceUUID);
//  pAdvertising->start();
//}
//
void sendData(String dataToSend) {    
    // Write the data to the BLE characteristic
    pCharacteristic->setValue(dataToSend.c_str());
    pCharacteristic->notify();
}
