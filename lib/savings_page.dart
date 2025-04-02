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

  void _showEditSavingDialog(int index) {
    TextEditingController titleController =
        TextEditingController(text: savings[index]["title"]);
    TextEditingController amountController =
        TextEditingController(text: savings[index]["goal"].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Saving"),
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
              decoration: InputDecoration(labelText: "Goal Amount"),
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
                savings[index]["title"] = titleController.text;
                savings[index]["goal"] = int.parse(amountController.text);
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
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

  void _deleteSaving(int index) {
    setState(() {
      savings.removeAt(index);
    });
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
              onPressed: _showCreateNewSaving,
              child: Text("Create New Saving"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingCard(Map<String, dynamic> saving, int index) {
    bool isDone = saving["saved"] >= saving["goal"];

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
}
