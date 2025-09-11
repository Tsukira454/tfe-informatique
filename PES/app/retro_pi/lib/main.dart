// main.dart
import 'package:flutter/material.dart';
import 'package:retro_pi/pages/home.dart';
import 'package:window_size/window_size.dart'; // pub.dev/packages/window_size
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Retro Pi');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1280, 720));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(        // ← On associe la clé ici
      themeMode: ThemeMode.system,
      // (Vos thèmes)
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}