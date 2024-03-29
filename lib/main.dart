import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trust_rig_version_one/permissions_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          surface: Colors.black,
          primary: Colors.red,
          background: Colors.green,
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const PermissionsPage(),
    );
  }
}
