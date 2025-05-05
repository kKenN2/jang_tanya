import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'ชาย';
  bool _isRegistering = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอายุให้ถูกต้อง')),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    final userData = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'age': age,
      'gender': _gender,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/userdata')
,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      setState(() {
        _isRegistering = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
        );
        Navigator.pop(context);
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'เกิดข้อผิดพลาด';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('สมัครไม่สำเร็จ: $message')),
        );
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ลงทะเบียน'),
        backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: _buildInputDecoration('ชื่อผู้ใช้'),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('อีเมล'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration('รหัสผ่าน'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _ageController,
                        decoration: _buildInputDecoration('อายุ'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                        items: ['ชาย', 'หญิง']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        decoration: _buildInputDecoration('เพศ'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isRegistering ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRegistering
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('สมัครสมาชิก', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isRegistering ? null : () => Navigator.pop(context),
                  child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}


