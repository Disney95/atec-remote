import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AtecRemoteApp());
}

class AtecRemoteApp extends StatelessWidget {
  const AtecRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATEC Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
