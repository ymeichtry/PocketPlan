import 'package:flutter/material.dart';

class SavingsPage extends StatefulWidget {
  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  List<Map<String, dynamic>> savings = [
    {"title": "Cruise", "goal": 4500, "saved": 4200},
    {"title": "Car", "goal": 45734, "saved": 12420},
  ];

  List<Map<String, String>> savingHistory = [
    {"date": "01.01.2024 12:25", "amount": "10.-"},
    {"date": "01.01.2024 12:25", "amount": "10.-"},
    {"date": "01.01.2024 12:25", "amount": "10.-"},
  ];

  void _showSavingHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Saving History"),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: savingHistory
                .map((entry) => ListTile(
                      title: Text(entry["date"]!),
                      trailing: Text(entry["amount"]!),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
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
              setState(() {
                savings[index]["saved"] += int.parse(amountController.text);
              });
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showCreateNewSaving() {
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create new Saving"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount to save"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                savings.add({
                  "title": titleController.text,
                  "goal": int.parse(amountController.text),
                  "saved": 0
                });
              });
              Navigator.pop(context);
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Savings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: savings.length,
                itemBuilder: (context, index) {
                  final saving = savings[index];
                  bool isDone = saving["saved"] >= saving["goal"];
                  return Card(
                    child: ListTile(
                      title: Text(saving["title"]),
                      subtitle: Text(
                        "Saved: ${saving["saved"]} / ${saving["goal"]}",
                        style: TextStyle(
                            color: isDone ? Colors.green : Colors.red),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _showAddMoneyDialog(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showSavingHistory,
              child: Text("See Saving History"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showCreateNewSaving,
              child: Text("Create New Saving"),
            ),
          ],
        ),
      ),
    );
  }
}
