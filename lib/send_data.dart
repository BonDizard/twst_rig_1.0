import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

String serviceUUID = "fa42b45a-ef63-11eb-9a03-0242ac130003";
String selectedCharacteristicUUID = "006066e8-ef64-11eb-9a03-0242ac130003";

TextEditingController textFieldController = TextEditingController();

void sendData(String data, List<BluetoothService> bluetoothService,
    BuildContext context) {
  if (selectedCharacteristicUUID.isNotEmpty) {
    BluetoothCharacteristic? characteristic =
        findCharacteristic(selectedCharacteristicUUID, bluetoothService);

    if (characteristic != null) {
      characteristic.write(data.codeUnits, allowLongWrite: true);

      // Show a SnackBar indicating the data was sent
      final snackBar = SnackBar(
        content: Center(child: Text('Sent data: $data')),
        duration: const Duration(milliseconds: 500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Show a SnackBar indicating characteristic not found
      const snackBar = SnackBar(
        backgroundColor: Colors.grey,
        content: Text('Characteristic not found. Cannot send data.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } else {
    // Show a SnackBar indicating no characteristic UUID set
    const snackBar = SnackBar(
      content: Text('Characteristic UUID not set. Cannot send data.'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

BluetoothCharacteristic? findCharacteristic(
    String uuid, List<BluetoothService> bluetoothService) {
  for (BluetoothService service in bluetoothService) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid.toString().toLowerCase() == uuid.toLowerCase()) {
        return characteristic;
      }
    }
  }
  return null;
}
