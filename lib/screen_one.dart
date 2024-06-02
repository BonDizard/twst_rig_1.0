import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trust_rig_version_one/model.dart';
import 'package:trust_rig_version_one/providers.dart';

class ScreenOne extends ConsumerStatefulWidget {
  final List<BluetoothService> services;
  final BluetoothDevice device;

  const ScreenOne({Key? key, required this.services, required this.device})
      : super(key: key);

  @override
  ScreenOneState createState() => ScreenOneState();
}

class ScreenOneState extends ConsumerState<ScreenOne> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController sendString = TextEditingController();
  bool _autoScrollEnabled = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_autoScrollEnabled && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
    final db = ref.watch(databaseProvider);
    try {
      // Use regular expressions to extract voltage and current values
      RegExp voltageRegex = RegExp(r'v:([\d.]+)', caseSensitive: false);
      RegExp currentRegex = RegExp(r'c:([\d.]+)', caseSensitive: false);
      RegExp thrustRegex = RegExp(r'h:([\d.]+)', caseSensitive: false);
      RegExp tempRegex = RegExp(r't:([\d.]+)', caseSensitive: false);
      RegExp powerRegex = RegExp(r'p:([\d.]+)', caseSensitive: false);
      RegExp rpmRegex = RegExp(r'r:([\d.]+)', caseSensitive: false);
      RegExp throttleRegex = RegExp(r'z:([\d.]+)', caseSensitive: false);
      RegExp torqueRegex = RegExp(r'x:([\d.]+)', caseSensitive: false);

      // Extract voltage value
      RegExpMatch? voltageMatch = voltageRegex.firstMatch(receivedString);
      double voltage = voltageMatch != null
          ? double.tryParse(voltageMatch.group(1)!) ?? 0.0
          : 0.0;

      // Extract current value
      RegExpMatch? currentMatch = currentRegex.firstMatch(receivedString);
      double current = currentMatch != null
          ? double.tryParse(currentMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? thrustMatch = thrustRegex.firstMatch(receivedString);
      double thrust = thrustMatch != null
          ? double.tryParse(thrustMatch.group(1)!) ?? 0.0
          : 0.0;

      // Extract current value
      RegExpMatch? tempMatch = tempRegex.firstMatch(receivedString);
      double temperature =
          tempMatch != null ? double.tryParse(tempMatch.group(1)!) ?? 0.0 : 0.0;

      RegExpMatch? powerMatch = powerRegex.firstMatch(receivedString);
      double power = powerMatch != null
          ? double.tryParse(powerMatch.group(1)!) ?? 0.0
          : 0.0;

      RegExpMatch? rpmMatch = rpmRegex.firstMatch(receivedString);
      double rpm =
          rpmMatch != null ? double.tryParse(rpmMatch.group(1)!) ?? 0.0 : 0.0;

      RegExpMatch? throttleMatch = throttleRegex.firstMatch(receivedString);
      double throttle = throttleMatch != null
          ? double.tryParse(throttleMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? torqueMatch = torqueRegex.firstMatch(receivedString);
      double torque = torqueMatch != null
          ? double.tryParse(torqueMatch.group(1)!) ?? 0.0
          : 0.0;
      // Add timestamped data point
      DateTime currentTime = DateTime.now();

      ParametersModel(
        timestamp: currentTime,
        voltage: voltage,
        current: current,
        power: power,
        rpm: rpm,
        temperature: temperature,
        throttle: throttle,
        thrust: thrust,
        torque: torque,
      );
      // Insert data into the database
      db.insertData(
        currentTime,
        voltage,
        current,
        torque,
        temperature,
        thrust,
        power,
        rpm,
        throttle,
      );
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
    });
  }

  @override
  void initState() {
    readContinuousData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataStream = ref.watch(getAllDataProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
        actions: [
          IconButton(
            icon: Icon(
              _autoScrollEnabled ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _autoScrollEnabled = !_autoScrollEnabled;
              });
            },
          ),
          IconButton(
              onPressed: () {
                db.resetDatabase();
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: dataStream.when(
        data: (data) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
          return Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Timestamp'),
                  Text('Voltage'),
                  Text('Current'),
                  Text('Torque'),
                  Text('Temperature'),
                  Text('Thrust'),
                  Text('Power'),
                  Text('RPM'),
                  Text('Throttle'),
                ],
              ),
              // Data
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Voltage')),
                      DataColumn(label: Text('Current')),
                      DataColumn(label: Text('Torque')),
                      DataColumn(label: Text('Temperature')),
                      DataColumn(label: Text('Thrust')),
                      DataColumn(label: Text('Power')),
                      DataColumn(label: Text('RPM')),
                      DataColumn(label: Text('Throttle')),
                    ],
                    rows: data.map((item) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(item['timestamp'])),
                          DataCell(Text(item['voltage'].toString())),
                          DataCell(Text(item['current'].toString())),
                          DataCell(Text(item['torque'].toString())),
                          DataCell(Text(item['temperature'].toString())),
                          DataCell(Text(item['thrust'].toString())),
                          DataCell(Text(item['power'].toString())),
                          DataCell(Text(item['rpm'].toString())),
                          DataCell(Text(item['throttle'].toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
