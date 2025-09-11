import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    // initialise l'heure
    _updateTime();
    // met à jour toutes les secondes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // arrête le timer quand on quitte la page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1, // top bar
            child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.blue,
                      child: const Center(child: Text("LOGO + USER ?")),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color.fromARGB(255, 33, 243, 110),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(_time, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          const Icon(Icons.wifi),
                          const SizedBox(width: 10),
                          const Icon(Icons.battery_full),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8, // content
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text("Contenu"),
              ),
            ),
          ),
          Expanded(
            flex: 2, // bottom bar
            child: Container(
              color: const Color.fromARGB(255, 163, 47, 47),
              child: const Center(
                child: Text("Bottom"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
