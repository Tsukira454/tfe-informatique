import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      fullScreen: true,
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.black,
      skipTaskbar: true,
    );

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// --- MODÈLE DE JEU ---
class Game {
  final String name;
  final String imagePath;
  final String command;
  final Color accentColor;

  Game({
    required this.name,
    required this.imagePath,
    required this.command,
    this.accentColor = Colors.blueAccent,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  String _time = "";
  String _statusMessage = "";

  List<String> _accounts = ["Player1"];
  String _currentAccount = "Player1";

  // --- DONNÉES DES JEUX ---
  final List<Game> games = [
    Game(
      name: "supertux",
      imagePath: "assets/game/supertux.png",
      command: "supertux2",
      accentColor: Colors.purpleAccent,
    )
  ];

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

  Future<void> _executeCommand(String command) async {
    try {
      Process.start(command, []);
      setState(() {
        _statusMessage = "Lancement de $command...";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚀 Lancement: $command"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Erreur: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
                    onPressed: () {
                      final newName = "Player${_accounts.length + 1}";
                      setState(() => _accounts.add(newName));
                      _saveAccounts();
                      Navigator.pop(context);
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
                    icon: Icons.exit_to_app,
                    label: "Quitter",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      exit(0);
                    },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              border: Border.all(color: color, width: 1.8),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => _executeCommand(game.command),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: game.accentColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    game.accentColor.withOpacity(0.3),
                    game.accentColor.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: game.accentColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          game.accentColor,
                          game.accentColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: game.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.gamepad,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Lancer",
                      style: TextStyle(
                        color: game.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT - GRILLE DE JEUX ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(16),
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
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return _buildGameCard(games[index]);
                  },
                ),
              ),
            ),

            // --- BOTTOM BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()),
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