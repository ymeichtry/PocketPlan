import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavingsPage extends StatefulWidget {
  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  List<Map<String, dynamic>> savings = [];
  List<Map<String, String>> savingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSavings();
    _loadSavingHistory();
  }

  void _addToHistory(int amount, String savingTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('savingHistory');
    List<Map<String, String>> currentHistory = [];

    if (historyJson != null) {
      List<dynamic> decoded = json.decode(historyJson);
      currentHistory = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    String formattedDate = DateTime.now().toString().substring(0, 16);
    Map<String, String> newEntry = {
      "date": formattedDate,
      "amount": amount.toString(),
      "savingTitle": savingTitle
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

    List<Map<String, String>> todayHistory = savingHistory
        .where((entry) => entry["date"]!.startsWith(today))
        .toList();
    List<Map<String, String>> monthlyHistory = savingHistory
        .where((entry) => entry["date"]!.substring(0, 7) == thisMonth)
        .toList();

    int dailyTotal = todayHistory.fold(0, (sum, item) => sum + int.parse(item["amount"]!));
    int monthlyTotal = monthlyHistory.fold(0, (sum, item) => sum + int.parse(item["amount"]!));

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  
void _showAddMoneyDialog(int index) {
  TextEditingController amountController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Money"),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: "Amount to save"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            int amount = int.tryParse(amountController.text) ?? 0;
            int remainingAmount = savings[index]["goal"] - savings[index]["saved"];

            if (amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid amount.")),
              );
              return;
            }

            if (amount > remainingAmount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You can only add up to $remainingAmount!")),
              );
              return;
            }

            _addMoney(index, amount);
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            HapticFeedback.lightImpact();
            
          },
          child: Text("Add", style: TextStyle(color: Colors.black)),
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
          title: const Text("Delete Saving", style: TextStyle(color: Colors.white)),
          content: const Text("Do you really want to delete this?", style: TextStyle(color: Colors.white)),
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
        savings.where((s) => s["saved"] < s["goal"]).toList();
    List<Map<String, dynamic>> doneSavings =
        savings.where((s) => s["saved"] >= s["goal"]).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Savings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (ongoingSavings.isNotEmpty) ...[
                    Text("Ongoing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...ongoingSavings.map((saving) {
                      int index = savings.indexOf(saving);
                      return _buildSavingCard(saving, index);
                    }).toList(),
                  ],
                  if (doneSavings.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text("Done", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...doneSavings.map((saving) {
                      int index = savings.indexOf(saving);
                      return _buildSavingCard(saving, index);
                    }).toList(),
                  ],
                ],
              ),
            ),
            SizedBox(height: 10),
                        ElevatedButton(
              onPressed: _showSavingHistory,
              child: Text("See Saving History"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showCreateNewSavingDialog(),
              child: Text("Create New Saving"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingCard(Map<String, dynamic> saving, int index, bool isDone) {
    double percent = saving["saved"] / saving["goal"];
    percent = percent > 1 ? 1 : percent;

    return Card(
      child: ListTile(
        title: Text(saving["title"]),
        subtitle: Text(
          "Saved: ${saving["saved"]} / ${saving["goal"]}",
          style: TextStyle(color: isDone ? Colors.green : Colors.red),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditSavingDialog(index),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddMoneyDialog(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSaving(index),
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
      builder: (context) => AlertDialog(
        title: Text("Create new Saving"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Amount to save")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _addSaving(titleController.text, int.parse(amountController.text));
              Navigator.pop(context);
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showEditSavingDialog(int index) {
    TextEditingController titleController = TextEditingController(text: savings[index]["title"]);
    TextEditingController amountController = TextEditingController(text: savings[index]["goal"].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Saving"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Goal Amount")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _editSaving(index, titleController.text, int.parse(amountController.text));
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}