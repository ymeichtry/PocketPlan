import 'package:flutter/material.dart';
import 'package:pocketplan/pin_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketplan/home_page.dart';
import 'package:pocketplan/savings_page.dart';
import 'package:pocketplan/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool requirePassword = prefs.getBool("requirePassword") ?? false;
  String? savedPassword = prefs.getString("userPassword");

  runApp(
    MyApp(
      showLogin:
          requirePassword && savedPassword != null && savedPassword.isNotEmpty,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showLogin;

  const MyApp({super.key, required this.showLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketPlan',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: showLogin ? PinLoginPage() : MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), SavingsPage(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFF263238),
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Savings"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
