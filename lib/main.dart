import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:medicineproject/screens/inputmed.dart';
import 'package:medicineproject/screens/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// เรียกใช้แอป
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.blue[50],
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

// Model ยา
class Medicine {
  final String name;
  final String description;
  final String mealTimes;
  final String times;

  Medicine({
    required this.name,
    required this.description,
    required this.mealTimes,
    required this.times,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      description: json['description'],
      mealTimes: json['mealTimes'],
      times: json['times'],
    );
  }
}

// ดึงข้อมูลจาก backend
Future<List<Medicine>> fetchMedicines() async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/medicines'),
  );

  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((json) => Medicine.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load medicines');
  }
}

// หน้าหลัก Home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.teal[100],
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            const Text(
              'ยาของฉันวันนี้',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            const TimeDisplay(), // Show time with a separate widget
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TimeDisplay(), // Show time with a separate widget
                  FutureBuilder<List<Medicine>>(
                    future: fetchMedicines(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No medicines found');
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Disable scrolling of the inner ListView
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return MedicineBox(medicine: snapshot.data![index]);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
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
        iconSize: 28.0,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

// กล่องแสดงข้อมูลยา
class MedicineBox extends StatelessWidget {
  final Medicine medicine;

  const MedicineBox({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.cyan[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: Center(child: Text('รูปยา')),
          ),
          SizedBox(height: 10),
          Text('ชื่อยา: ${medicine.name}', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('สรรพคุณยา: ${medicine.description}'),
          Text('เวลาที่ต้องกิน: ${medicine.times}'),
          Text('จำนวน: ${medicine.mealTimes}'),
        ],
      ),
    );
  }
}

// แสดงเวลา
class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
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
          'dd/MM/yyyy HH:mm:ss',
        ).format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: const TextStyle(fontSize: 16, color: Colors.teal),
    );
  }
}
