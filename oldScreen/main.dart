import 'package:flutter/material.dart';
import 'package:medicineproject/screens/inputmed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Title",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("My Application"),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: 
            const Inputmed(),
            //const Home(), //Home Widget รับหน้าที่ในการ Display บนพื้นที่ Scaffold
      ),
    );
  }
}


