import 'package:flutter/material.dart';
import 'package:medicineproject/main.dart';
import 'package:medicineproject/loginscreens/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // TODO: ตรวจสอบจากเซิร์ฟเวอร์จริงๆ
    if (_emailController.text == 'user@example.com' &&
        _passwordController.text == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง')),
      );
    }
  }

  void _register() {
    // ไปหน้าลงทะเบียน
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // เปลี่ยนสีพื้นหลังเป็นเขียวอ่อน
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.medical_services, size: 100, color: Color.fromARGB(255, 31, 201, 150)), // เปลี่ยนสีไอคอนเป็นเขียว
                const SizedBox(height: 20),
                // กรอกอีเมล
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 37, 225, 156)), // เปลี่ยนสีของ label เป็นเขียวเข้ม
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // ไม่มีขอบ
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                // กรอกรหัสผ่าน
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 37, 225, 156)), // เปลี่ยนสีของ label เป็นเขียวเข้ม
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // ไม่มีขอบ
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                // ปุ่มเข้าสู่ระบบ
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 76, 175, 152), // ปรับสีปุ่มเป็นสีเขียว
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // มุมโค้ง
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('เข้าสู่ระบบ'),
                ),
                const SizedBox(height: 15),
                // ปุ่มไปหน้าลงทะเบียน
                TextButton(
                  onPressed: _register,
                  child: const Text(
                    'ยังไม่มีบัญชี? ลงทะเบียน',
                    style: TextStyle(color: Color.fromARGB(255, 40, 211, 154)), // เปลี่ยนสีข้อความเป็นเขียว
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



