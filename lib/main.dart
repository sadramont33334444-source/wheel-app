import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  // قفل کردن جهت صفحه به Portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FortuneWheelApp());
}

class FortuneWheelApp extends StatelessWidget {
  const FortuneWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'گردونه شانس',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Vazirmatn', // فونت فارسی (اختیاری)
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
