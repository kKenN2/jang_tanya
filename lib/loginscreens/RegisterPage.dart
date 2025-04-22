import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _register() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill in all fields");
    } else if (password != confirmPassword) {
      _showError("Passwords do not match");
    } else {
      // สมมุติว่า "สมัคร" สำเร็จแล้วกลับไปหน้า login
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Register Successful'),
              content: Text('You can now log in.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context); // ปิด dialog
                    Navigator.pop(context); // กลับไปหน้า login
                  },
                ),
              ],
            ),
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สมัครใช้งาน')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'อีเมล'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'ชื่อ-นามสกุล ผู้ใช้'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'รหัสผ่าน'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: Text('สมัคร')),
          ],
        ),
      ),
    );
  }
}
