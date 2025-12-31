
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

class Pin_fingerloginPage extends StatefulWidget {
  const Pin_fingerloginPage({super.key});

  @override
  _Pin_fingerloginPageState createState() => _Pin_fingerloginPageState();
}

class _Pin_fingerloginPageState extends State<Pin_fingerloginPage> {
  List<Map<String, dynamic>>? userdata = [];
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  bool _hasPin = false;
  bool _isSettingPin = false;
  String _tempPin = '';
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
    _authenticateWithBiometrics();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasPin = prefs.containsKey('user_pin');
      if (!_hasPin) {
        _isSettingPin = true;
        _feedbackMessage = 'Create a 4-digit PIN for your account.';
      }
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometrics = false;
    }

    if (!mounted) return;

    if (canCheckBiometrics) {
      try {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access your account',
        );
        if (didAuthenticate) {
          _navigateToHome();
        }
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AppVisitRequestPage(visitors: userdata!),),
    );
  }

  void _handlePinInput(String digit) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += digit;
      });
    }

    if (_pinController.text.length == 4) {
      if (_isSettingPin) {
        _handlePinSetup();
      } else {
        _verifyPin();
      }
    }
  }

  void _handlePinSetup() async {
    if (_tempPin.isEmpty) {
      setState(() {
        _tempPin = _pinController.text;
        _pinController.clear();
        _feedbackMessage = 'Confirm your PIN';
      });
    } else {
      if (_tempPin == _pinController.text) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pin', _tempPin);
        setState(() {
          _hasPin = true;
          _isSettingPin = false;
          _feedbackMessage = 'PIN created successfully!';
        });
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToHome();
        });
      } else {
        setState(() {
          _feedbackMessage = 'PINs do not match. Please try again.';
          _pinController.clear();
          _tempPin = '';
        });
      }
    }
  }

  void _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPin = prefs.getString('user_pin');

    if (savedPin == _pinController.text) {
      _navigateToHome();
    } else {
      setState(() {
        _feedbackMessage = 'Incorrect PIN. Please try again.';
        _pinController.clear();
      });
    }
  }

  void _deleteLastDigit() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Icon(Icons.lock_outline, size: 60, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              _isSettingPin ? 'Setup Your PIN' : 'Enter Your PIN',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Text(
              _feedbackMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildPinDisplay(),
            const Spacer(flex: 1),
            _buildNumpad(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pinController.text.length ? Colors.deepPurple : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumpadButton('1'),
            _buildNumpadButton('2'),
            _buildNumpadButton('3'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumpadButton('4'),
            _buildNumpadButton('5'),
            _buildNumpadButton('6'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumpadButton('7'),
            _buildNumpadButton('8'),
            _buildNumpadButton('9'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumpadIconButton(Icons.fingerprint, _authenticateWithBiometrics),
            _buildNumpadButton('0'),
            _buildNumpadIconButton(Icons.backspace, _deleteLastDigit),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadButton(String digit) {
    return MaterialButton(
      onPressed: () => _handlePinInput(digit),
      shape: const CircleBorder(),
      color: Colors.white,
      elevation: 4,
      padding: const EdgeInsets.all(24),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildNumpadIconButton(IconData icon, VoidCallback onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      color: Colors.white,
      elevation: 4,
      padding: const EdgeInsets.all(20),
      child: Icon(icon, size: 32, color: Colors.deepPurple),
    );
  }
}
