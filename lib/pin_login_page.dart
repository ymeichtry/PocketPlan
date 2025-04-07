import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pocketplan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginPage extends StatefulWidget {
  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  List<String> _enteredPin = [];
  String? _savedPin;
  final LocalAuthentication auth = LocalAuthentication();

@override
void initState() {
  super.initState();
  _loadPin().then((_) {
    _checkBiometrics(); // Trigger after loading saved PIN
  });
}

  Future<void> _loadPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _savedPin = prefs.getString("userPin");
  }

  void _handleNumberPress(String number) async {
    if (_enteredPin.length >= 4) return;
    setState(() => _enteredPin.add(number));

    if (_enteredPin.length == 4) {
      String input = _enteredPin.join();
      if (_savedPin == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userPin", input);
        _navigateToHome();
      } else if (input == _savedPin) {
        _navigateToHome();
      } else {
        _showError();
      }
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin.removeLast());
    }
  }

  void _showError() {
    setState(() => _enteredPin.clear());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Incorrect PIN")));
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => MainPage())
    );
  }

Future<void> _checkBiometrics() async {
  try {
    bool canCheck = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (canCheck && isDeviceSupported) {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access PocketPlanner',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _navigateToHome();
      }
    }
  } catch (e) {
    debugPrint('Biometric auth error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Biometric authentication failed")),
    );
  }
}

  Widget _buildCircle(bool filled) {
    return Container(
      width: 15,
      height: 15,
      margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildKey(String number) {
    return GestureDetector(
      onTap: () => _handleNumberPress(number),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
        padding: EdgeInsets.all(22),
        child: Center(child: Text(number, style: TextStyle(fontSize: 22, color: Colors.white))),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _handleBackspace,
      child: Icon(Icons.backspace, size: 30, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF263238),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text("Welcome to", style: TextStyle(fontSize: 22, color: Colors.white)),
                Text("PocketPlan", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Saving made simple, always in your pocket", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(4, (index) => _buildCircle(index < _enteredPin.length)),
                SizedBox(width: 10),
                _buildBackspaceButton(),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['1', '2', '3'].map((n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['4', '5', '6'].map((n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['7', '8', '9'].map((n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 80),
                    _buildKey('0'),
                    SizedBox(width: 80),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                TextButton(
                  onPressed: _checkBiometrics,
                  child: Text("Use Biometrics", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
