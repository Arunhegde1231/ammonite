import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:system_theme/system_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _instanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstanceURL();
  }

  Future<void> _loadInstanceURL() async {
    final prefs = await SharedPreferences.getInstance();
    _instanceController.text =
        prefs.getString('instanceURL') ?? 'https://tilvids.com';
  }

  Future<void> _saveInstanceURL() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instanceURL', _instanceController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instance URL saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, r, g, b),
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 125, 66, 227),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Instance'),
              tiles: [
                SettingsTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Custom Instance'),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _instanceController,
                        decoration: const InputDecoration(
                          hintText: 'https://example.com',
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _saveInstanceURL,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.cloud),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _instanceController.dispose();
    super.dispose();
  }
}
