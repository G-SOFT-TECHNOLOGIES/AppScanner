import 'package:bahiascanner_example/scan_code_page.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        // "/generate": (context) => const GenerateCodePage(),
        "/scan": (context) => const ScanCodePage(),
      },
      initialRoute: "/scan",
    );
  }
}