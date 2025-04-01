import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:medicineproject/screens/inputmed.dart';
import 'package:medicineproject/screens/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat(
          'dd/MM/yyyy  HH:mm:ss',
        ).format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text(
          'สมศัก จริงดิ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: Text('User Pic'),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'วัน/เดือน/ปี',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  _currentTime,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
        onTap: (index) {
          if (index == 0) {
            // Assuming the medical_services icon is at index 0
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Inputmed()),
            );
          /*} else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListPage()),
            );*/
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()), // Corrected line
            );
          }
          // You can add more conditions here for other bottom navigation bar items if needed.
        },
      ),
    );
  }
}
