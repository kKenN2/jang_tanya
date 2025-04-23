// --- CORRECTED reminder.dart ---

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For delete action
import 'package:medicineproject/notificationHelper.dart'; // For snooze action
import 'dart:convert'; // For payload encoding if needed for snooze


class ReminderPage extends StatefulWidget {
  final String medicineId;
  final String medicineName;
  final String description;
  final String quantity;
  final String unit; // Added unit
  final int notificationId; // Original notification ID for cancelling/snoozing

  const ReminderPage({
    super.key,
    required this.medicineId,
    required this.medicineName,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.notificationId,
  });

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool _isDeleting = false;
  bool _isSnoozing = false;

  // --- Action for "OK" (ตกลง) Button ---
  Future<void> _handleOkAction() async {
    if (_isDeleting) return; // Prevent double taps

    setState(() {
      _isDeleting = true; // Show loading/disable button
    });

    print('OK Action: Attempting to delete medicine ID: ${widget.medicineId}');

    // --- Reusing Delete Logic ---
    final url = Uri.parse('http://10.0.2.2:8080/medicines/${widget.medicineId}');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      print('Delete Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Medicine ${widget.medicineId} deleted successfully via reminder page.');
        // Cancel the original notification just in case (might already be cleared)
        await NotificationHelper.cancelNotification(widget.notificationId);
        if (!mounted) return; // Check if widget is still alive
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("ยืนยันการกินยา '${widget.medicineName}' และลบข้อมูลแล้ว")),
         );
        Navigator.of(context).pop(); // Close the reminder page
        // NOTE: HomeScreen won't automatically refresh. Might need a callback or state management.
      } else {
        print('Failed to delete medicine ${widget.medicineId}: ${response.statusCode} ${response.body}');
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("ลบข้อมูลไม่สำเร็จ: ${response.statusCode}")),
         );
      }
    } catch (e) {
      print('Error deleting medicine ${widget.medicineId}: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    } finally {
       if (mounted) {
         setState(() {
           _isDeleting = false; // Re-enable button
         });
       }
    }
    // --- End Delete Logic ---
  }

  // --- Action for "Postpone" (เลื่อนไปก่อน) Button ---
  Future<void> _handlePostponeAction() async {
     if (_isSnoozing) return;

     setState(() {_isSnoozing = true;});
     print('Postpone Action: Snoozing notification ID: ${widget.notificationId}');

      // 1. Cancel the original repeating notification for this time slot
      //    (We assume the ID passed is for the specific time slot)
      //    Note: This cancels future daily repeats as well for this specific notificationId.
      //    A more complex system might only want to acknowledge today's.
      await NotificationHelper.cancelNotification(widget.notificationId);

      // 2. Schedule a new one-time notification for 15 minutes later
      //    We need to re-create the payload to pass necessary info if the snoozed notification is tapped
       final String payload = jsonEncode({
            'id': widget.medicineId,
            'name': widget.medicineName,
            'description': widget.description,
            'quantity': widget.quantity,
            'unit': widget.unit,
            'notificationId': widget.notificationId, // Keep original ID reference if needed
        });

      await NotificationHelper.scheduleSnoozeNotification(
          notificationId: widget.notificationId, // Re-use ID to replace original
          medicineName: widget.medicineName,
          quantity: widget.quantity,
          unit: widget.unit,
          payload: payload,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("เลื่อนการแจ้งเตือน '${widget.medicineName}' ไปอีก 15 นาที")),
      );
      Navigator.of(context).pop(); // Close the reminder page

      // No need to set _isSnoozing back to false as the page is popped
  }


  @override
  Widget build(BuildContext context) {
    // Combine quantity and unit for display
    String dosageInfo = "${widget.quantity} ${widget.unit ?? ''}".trim();

    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: const Text('แจ้งเตือนกินยา', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.greenAccent,
        elevation: 1,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
         ),
         automaticallyImplyLeading: false, // Don't show default back if using custom leading
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2), ), ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display the current time perhaps? Or the intended time?
                  // For now, keeping the structure simple
                   Text(
                    // Use actual medicine name here
                    'ถึงเวลากินยา ${widget.medicineName}',
                    textAlign: TextAlign.center,
                    style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[800], ),
                  ),
                  const SizedBox(height: 25),
                  _buildDetailRow('ชื่อยา:', widget.medicineName), // Use widget data
                  const SizedBox(height: 8),
                  _buildDetailRow('รายละเอียด:', widget.description), // Use widget data
                  const SizedBox(height: 8),
                  _buildDetailRow('กินครั้งละ:', dosageInfo), // Use combined quantity/unit
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    // Disable button while action is in progress
                    onPressed: _isDeleting || _isSnoozing ? null : _handleOkAction,
                    style: ElevatedButton.styleFrom( backgroundColor: Colors.teal[600], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),), elevation: 2, ),
                    child: _isDeleting
                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                         : const Text('ตกลง', style: TextStyle(fontSize: 16, color: Colors.white), ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                     // Disable button while action is in progress
                    onPressed: _isDeleting || _isSnoozing ? null : _handlePostponeAction,
                    style: ElevatedButton.styleFrom( backgroundColor: Colors.blueGrey[400], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),), elevation: 2, ),
                     child: _isSnoozing
                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                         : const Text('เลื่อนไปก่อน', style: TextStyle(fontSize: 16, color: Colors.white), ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    // ... (same helper function as before) ...
     return Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( '$label ', style: TextStyle( fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54, ), ), Expanded( child: Text( value, style: const TextStyle( fontSize: 16, color: Colors.black87, ), ), ), ], );
  }
}