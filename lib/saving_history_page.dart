import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavingHistoryPage extends StatefulWidget {
  const SavingHistoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SavingHistoryPageState createState() => _SavingHistoryPageState();
}

class _SavingHistoryPageState extends State<SavingHistoryPage> {

  Future<List<Map<String, String>>> _loadSavingHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('savingHistory');
    
    if (historyJson != null) {
      List<dynamic> decodedList = json.decode(historyJson);
      List<Map<String, String>> historyList = decodedList.map((e) {
        return Map<String, String>.from(e as Map<dynamic, dynamic>);
      }).toList();
      
      return historyList;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saving History", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF263238), 
        iconTheme: IconThemeData(color: Colors.white),
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
        child: FutureBuilder<List<Map<String, String>>>(
          future: _loadSavingHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); 
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No transactions yet.", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))));
            } else {
              List<Map<String, String>> savingHistory = snapshot.data!;
              return ListView.builder(
                itemCount: savingHistory.length,
                itemBuilder: (context, index) {
                  final entry = savingHistory[index];
                  return Card(
                    color: Color.fromARGB(255, 211, 211, 211),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.monetization_on, color: const Color.fromARGB(255, 0, 0, 0)),
                      title: Text(entry["date"]!, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                      subtitle: Text('Saving: ${entry["savingTitle"]}', style: TextStyle(color: const Color.fromARGB(179, 32, 32, 32))),
                      trailing: Text('${entry["amount"]!}.-', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
