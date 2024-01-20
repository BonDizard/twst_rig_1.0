import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trust_rig_version_one/send_data.dart';

class ScreenOne extends StatefulWidget {
  final List<BluetoothService> services;
  final BluetoothDevice device;

  const ScreenOne({Key? key, required this.services, required this.device})
      : super(key: key);

  @override
  ScreenOneState createState() => ScreenOneState();
}

class ScreenOneState extends State<ScreenOne> {
  List<int> allValues = []; // Accumulate all values received

  void readContinuousData() {
    for (BluetoothService service in widget.services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.read || c.properties.notify) {
          // Start reading data continuously in a loop
          readDataContinuous(c);
        }
      }
    }
  }

  void readDataContinuous(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);

    characteristic.lastValueStream.listen((value) {
      // Convert received data to numeric values
      List<int> numericValues = value.map((byte) => byte).toList();

      // Update the UI with the received numeric values
      setState(() {
        allValues.add(numericValues.first); // Assuming only one int is sent
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readContinuousData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              sendData('hello from flutter', widget.services, context);
            },
            child: const Text('Send'),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(allValues.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
