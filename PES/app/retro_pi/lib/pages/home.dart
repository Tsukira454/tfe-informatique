import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart'; // ajoute dans pubspec.yaml

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format console fixe
  setWindowMinSize(const Size(800, 480));
  setWindowMaxSize(const Size(800, 480));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  String _time = "";

  List<String> _accounts = ["Player1"];
  String _currentAccount = "Player1";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _loadAccounts();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accounts = prefs.getStringList("accounts") ?? ["Player1"];
      _currentAccount = prefs.getString("currentAccount") ?? _accounts.first;
    });
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("accounts", _accounts);
    await prefs.setString("currentAccount", _currentAccount);
  }

  void _showPlayerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black.withOpacity(0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sélection du joueur",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  ..._accounts.map((acc) => GestureDetector(
                        onTap: () {
                          setState(() => _currentAccount = acc);
                          _saveAccounts();
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _currentAccount == acc
                                ? Colors.blueAccent.withOpacity(0.4)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _currentAccount == acc
                                    ? Colors.blueAccent
                                    : Colors.grey,
                                child: const Icon(Icons.person,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                acc,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const Spacer(),
                              if (_currentAccount == acc)
                                const Icon(Icons.check,
                                    color: Colors.white),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newName = "Player${_accounts.length + 1}";
                      setState(() => _accounts.add(newName));
                      _saveAccounts();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter un joueur"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPowerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPowerButton(
                    icon: Icons.power_settings_new,
                    label: "Éteindre",
                    color: Colors.redAccent,
                  ),
                  _buildPowerButton(
                    icon: Icons.bedtime,
                    label: "Veille",
                    color: Colors.amberAccent,
                  ),
                  _buildPowerButton(
                    icon: Icons.restart_alt,
                    label: "Redémarrer",
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPowerButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12), // réduit (avant 18)
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white12,
            border: Border.all(color: color, width: 1.8),
          ),
          child: Icon(icon, color: color, size: 26), // réduit (avant 32)
        ),
        const SizedBox(height: 6), // réduit l'espacement
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13, // plus petit
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showPlayerMenu,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentAccount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        _time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.wifi, color: Colors.white),
                      const SizedBox(width: 12),
                      const Icon(Icons.battery_full, color: Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "📂 Contenu principal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // --- BOTTOM BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.home, color: Colors.white, size: 28),
                  const Icon(Icons.apps, color: Colors.white, size: 28),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    child: const Icon(Icons.settings,
                        color: Colors.white, size: 28),
                  ),
                  GestureDetector(
                    onTap: _showPowerMenu,
                    child: const Icon(Icons.power_settings_new,
                        color: Colors.redAccent, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAGE PARAMÈTRES ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.volume_up, color: Colors.white),
            title: Text("Son", style: TextStyle(color: Colors.white)),
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.display_settings, color: Colors.white),
            title: Text("Affichage", style: TextStyle(color: Colors.white)),
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.sd_storage, color: Colors.white),
            title: Text("Stockage", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
