import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:trust_rig_version_one/scan_page.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  PermissionsPageState createState() => PermissionsPageState();
}

class PermissionsPageState extends State<PermissionsPage> {
  Future<bool> isBluetoothON = Future.value(false);
  Future<void> requestLocationPermission() async {
    if (await FlutterBluePlus.isSupported == false) {
      if (kDebugMode) {
        print("Bluetooth not supported by this device");
      }
      // Show a SnackBar to inform the user to turn on Bluetooth
      const snackBar = SnackBar(
        content: Text('Bluetooth not supported by this device.'),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isBluetoothON =
            Future.value(true); // Wrap the boolean value in Future.value
      });
    } else {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      if (state == BluetoothAdapterState.on) {
        setState(() {
          isBluetoothON = Future.value(true);
        });
      } else {
        await FlutterBluePlus.turnOn();
        setState(() {
          isBluetoothON = Future.value(true);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkBluetoothStatus().then((result) {
      setState(() {
        isBluetoothON = Future.value(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<bool>(
        future: isBluetoothON,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return ScanPage();
          } else {
            return Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Lottie.asset('assets/turn_on_bluetooth.json'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      requestLocationPermission();
                      if (kDebugMode) {
                        print('the turn on button pressed');
                      }
                    },
                    child: Text(
                      'Turn on the bluetooth',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<bool> checkBluetoothStatus() {
    return FlutterBluePlus.isOn;
  }
}
