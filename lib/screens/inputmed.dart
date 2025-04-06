import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:medicineproject/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final TextEditingController _beforebedTimeController = TextEditingController();
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

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
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
    final Uri url = Uri.parse('http://10.0.2.2:8080/medicines');

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

    if (name.isEmpty || description.isEmpty || startDate.isEmpty || endDate.isEmpty || selectedMealTimes.isEmpty) {
      print("Please fill in all required fields.");
      return;
    }

    final Map<String, dynamic> requestData = {
      "name": name,
      "description": description,
      "quantity": quantity,
      "unit": unit,
      "startDate": startDate,
      "endDate": endDate,
      "mealTimes": selectedMealTimes.join(","),
      "times": selectedTimes.entries.map((e) => "${e.key} at ${e.value}").join(", "),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Medicine saved successfully!");
      } else {
        print("Failed to save data: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
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
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 100, color: Colors.grey),
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
                  )
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
                  items: ["เม็ด", "ช้อนชา", "ช้อนโต๊ะ", "มิลลิลิตร", "กรัม", "ซีซี"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value) => setState(() => _selectedOption = value),
                )
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
                )
              ],
            ),
            const SizedBox(height: 12),
            const Text("ช่วงเวลาการกิน", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("บันทึกข้อมูล"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

