import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> savingHistory = [];
  double totalSaved = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavingHistory();
  }

Future<void> _loadSavingHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? historyJson = prefs.getString('savingHistory');

  if (historyJson != null) {
    List<dynamic> decodedList = json.decode(historyJson);
    List<Map<String, String>> historyList = decodedList.map((item) {
    return Map<String, String>.from(item as Map);
    }).toList();

    double calculatedTotal = _calculateTotalSavedFromList(historyList);

    setState(() {
      savingHistory = historyList;
      totalSaved = calculatedTotal;
    });
  }
}

double _calculateTotalSavedFromList(List<Map<String, String>> history) {
  double total = 0.0;
  for (var entry in history) {
    String rawAmount = entry['amount'] ?? '0';
    String cleanAmount = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
    double amount = double.tryParse(cleanAmount) ?? 0.0;
    total += amount;
  }
  return total;
}

List<BarChartGroupData> _prepareBarChartData() {
  List<BarChartGroupData> bars = [];
  DateTime today = DateTime.now();

  Map<int, double> dailySavings = {};

  for (var entry in savingHistory) {
    DateTime entryDate = DateTime.parse(entry['date']!);
    int daysAgo = today.difference(entryDate).inDays;

    if (daysAgo < 7) {
      double amount = double.tryParse(entry['amount']!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      dailySavings[6 - daysAgo] = (dailySavings[6 - daysAgo] ?? 0) + amount;
    }
  }

  for (int i = 0; i < 7; i++) {
    bars.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dailySavings[i] ?? 0.0,
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  return bars;
}

@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF004D40), Color.fromARGB(255, 54, 64, 60)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "PocketPlan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF263238),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Color(0xFFEAEAEA),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Saved",
                      // ignore: deprecated_member_use
                      style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$${totalSaved.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Your Progress This Week",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Color(0xFFEAEAEA),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              DateTime today = DateTime.now();
                              DateTime date = today.subtract(Duration(days: 6 - value.toInt()));
                              return Text("${date.day}.${date.month}", style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0)));
                            },
                            reservedSize: 32,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _prepareBarChartData()
                          .map((group) => BarChartGroupData(
                                x: group.x,
                                barRods: group.barRods
                                    .map((rod) => BarChartRodData(
                                          toY: rod.toY,
                                          color: Colors.green[700],
                                          width: 16,
                                          borderRadius: BorderRadius.circular(4),
                                        ))
                                    .toList(),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}