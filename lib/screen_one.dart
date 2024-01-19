import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trust_rig_version_one/send_data.dart';

class ScreenOne extends StatefulWidget {
  final List<BluetoothService> services;
  final BluetoothDevice device;

  const ScreenOne({Key? key, required this.services, required this.device})
      : super(key: key);

  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  String readData = '';
  List<int> allValues = []; // Accumulate all values received

  void readContinuousData() {
    for (BluetoothService service in widget.services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.read) {
          // Start reading data continuously in a loop
          readDataContinuous(c);
        }
      }
    }
  }

  void readDataContinuous(BluetoothCharacteristic characteristic) async {
    while (true) {
      List<int> value = await characteristic.read();
      print('Received data: $value');

      allValues.addAll(value); // Accumulate the received values

      setState(() {
        readData =
            allValues.toString() + '\n'; // Display all accumulated values
        print('Read data: $readData');
      });
      await Future.delayed(Duration(seconds: 1)); // Adjust delay as needed
    }
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
            child: Text('Send'),
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
