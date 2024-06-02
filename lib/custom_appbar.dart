import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:trust_rig_version_one/providers.dart';
import 'package:trust_rig_version_one/show_snack_bar.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final Widget child;
  final BluetoothDevice device;
  const CustomAppBar({super.key, required this.child, required this.device});

  @override
  ConsumerState createState() => _CustomAppBarState();

  @override
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  StreamSubscription<BluetoothConnectionState>? _stateListener;
  Color connectionState = Colors.blueGrey;
  BluetoothConnectionState deviceState = BluetoothConnectionState.disconnected;

  @override
  void initState() {
    // Register the state connection listener
    _stateListener = widget.device.connectionState.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // Ignore if the state is the same
        return;
      }
      // TODO: implement initState
      setBleConnectionState(event);
      super.initState();
    });
  }

  setBleConnectionState(BluetoothConnectionState event) {
    if (kDebugMode) {
      print('Received Connection State: $event');
    }
    switch (event) {
      case BluetoothConnectionState.disconnected:
        setState(() {
          connectionState = Colors.red;
        });

        break;
      case BluetoothConnectionState.disconnecting:
        setState(() {
          connectionState = Colors.orange;
        });
        break;
      case BluetoothConnectionState.connected:
        setState(() {
          connectionState = Colors.greenAccent;
        });
        break;
      case BluetoothConnectionState.connecting:
        setState(() {
          connectionState = Colors.greenAccent;
        });
        break;
    }
    deviceState = event;
    setState(() {});
  }

  Future<void> saveToExcel({required WidgetRef ref}) async {
    final dbHelper = ref.watch(databaseProvider);

    List<Map<String, dynamic>> data = await dbHelper.getAllData();

    Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('trust rig');
    sheet.getRangeByName('A2').setText('Timestamp\n(h : m : s)');
    sheet.getRangeByName('B2').setText('Thrust\n(N)');
    sheet.getRangeByName('C2').setText('Torque\n(N/m)');
    sheet.getRangeByName('D2').setText('Current\n(A)');
    sheet.getRangeByName('E2').setText('Voltage\n(V)');
    sheet.getRangeByName('F2').setText('Power\n(W)');
    sheet.getRangeByName('G2').setText('Temp\n(°C)');
    sheet.getRangeByName('H2').setText('Speed\n(RPM)');
    sheet.getRangeByName('I2').setText('PWM\n(us)');
    sheet.getRangeByName('J2').setText('Throttle\n(%)');
    // Insert data into Excel row by row
    int rowIndex = 4; // Start inserting data from row 4
    for (Map<String, dynamic> row in data) {
      sheet.getRangeByName('A$rowIndex').setText(row['timestamp']);
      sheet.getRangeByName('B$rowIndex').setText(row['thrust'].toString());
      sheet.getRangeByName('C$rowIndex').setText(row['torque'].toString());
      sheet.getRangeByName('D$rowIndex').setText(row['current'].toString());
      sheet.getRangeByName('E$rowIndex').setText(row['voltage'].toString());
      sheet.getRangeByName('F$rowIndex').setText(row['power'].toString());
      sheet.getRangeByName('G$rowIndex').setText(row['temperature'].toString());
      sheet.getRangeByName('H$rowIndex').setText(row['speed'].toString());
      sheet.getRangeByName('I$rowIndex').setText(row['pwm'].toString());
      sheet.getRangeByName('J$rowIndex').setText(row['throttle'].toString());
      rowIndex++;
    }

    List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  Future<void> reset(
      {required WidgetRef ref, required BuildContext context}) async {
    try {
      ref.watch(databaseProvider).resetDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting database: $e');
      }
    }
    showSnackBar(context, 'Database reset complete');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          onPressed: () {
            saveToExcel(ref: ref);
          },
          child: Text(
            'save',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
      title: const Text('Z-DIME WING-STATION'),
      actions: [
        Container(
          height: 10,
          width: 10,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: connectionState),
        ),
        widget.child,
        IconButton(
          onPressed: () async {
            await reset(ref: ref, context: context);
          },
          icon: const Icon(Icons.restart_alt),
        ),
        IconButton(
          onPressed: () async {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
