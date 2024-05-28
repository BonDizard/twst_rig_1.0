import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trust_rig_version_one/permissions_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) async {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'test rig',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          surface: Colors.black,
          primary: Colors.blue,
          background: Colors.white,
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const PermissionsPage(),
    );
  }
}
