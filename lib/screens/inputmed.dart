import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart'; 
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:medicineproject/screens/profile.dart';

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

class Inputmed extends StatefulWidget {
  const Inputmed({super.key});

  @override
  State<Inputmed> createState() => _InputmedState();
}

class _InputmedState extends State<Inputmed> {
  File? _selectedImage;
  String? _selectedOption;
  Set<String> _selectedTimes = {};

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectStartDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _StartDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _EndDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  TextEditingController _StartDateController = TextEditingController();

  TextEditingController _EndDateController = TextEditingController();

  TextEditingController _morningTimeController = TextEditingController();
  TextEditingController _noonTimeController = TextEditingController();
  TextEditingController _eveningTimeController = TextEditingController();
  TextEditingController _beforebedTimeController = TextEditingController();

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Widget _buildSelectableButton(String text) {  //Slectable Button For Take Pill When
    bool isSelected = _selectedTimes.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTimes.remove(text);
          } else {
            _selectedTimes.add(text);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.green[800] : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) { //TIme picker field
  return TextField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.access_time),
      border: const OutlineInputBorder(),
    ),
    onTap: () => _selectTime(context, controller),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text("เพิ่มรายการยา")),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child:
                    _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                //Medicine Name
                decoration: const InputDecoration(
                  labelText: "ชื่อยา",
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                fontFamily: 'ChakraPetch', // Apply your custom font here
                //fontSize: 18, // Optional: customize font size
                //fontWeight: FontWeight.normal, //Optional: customize font weight
              ),
              ),
              const SizedBox(height: 20),
              TextField(
                //Medicine Desc
                decoration: const InputDecoration(
                  labelText: "รายละเอียดยา",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      //Medicine Amount
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "จำนวนรับประทานครั้งละ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    //Medicine Type
                    value: _selectedOption,
                    hint: const Text("เลือก"),
                    items:
                        [
                          "เม็ด",
                          "ช้อนชา",
                          "ช้อนโต๊ะ",
                          "มิลลิลิตร",
                          "กรัม",
                          "ซีซี",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      // START DATE
                      controller: _StartDateController,
                      decoration: const InputDecoration(
                        labelText: "Start Date",
                        filled: true,
                        prefixIcon: Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectStartDate();
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // Space between fields
                  Expanded(
                    child: TextField(
                      // END DATE
                      controller: _EndDateController,
                      decoration: const InputDecoration(
                        labelText: "End Date",
                        filled: true,
                        prefixIcon: Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectEndDate();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                // Take when meals
                "ช่วงเวลาการกิน",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              GridView.count(
                //time picker
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 2.5,
                children: [
                  _buildSelectableButton("ก่อนอาหาร"),
                  _buildSelectableButton("หลังอาหาร"),
                  _buildSelectableButton("เช้า"),
                  _buildSelectableButton("กลางวัน"),
                  _buildSelectableButton("เย็น"),
                  _buildSelectableButton("ก่อนนอน"),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2, // 2 columns
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.5,
                children: [
                  _buildTimePickerField("Morning", _morningTimeController),
                  _buildTimePickerField("Noon", _noonTimeController),
                  _buildTimePickerField("Evening", _eveningTimeController),
                  _buildTimePickerField("Before Bed", _beforebedTimeController),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "ยืนยัน",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "ยกเลิก",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                ],
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
}
