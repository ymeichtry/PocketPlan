import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = "English";
  bool _requirePassword = true;
  String _autoSaveFrequency = "Daily";
  TextEditingController _autoSaveAmountController = TextEditingController(text: "5.50");
  TextEditingController _dailyLimitController = TextEditingController(text: "0");
  TextEditingController _weeklyLimitController = TextEditingController(text: "0");
  TextEditingController _monthlyLimitController = TextEditingController(text: "5000");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
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
              },
              items: ["English", "Deutsch", "Français", "Español"]
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Password when Log in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(
                  value: _requirePassword,
                  onChanged: (newValue) {
                    setState(() {
                      _requirePassword = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            Text("Add Automatic Save", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _autoSaveFrequency,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        _autoSaveFrequency = newValue!;
                      });
                    },
                    items: ["Daily", "Weekly", "Monthly"]
                        .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                        .toList(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _autoSaveAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Amount"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Text("Saving Limit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _dailyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Daily"),
            ),
            TextField(
              controller: _weeklyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weekly"),
            ),
            TextField(
              controller: _monthlyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Monthly"),
            ),
          ],
        ),
      ),
    );
  }
}
