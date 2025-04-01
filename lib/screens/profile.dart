import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicineproject/screens/inputmed.dart'; // Import Inputmed

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String _notificationSound = 'เสียง 1';
  final List<String> _soundOptions = ['เสียง 1', 'เสียง 2', 'เสียง 3', 'เสียงอื่น ๆ'];

  final TextEditingController _usernameController = TextEditingController(text: 'LWA');
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สมศักดิ์ จริงดิ'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Text('User Pic'),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'วันที่: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'เวลา: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField('ชื่อผู้ใช้', _usernameController),
              _buildTextField('เพศ', _genderController),
              _buildTextField('อายุ', _ageController),
              _buildTextField('อีเมล', _emailController),
              _buildSoundSelection(),
              _buildTextField('รหัสผ่าน', _passwordController, obscureText: true),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        print('Username: ${_usernameController.text}');
                        print('Gender: ${_genderController.text}');
                        print('Age: ${_ageController.text}');
                        print('Email: ${_emailController.text}');
                        print('Notification Sound: $_notificationSound');
                      }
                      _isEditing = !_isEditing;
                    });
                  },
                  child: Text(_isEditing ? 'บันทึก' : 'แก้ไข'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Inputmed()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
        iconSize: 28.0, // Adjust this value
        selectedFontSize: 14.0, // Adjust this value
        unselectedFontSize: 12.0, // Adjust this value
        showSelectedLabels: false, // Or adjust to your needs
        showUnselectedLabels: false, // Or adjust to your needs
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSoundSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('เสียงแจ้งเตือน'),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: _notificationSound,
          items: _soundOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: _isEditing
              ? (value) {
                  setState(() {
                    _notificationSound = value!;
                  });
                }
              : null,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}