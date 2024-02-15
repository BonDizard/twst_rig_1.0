import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trust_rig_version_one/send_data.dart';
import 'package:trust_rig_version_one/vi.dart';

class ScreenOne extends StatefulWidget {
  final List<BluetoothService> services;
  final BluetoothDevice device;

  const ScreenOne({Key? key, required this.services, required this.device})
      : super(key: key);

  @override
  ScreenOneState createState() => ScreenOneState();
}

class ScreenOneState extends State<ScreenOne> {
  double voltage = 0.0;
  double current = 0.0;
  List<VoltageCurrentTimeData> voltageDataPoints = [];
  List<VoltageCurrentTimeData> currentDataPoints = [];
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

  void processReceivedData(String receivedString) {
    print('recived string: $receivedString');
    try {
      // Use regular expressions to extract voltage and current values
      RegExp voltageRegex = RegExp(r'v:([\d.]+)', caseSensitive: false);
      RegExp currentRegex = RegExp(r'i:([\d.]+)', caseSensitive: false);

      // Extract voltage value
      RegExpMatch? voltageMatch = voltageRegex.firstMatch(receivedString);
      voltage = voltageMatch != null
          ? double.tryParse(voltageMatch.group(1)!) ?? 0.0
          : 0.0;

      // Extract current value
      RegExpMatch? currentMatch = currentRegex.firstMatch(receivedString);
      current = currentMatch != null
          ? double.tryParse(currentMatch.group(1)!) ?? 0.0
          : 0.0;

      // Add timestamped data point
      DateTime currentTime = DateTime.now();
      voltageDataPoints.add(VoltageCurrentTimeData(
          currentTime, voltage, 0.0)); // Adding 0.0 for current
      currentDataPoints.add(VoltageCurrentTimeData(
          currentTime, 0.0, current)); // Adding 0.0 for voltage

      print('Voltage: $voltage, Current: $current');
      // print('voltageDataPoints: $voltageDataPoints');
      // print('currentDataPoints: $currentDataPoints');

      setState(() {});
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  void readDataContinuous(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      // Convert received data to numeric values
      String receivedString = String.fromCharCodes(value);
      processReceivedData(receivedString);

      // Update the UI with the received numeric values
      setState(() {
        // Assuming only one int is sent
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
          SingleChildScrollView(
            reverse: true,
            child: Text('voltage = $voltage\n current = $current'),
          ),
        ],
      ),
    );
  }
}
