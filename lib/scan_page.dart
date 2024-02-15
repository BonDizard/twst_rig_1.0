import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trust_rig_version_one/screen_one.dart';

class ScanPage extends StatefulWidget {
  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  bool isScanning = false;
  List<ScanResult> scanResultList = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> bluetoothService = [];
  StreamSubscription<bool>? isScanningSubscription;
  Set<String> seen = {};
  StreamSubscription<List<ScanResult>>? scanSubscription; // Updated type

  @override
  void initState() {
    super.initState();
    initBle();
    _requestBluetoothPermissions(); // Request Bluetooth permissions
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }

  void initBle() {
    isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      setState(() {
        this.isScanning = isScanning;
      });
    });
  }

  Future<void> _requestBluetoothPermissions() async {
    const bluetoothPermission = Permission.bluetooth;
    const locationPermission = Permission.locationWhenInUse;

    final bluetoothStatus = await bluetoothPermission.request();
    final locationStatus = await locationPermission.request();

    // Check if both Bluetooth and location permissions are granted
    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      final isBluetoothEnabled = await FlutterBluePlus.isAvailable;
      if (kDebugMode) {
        print('Bluetooth Status: $bluetoothStatus');
        print('Location Status: $locationStatus');
        print('isBluetoothEnabled is: $isBluetoothEnabled');
      }

      if (isBluetoothEnabled) {
        if (kDebugMode) {
          print('Bluetooth is enabled. Starting scanning.');
        }
        scan(); // Start scanning
      } else {
        if (kDebugMode) {
          print('Bluetooth is disabled. Showing message to turn it on.');
        }
        const snackBar = SnackBar(
          content: Text('Please turn on Bluetooth to scan for devices.'),
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      if (kDebugMode) {
        print('Permissions not granted. Showing permission message.');
      }
      final message = <String>[];
      if (!bluetoothStatus.isGranted) {
        message.add('Bluetooth permission is required');
      }
      if (!locationStatus.isGranted) {
        message.add('Location permission is required');
      }

      final snackBar = SnackBar(
        content: Text(message.join(' and ')),
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> scan() async {
    if (isScanning) {
      if (kDebugMode) {
        print('Stopping scanning.');
      }
      FlutterBluePlus.stopScan();
      scanSubscription?.cancel();
    } else {
      try {
        setState(() {
          isScanning = true;
        });

        scanResultList.clear();
        seen.clear();

        if (kDebugMode) {
          print('Starting scanning.');
        }

        scanSubscription =
            FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
          // Updated parameter type
          for (ScanResult r in results) {
            if (!seen.contains(r.device.id.id)) {
              if (kDebugMode) {
                print(
                    '${r.device.id.id}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
              }
              seen.add(r.device.id.id);
              setState(() {
                scanResultList.add(r);
              });
            }
          }
        });

        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      } catch (e) {
        if (kDebugMode) {
          print("Error scanning: $e");
        }
        const snackBar = SnackBar(
          content: Center(
              child: Text('Error Scanning: Check Bluetooth connectivity')),
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        setState(() {
          isScanning = false;
        });
        if (kDebugMode) {
          print('Scanning finished.');
        }
      }
    }
  }

  Widget deviceSignal(ScanResult r) {
    return SizedBox(
      width: 50, // Set an appropriate width
      height: 20, // Set an appropriate height
      child: Center(
        child: Text(
          r.rssi.toString(),
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  /* Widget for device MAC address */
  Widget deviceMacAddress(ScanResult r) {
    return Text(
      r.device.id.id,
      style: TextStyle(
        color: Colors.deepPurple,
      ),
    );
  }

  /* Widget for device name */
  Widget deviceName(ScanResult r) {
    String name = '';

    if (r.device.localName.isNotEmpty) {
      // If device.name has a value
      name = r.device.localName;
    } else if (r.advertisementData.localName.isNotEmpty) {
      // If advertisementData.localName has a value
      name = r.advertisementData.localName;
    } else {
      // If both are empty, name is unknown
      name = 'N/A';
    }
    return Text(
      name,
      style: TextStyle(
        color: Colors.deepPurple,
      ),
    );
  }

  /* Widget for BLE icon */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      child: Icon(
        Icons.bluetooth,
        color: Theme.of(context).colorScheme.background,
      ),
    );
  }

  Future<void> onTap(ScanResult r) async {
    if (kDebugMode) {
      print(r.device.localName);
    }

    try {
      final BluetoothDevice device = r.device;
      await device.connect(autoConnect: false);

      final List<BluetoothService> services = await device.discoverServices();

      setState(() {
        bluetoothService = services;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenOne(services: services, device: device),
        ),
      );
    } catch (error) {
      const snackBar = SnackBar(
        content:
            Center(child: Text('Error Connecting or Discovering Services')),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (kDebugMode) {
        print("Error connecting to device or discovering services: $error");
      }
    }
  }

  /* Widget for device item */
  Widget listItem(ScanResult r) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.5),
          borderRadius: BorderRadius.circular(
              20.0), // Set the border radius to achieve rounded edges
        ),
        child: ListTile(
          onTap: () => onTap(r),
          leading: leading(r),
          title: deviceName(r),
          subtitle: deviceMacAddress(r),
          trailing: deviceSignal(r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            'NEURASTIM',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            color: Colors.transparent,
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ScanPage()));
            },
            icon: Icon(
              Icons.settings,
              color: Colors.deepPurple,
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        /* Display the device list */
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: scan,
        // Display stop icon if scanning, search icon if not scanning
        child: Icon(
          isScanning ? Icons.stop : Icons.search,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}
