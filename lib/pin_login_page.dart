import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pocketplan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final List<String> _enteredPin = <String>[];
  String? _savedPin;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPin().then((_) {
      _checkBiometrics();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      // ignore: always_specify_types
      MaterialPageRoute(builder: (_) => const MainPage()),
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric authentication failed")),
      );
    }
  }

  Widget _buildCircle(bool filled) {
    return Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _handleBackspace,
      child: const Icon(Icons.backspace, size: 30, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Column(
              children: <Widget>[
                Text(
                  "Welcome to",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  "PocketPlan",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Saving made simple, always in your pocket",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ignore: always_specify_types
                ...List.generate(
                  4,
                  (int index) => _buildCircle(index < _enteredPin.length),
                ),
                const SizedBox(width: 10),
                _buildBackspaceButton(),
              ],
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      <String>[
                        '1',
                        '2',
                        '3',
                      ].map((String n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      <String>[
                        '4',
                        '5',
                        '6',
                      ].map((String n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      <String>[
                        '7',
                        '8',
                        '9',
                      ].map((String n) => _buildKey(n)).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 80),
                    _buildKey('0'),
                    const SizedBox(width: 80),
                  ],
                ),
              ],
            ),
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: _checkBiometrics,
                  child: const Text(
                    "Use Biometrics",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
