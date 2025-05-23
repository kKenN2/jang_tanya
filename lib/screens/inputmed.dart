import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:medicineproject/screens/profile.dart';
import 'package:medicineproject/screens/reminderView.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:medicineproject/main.dart';

class Inputmed extends StatefulWidget {
  const Inputmed({super.key});

  @override
  State<Inputmed> createState() => _InputmedState();
}

class _InputmedState extends State<Inputmed> {
  File? _selectedImage;
  String? _selectedOption;
  final Set<String> _selectedTimes = {};

  final TextEditingController _StartDateController = TextEditingController();
  final TextEditingController _EndDateController = TextEditingController();
  final TextEditingController _morningTimeController = TextEditingController();
  final TextEditingController _noonTimeController = TextEditingController();
  final TextEditingController _eveningTimeController = TextEditingController();
  final TextEditingController _beforebedTimeController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

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
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    setState(() {
      _StartDateController.text = picked.toString().split(" ")[0];
    });
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    setState(() {
      _EndDateController.text = picked.toString().split(" ")[0];
    });
  }

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

  Future<void> _submitData() async {
    final Uri url = Uri.parse('http://10.0.2.2:8080/medicines/upload');

    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final String unit = _selectedOption ?? "unit";
    final String startDate = _StartDateController.text.trim();
    final String endDate = _EndDateController.text.trim();
    List<String> selectedMealTimes = _selectedTimes.toList();

    Map<String, String> selectedTimes = {
      "morning": _morningTimeController.text,
      "noon": _noonTimeController.text,
      "evening": _eveningTimeController.text,
      "beforeBed": _beforebedTimeController.text,
    };

    if (name.isEmpty ||
        description.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        selectedMealTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    try {
      // วิธีที่ 1: ใช้ MultipartRequest
      var request = http.MultipartRequest('POST', url);

      // สร้าง Object สำหรับข้อมูลยา
      Map<String, dynamic> medicineData = {
        'name': name,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'startDate': startDate,
        'endDate': endDate,
        'mealTimes': selectedMealTimes.join(","),
        'times': selectedTimes.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => "${e.key} at ${e.value}")
            .join(", "),
      };

      // เพิ่ม field medicine เป็น JSON string
      request.fields['medicine'] = jsonEncode(medicineData);

      // ต้องแน่ใจว่า Content-Type ถูกตั้งค่าเป็น application/json สำหรับ medicine field
      request.headers['Content-Type'] = 'multipart/form-data';

      // เพิ่มไฟล์รูปภาพ (ถ้ามี)
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedImage!.path),
        );
      }

      var response = await request.send();

      // ทางเลือกที่ 2: ใช้ Dio package (ถ้าคุณต้องการใช้)
      // แนะนำให้เพิ่ม: import 'package:dio/dio.dart';
      /*
    final dio = Dio();
    FormData formData = FormData.fromMap({
      'medicine': jsonEncode(medicineData),
      if (_selectedImage != null)
        'file': await MultipartFile.fromFile(_selectedImage!.path),
    });

    final response = await dio.post(
      'http://10.0.2.2:8080/medicines/upload',
      data: formData,
    );
    */

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        print("Response: $respStr"); // debug

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("สำเร็จ"),
                content: const Text("บันทึกข้อมูลสำเร็จ"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("ตกลง"),
                  ),
                ],
              ),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print("Error Response: $responseBody"); // debug
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("ผิดพลาด"),
                content: Text(
                  "ไม่สามารถบันทึกข้อมูลได้: ${response.statusCode}\n$responseBody",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("ตกลง"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print("Exception: $e"); // debug
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("ข้อผิดพลาด"),
              content: Text("เกิดข้อผิดพลาด: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("ตกลง"),
                ),
              ],
            ),
      );
    }
  }

  Widget _buildSelectableButton(String text) {
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
          color: isSelected ? Colors.green[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.green[800] : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.check, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Center(
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อยา",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "รายละเอียด",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "จำนวน",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedOption,
                  hint: const Text("เลือกหน่วย"),
                  items:
                      [
                            "เม็ด",
                            "ช้อนชา",
                            "ช้อนโต๊ะ",
                            "มิลลิลิตร",
                            "กรัม",
                            "ซีซี",
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedOption = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _StartDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "วันที่เริ่ม",
                      border: OutlineInputBorder(),
                    ),
                    onTap: _selectStartDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _EndDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "วันที่สิ้นสุด",
                      border: OutlineInputBorder(),
                    ),
                    onTap: _selectEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "ช่วงเวลาการกิน",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
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
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.5,
              children: [
                _buildTimePickerField("เช้า", _morningTimeController),
                _buildTimePickerField("กลางวัน", _noonTimeController),
                _buildTimePickerField("เย็น", _eveningTimeController),
                _buildTimePickerField("ก่อนนอน", _beforebedTimeController),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("บันทึกข้อมูล"),
                  ),
                ),
              ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Add Med',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Inputmed()),
            );
          } else if (index == 2) {
            /* Needs data */
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReminderViewPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
