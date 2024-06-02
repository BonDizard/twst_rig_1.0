import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:trust_rig_version_one/providers.dart';
import 'package:trust_rig_version_one/show_snack_bar.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  Future<void> saveToExcel({required WidgetRef ref}) async {
    final dbHelper = ref.watch(databaseProvider);

    List<Map<String, dynamic>> data = await dbHelper.getAllData();

    Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('trust rig');
    sheet.getRangeByName('A2').setText('time');
    sheet.getRangeByName('B2').setText('voltage');
    sheet.getRangeByName('C2').setText('current');
    sheet.getRangeByName('D2').setText('torque');
    sheet.getRangeByName('E2').setText('temperature');
    sheet.getRangeByName('F2').setText('thrust');
    sheet.getRangeByName('G2').setText('power');
    sheet.getRangeByName('H2').setText('rpm');
    sheet.getRangeByName('I2').setText('throttle');

    // Insert data into Excel row by row
    int rowIndex = 4; // Start inserting data from row 4
    for (Map<String, dynamic> row in data) {
      sheet.getRangeByName('A$rowIndex').setText(row['timestamp']);
      sheet.getRangeByName('B$rowIndex').setText(row['voltage'].toString());
      sheet.getRangeByName('C$rowIndex').setText(row['current'].toString());
      sheet.getRangeByName('D$rowIndex').setText(row['torque'].toString());
      sheet.getRangeByName('E$rowIndex').setText(row['temperature'].toString());
      sheet.getRangeByName('F$rowIndex').setText(row['thrust'].toString());
      sheet.getRangeByName('G$rowIndex').setText(row['power'].toString());
      sheet.getRangeByName('H$rowIndex').setText(row['rpm'].toString());
      sheet.getRangeByName('I$rowIndex').setText(row['throttle'].toString());
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
      print('Error resetting database: $e');
    }
    showSnackBar(context, 'Database reset complete');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          await reset(ref: ref, context: context);
        },
        icon: Icon(Icons.restart_alt),
      ),
      title: Text('Test Rig'),
      actions: [
        TextButton(
          onPressed: () {
            saveToExcel(ref: ref);
          },
          child: Text('save'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Height of the AppBar
}
