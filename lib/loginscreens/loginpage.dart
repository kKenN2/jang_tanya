import 'package:flutter/material.dart';
import 'package:medicineproject/loginscreens/RegisterPage.dart';
import 'package:medicineproject/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == "admin" && password == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jang tanya')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'ชื่อผู้ใช้'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'รหัสผ่าน'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('เข้าสู่ระบบ')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text("สมัครใช้งาน"),
            ),
          ],
        ),
      ),
    );
  }
}
