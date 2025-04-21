import 'package:flutter/material.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  // Placeholder data (same as before)
  final String reminderTime = "22:00 น.";
  final String medicineName = "ยาแก้แพ้";
  final String medicineDetails = "กินจนหมด";
  final String dosageInfo = "กินครั้งละ 1 เม็ด";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Change background to match HomeScreen
      backgroundColor: Colors.teal[200],

      appBar: AppBar(
        title: const Text(
          'แจ้งเตือนกินยา',
          // Change title color to black
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // Change AppBar color to match HomeScreen's BottomNav/AppBar
        backgroundColor: Colors.greenAccent,
        elevation: 1,
        // Change back button color to black
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
         ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Reminder Details Card ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              decoration: BoxDecoration(
                // Change card background to white or very light teal for contrast
                color: Colors.white,
                // color: Colors.teal[50], // Alternative light teal
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Darker shadow
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$reminderTime ถึงเวลากินยา',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // Change text color to a darker teal or black
                      color: Colors.teal[800],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Use darker text colors for details
                  _buildDetailRow('ชื่อยา:', medicineName),
                  const SizedBox(height: 8),
                  _buildDetailRow('รายละเอียด:', medicineDetails),
                  const SizedBox(height: 8),
                  _buildDetailRow('กินครั้งละ:', dosageInfo),
                ],
              ),
            ),
            // --- End Reminder Details Card ---

            const SizedBox(height: 40),

            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // OK Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("OK button pressed");
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      // Keep a strong teal color
                      backgroundColor: Colors.teal[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'ตกลง', // OK
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Postpone Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("Postpone button pressed");
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      // Change postpone color - maybe a grey or secondary color
                      backgroundColor: Colors.blueGrey[400],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'เลื่อนไปก่อน', // Postpone
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // --- End Action Buttons ---
          ],
        ),
      ),
      // No BottomNavigationBar here
    );
  }

  // Helper widget for detail rows (updated text colors)
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            // Use darker grey or black for labels
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              // Use primary black for values
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}