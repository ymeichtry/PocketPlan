import 'package:flutter/material.dart';
import 'package:pocketplan/saving_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vibration/vibration.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  List<Map<String, dynamic>> savings = <Map<String, dynamic>>[];
  List<Map<String, String>> savingHistory = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    _loadSavings();
    _loadSavingHistory();
  }

  void _addToHistory(int amount, String savingTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('savingHistory');
    List<Map<String, String>> currentHistory = <Map<String, String>>[];

    if (historyJson != null) {
      List<dynamic> decoded = json.decode(historyJson);
      // ignore: always_specify_types
      currentHistory = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    String formattedDate = DateTime.now().toString().substring(0, 16);
    Map<String, String> newEntry = <String, String>{
      "date": formattedDate,
      "amount": amount.toString(),
      "savingTitle": savingTitle,
    };

    currentHistory.insert(0, newEntry);

    await prefs.setString('savingHistory', json.encode(currentHistory));

    setState(() {
      savingHistory = currentHistory;
    });
  }

  Future<void> _loadSavingHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('savingHistory');
    if (historyJson != null) {
      setState(() {
        savingHistory = List<Map<String, String>>.from(
          json.decode(historyJson),
        );
      });
    }
  }

  Future<void> _saveSavings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savingsJson = json.encode(savings);
    await prefs.setString('savings', savingsJson);
  }

  void _addMoney(int index, int amount) async {
    if (!await _canAddAmount(amount)) return;

    setState(() {
      savings[index]["saved"] += amount;
    });

    _addToHistory(amount, savings[index]["title"]);
    _saveSavings();
  }

  Future<bool> _canAddAmount(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyLimit = prefs.getInt("dailyLimit") ?? 0;
    int monthlyLimit = prefs.getInt("monthlyLimit") ?? 0;

    DateTime now = DateTime.now();
    String today = now.toIso8601String().substring(0, 10);
    String thisMonth = "${now.year}-${now.month}";

    List<Map<String, String>> todayHistory =
        savingHistory
            .where((Map<String, String> entry) => entry["date"]!.startsWith(today))
            .toList();
    List<Map<String, String>> monthlyHistory =
        savingHistory
            .where((Map<String, String> entry) => entry["date"]!.substring(0, 7) == thisMonth)
            .toList();

    int dailyTotal = todayHistory.fold(
      0,
      (int sum, Map<String, String> item) => sum + int.parse(item["amount"]!),
    );
    int monthlyTotal = monthlyHistory.fold(
      0,
      (int sum, Map<String, String> item) => sum + int.parse(item["amount"]!),
    );

    if (dailyLimit > 0 && (dailyTotal + amount) > dailyLimit) {
      _showError("Daily limit of $dailyLimit exceeded!");
      return false;
    }
    if (monthlyLimit > 0 && (monthlyTotal + amount) > monthlyLimit) {
      _showError("Monthly limit of $monthlyLimit exceeded!");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddMoneyDialog(int index) {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text("Add Money", style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount to save",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  int amount = int.tryParse(amountController.text) ?? 0;
                  int remainingAmount =
                      savings[index]["goal"] - savings[index]["saved"];

                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a valid amount.")),
                    );
                    return;
                  }

                  if (amount > remainingAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You can only add up to $remainingAmount!",
                        ),
                      ),
                    );
                    return;
                  }

                  _addMoney(index, amount);
                  Vibration.vibrate(duration: 150);
                  Navigator.pop(context);
                },
                child: const Text("Add", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  Future<void> _loadSavings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savingsJson = prefs.getString('savings');
    if (savingsJson != null) {
      setState(() {
        savings = List<Map<String, dynamic>>.from(json.decode(savingsJson));
      });
    }
  }

  void _addSaving(String title, int goal) {
    setState(() {
      // ignore: always_specify_types
      savings.add({"title": title, "goal": goal, "saved": 0});
      _saveSavings();
    });
  }

  void _editSaving(int index, String newTitle, int newGoal) {
    setState(() {
      savings[index]["title"] = newTitle;
      savings[index]["goal"] = newGoal;
      _saveSavings();
    });
  }

  void _deleteSaving(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            "Delete Saving",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Do you really want to delete this?",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savings.removeAt(index);
                  _saveSavings();
                });
                Navigator.pop(context);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ongoingSavings =
        savings.where((Map<String, dynamic> s) => s["saved"] < s["goal"]).toList();
    List<Map<String, dynamic>> doneSavings =
        savings.where((Map<String, dynamic> s) => s["saved"] >= s["goal"]).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Savings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF263238),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF004D40), Color.fromARGB(255, 54, 64, 60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    if (ongoingSavings.isNotEmpty) ...<Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Ongoing Goals",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      ...ongoingSavings.map((Map<String, dynamic> saving) {
                        int index = savings.indexOf(saving);
                        return _buildSavingCard(saving, index, false);
                      }),
                    ],
                    if (doneSavings.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Completed Goals",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      ...doneSavings.map((Map<String, dynamic> saving) {
                        int index = savings.indexOf(saving);
                        return _buildSavingCard(saving, index, true);
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateNewSavingDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "New Saving",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        // ignore: always_specify_types
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SavingHistoryPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 227, 227, 227),
                      foregroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.green),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.history),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingCard(Map<String, dynamic> saving, int index, bool isDone) {
    double percent = saving["saved"] / saving["goal"];
    percent = percent > 1 ? 1 : percent;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color.fromARGB(255, 225, 225, 225),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              saving["title"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent,
              color: Colors.green[700],
              backgroundColor: Colors.grey[600],
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              "${saving["saved"]} / ${saving["goal"]}",
              style: TextStyle(
                color:
                    isDone
                        ? Colors.green[700]
                        : const Color.fromARGB(255, 91, 91, 91),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 109, 109, 109),
                  ),
                  onPressed: () => _showEditSavingDialog(index),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () => _showAddMoneyDialog(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSaving(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNewSavingDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text(
              "Create new Saving",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount to save",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  _addSaving(
                    titleController.text,
                    int.parse(amountController.text),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Create",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditSavingDialog(int index) {
    TextEditingController titleController = TextEditingController(
      text: savings[index]["title"],
    );
    TextEditingController amountController = TextEditingController(
      text: savings[index]["goal"].toString(),
    );
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: Colors.grey[850],
            title: const Text("Edit Saving", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Goal Amount",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  _editSaving(
                    index,
                    titleController.text,
                    int.parse(amountController.text),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
    );
  }
}
