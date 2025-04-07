import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = "English";
  bool _requirePassword = false;
  String _autoSaveFrequency = "Daily";
  TextEditingController _autoSaveAmountController = TextEditingController(text: "0");

  int _dailyLimit = 0;
  int _monthlyLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString("selectedLanguage") ?? "English";
      _requirePassword = prefs.getBool("requirePassword") ?? false;
      _autoSaveFrequency = prefs.getString("autoSaveFrequency") ?? "Daily";
      _autoSaveAmountController.text = (prefs.getInt("autoSaveAmount") ?? 0).toString();
      _dailyLimit = prefs.getInt("dailyLimit") ?? 0;
      _monthlyLimit = prefs.getInt("monthlyLimit") ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedLanguage", _selectedLanguage);
    await prefs.setBool("requirePassword", _requirePassword);
    await prefs.setString("autoSaveFrequency", _autoSaveFrequency);
    await prefs.setInt("autoSaveAmount", int.tryParse(_autoSaveAmountController.text) ?? 0);
  }

  Future<void> _changePasswordDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentPassword = prefs.getString("userPassword") ?? "";
    TextEditingController controller = TextEditingController(text: currentPassword);
    bool isVisible = false;

await showDialog(
  context: context,
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text("Change your password", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            obscureText: !isVisible,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                onPressed: () => setState(() => isVisible = !isVisible),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.length > 4) {
                controller.text = value.substring(0, 4);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: 4));
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.length == 4) {
                  await prefs.setString("userPassword", controller.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password must be 4 digits")));
                }
              },
              child: Text("Save", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        );
      },
    );
  },
);}

  Future<void> _handleRequirePasswordChanged(bool newValue) async {
    if (newValue) {
      await _changePasswordDialog();
    }
    setState(() {
      _requirePassword = newValue;
    });
    _saveSettings();
  }

  Future<void> _saveLimits(int daily, int monthly) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("dailyLimit", daily);
    await prefs.setInt("monthlyLimit", monthly);
    setState(() {
      _dailyLimit = daily;
      _monthlyLimit = monthly;
    });
  }

  void _showLimitDialog() {
    TextEditingController dailyController = TextEditingController(text: _dailyLimit.toString());
    TextEditingController monthlyController = TextEditingController(text: _monthlyLimit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850], 
        title: Text("Change Limits", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Daily Limit",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: monthlyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              int daily = int.tryParse(dailyController.text) ?? 0;
              int monthly = int.tryParse(monthlyController.text) ?? 0;
              _saveLimits(daily, monthly);
              Navigator.pop(context);
            },
            child: Text("Save", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Settings", style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF263238),
    ),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004D40), Color.fromARGB(255, 54, 64, 60)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Color(0xFFEAEAEA),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                          _saveSettings();
                        },
                        items: ["English", "Deutsch", "Français", "Español"]
                            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // Password Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Color(0xFFEAEAEA),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Password when Log in",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: _requirePassword,
                            onChanged: _handleRequirePasswordChanged,
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey[300],
                            activeTrackColor: Color(0xFF1E88E5),
                          ),
                        ],
                      ),
                      if (_requirePassword)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _changePasswordDialog,
                            child: Text("Change Password", style: TextStyle(fontSize: 16, color: const Color(0xFF1E88E5))),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Color(0xFFEAEAEA),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Saving Limits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Daily: $_dailyLimit .-"),
                      Text("Monthly: $_monthlyLimit .-"),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _showLimitDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF004D40),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Change Limits",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}