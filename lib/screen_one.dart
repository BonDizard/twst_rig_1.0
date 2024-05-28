import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trust_rig_version_one/custom_appbar.dart';
import 'package:trust_rig_version_one/model.dart';

import 'date_time.dart';
import 'db_helper.dart';

class ScreenOne extends StatefulWidget {
  final List<BluetoothService> services;
  final BluetoothDevice device;

  const ScreenOne({Key? key, required this.services, required this.device})
      : super(key: key);

  @override
  ScreenOneState createState() => ScreenOneState();
}

class ScreenOneState extends State<ScreenOne> {
  TextEditingController sendString = TextEditingController();
  late DbHelper _dbHelper;
  bool _isDbInitialized =
      false; // Track whether database initialization is complete

  Future<void> _initializeDatabase() async {
    _dbHelper = DbHelper();
    await _dbHelper.initializeDatabase(); // Initialize the database
    setState(() {
      _isDbInitialized = true; // Database initialization is complete
    });
    readContinuousData(); // Start reading data once database is initialized
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
      _dbHelper.insertData(
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

  StreamController<void> _updateController = StreamController<void>.broadcast();

  @override
  void dispose() {
    _updateController.close();
    super.dispose();
  }

  void _onDataInserted() {
    _updateController.add(null); // Notify the StreamBuilder to rebuild
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(dbHelper: _dbHelper),
      body: StreamBuilder<void>(
        stream: _updateController.stream,
        builder: (context, snapshot) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _dbHelper.getAllData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Map<String, dynamic>>? data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return Center(child: Text('No data available yet'));
                }
                return SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Time')),
                      DataColumn(label: Text('Voltage')),
                      DataColumn(label: Text('Current')),
                      DataColumn(label: Text('Torque')),
                      DataColumn(label: Text('Temperature')),
                      DataColumn(label: Text('Thrust')),
                      DataColumn(label: Text('Power')),
                      DataColumn(label: Text('RPM')),
                      DataColumn(label: Text('Throttle')),
                    ],
                    rows: List.generate(
                      data.length,
                      (index) => DataRow(cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                DateTimeFormatter.formatTime(
                                  DateTime.parse(data[index]['timestamp']),
                                ),
                              ),
                              Text(
                                DateTimeFormatter.formatDate(
                                  DateTime.parse(data[index]['timestamp']),
                                ),
                                style: TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(data[index]['voltage'].toString())),
                        DataCell(Text(data[index]['current'].toString())),
                        DataCell(Text(data[index]['torque'].toString())),
                        DataCell(Text(data[index]['temperature'].toString())),
                        DataCell(Text(data[index]['thrust'].toString())),
                        DataCell(Text(data[index]['power'].toString())),
                        DataCell(Text(data[index]['rpm'].toString())),
                        DataCell(Text(data[index]['throttle'].toString())),
                      ]),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
