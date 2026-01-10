// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retro_pi/pages/home.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    // ✅ On assigne les options à une variable
    const WindowOptions windowOptions = WindowOptions(
      fullScreen: true,               // pas de plein écran total
      titleBarStyle: TitleBarStyle.hidden, // barre cachée mais fenêtre normale
      size: Size(1280, 720),           // taille de la fenêtre
      minimumSize: Size(1280, 720),
      maximumSize: Size(1280, 720),
    );

    // On attend que la fenêtre soit prête, puis on applique
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
