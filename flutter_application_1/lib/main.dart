import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StackOverflowApp());
}

class StackOverflowApp extends StatelessWidget {
  const StackOverflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Overflow Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFf48024),
          primary: const Color(0xFFf48024),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
