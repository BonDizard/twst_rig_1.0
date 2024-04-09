import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  Future<void> saveToExcel() async {
    Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('trust rig');
    List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.xlsx';
    print(fileName);
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [ElevatedButton(onPressed: saveToExcel, child: Text('save'))],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight); // Height of the AppBar
}
