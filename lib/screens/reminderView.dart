import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// IMPORTANT: Ensure these functions are accessible. Move them to a shared file if needed.
import 'package:medicineproject/main.dart' show Medicine, fetchMedicines, parseMedicineTimes;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// --- Helper Class to hold upcoming reminder info ---
class UpcomingReminderInfo {
  final Medicine medicine;
  final DateTime scheduledTime;

  UpcomingReminderInfo({required this.medicine, required this.scheduledTime});
}
// --- End Helper Class ---


class ReminderViewPage extends StatefulWidget {
  const ReminderViewPage({super.key});

  @override
  State<ReminderViewPage> createState() => _ReminderViewPageState();
}

class _ReminderViewPageState extends State<ReminderViewPage> {
  // --- State Variables Changed ---
  List<UpcomingReminderInfo> _upcomingReminders = []; // Store a LIST of reminders
  Timer? _timer;
  bool _isLoading = true;
  String _errorMessage = '';
  // --- End State Variables ---

  @override
  void initState() {
    super.initState();
    _initializeTimezone();
    _findUpcomingReminders(); // Initial fetch
    // Timer to refresh the list periodically (e.g., every 5 minutes)
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _findUpcomingReminders();
      } else {
        timer.cancel();
      }
    });
  }

  // Separate async init for timezone if needed elsewhere too
  Future<void> _initializeTimezone() async {
     try {
       tz.initializeTimeZones();
       tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
     } catch (e) { print("Error setting timezone location: $e."); }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Find ALL upcoming medicine doses within the next 24 hours ---
  Future<void> _findUpcomingReminders() async {
    if (!mounted) return;
    // Set loading state only if not already loading (prevents flicker on timer refresh)
    if (!_isLoading) {
        setState(() { _isLoading = true; _errorMessage = ''; });
    }

    try {
      final List<Medicine> allMedicines = await fetchMedicines();
      List<UpcomingReminderInfo> foundReminders = [];
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime limit = now.add(const Duration(hours: 24)); // 24 hour window

      for (final medicine in allMedicines) {
        final List<TimeOfDay> times = parseMedicineTimes(medicine.times);
        for (final timeOfDay in times) {
          // Calculate the next occurrence time
          tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          // Check if it falls within the next 24 hours
          if (scheduledDate.isAfter(now) && scheduledDate.isBefore(limit)) {
            foundReminders.add(UpcomingReminderInfo(
              medicine: medicine,
              scheduledTime: scheduledDate, // Store the calculated DateTime
            ));
          }
        }
      }

      // Sort the found reminders by time
      foundReminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      if (mounted) {
         setState(() {
           _upcomingReminders = foundReminders; // Update the list
           _isLoading = false;
           _errorMessage = ''; // Clear any previous error
         });
      }

    } catch (e) {
      print("Error finding upcoming reminders: $e");
      if (mounted) {
        setState(() {
           _isLoading = false;
           _errorMessage = "เกิดข้อผิดพลาด:\n$e";
           _upcomingReminders = []; // Clear list on error
        });
      }
    }
  }


  // --- Helper Function to Format Time Difference ---
  String _formatTimeDifference(DateTime scheduledTime) {
      final now = DateTime.now();
      final difference = scheduledTime.difference(now);
      String remainingText;

      if (difference.isNegative && difference.inMinutes.abs() < 5) { remainingText = "ถึงเวลาแล้ว!"; }
      else if (difference.isNegative) { remainingText = "ผ่านไปแล้ว"; } // Indicate if it's slightly past
      else if (difference.inSeconds < 60) { remainingText = "ในอีก ${difference.inSeconds} วินาที"; }
      else if (difference.inMinutes < 60) { remainingText = "ในอีก ${difference.inMinutes} นาที"; }
      else if (difference.inHours < 24) { final hours = difference.inHours; final minutes = difference.inMinutes % 60; remainingText = "ในอีก $hours ชั่วโมง${minutes > 0 ? ' $minutes นาที' : ''}"; }
      else { remainingText = "ในอีก ${difference.inDays} วัน"; } // Should not happen with 24h limit, but fallback

      return remainingText.trim();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: const Text('รายการยาที่ต้องกิน', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Updated Title
        backgroundColor: Colors.greenAccent,
        elevation: 1,
        leading: IconButton( icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop(), ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
         onRefresh: _findUpcomingReminders,
         child: _isLoading
           ? const Center(child: CircularProgressIndicator()) // Show loading indicator fullscreen
           : _errorMessage.isNotEmpty
               ? ListView( // Allow refreshing even for error message
                   children: [ Padding( padding: const EdgeInsets.all(32.0), child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[800]))) ],
                 )
               : _upcomingReminders.isEmpty
                   ? ListView( // Allow refreshing when list is empty
                       children: const [ Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 50.0), child: Text("ไม่มียาที่ต้องกินใน 24 ชั่วโมงข้างหน้า"))) ],
                     )
                   : ListView.builder( // Use ListView.builder for the list of cards
                       padding: const EdgeInsets.all(15.0), // Padding for the whole list
                       itemCount: _upcomingReminders.length,
                       itemBuilder: (context, index) {
                           final reminderInfo = _upcomingReminders[index];
                           // Build a card for each reminder
                           return _buildReminderCard(reminderInfo.medicine, reminderInfo.scheduledTime);
                       },
                     ),
       ),
    );
  }

  // --- Reusable Widget for the Reminder Card ---
  Widget _buildReminderCard(Medicine medicine, DateTime scheduledTime) {
     String dosageInfo = "${medicine.quantity} ${medicine.unit ?? ''}".trim();
     if (dosageInfo.isEmpty) dosageInfo = 'ตามที่ระบุ';

     String timeDifference = _formatTimeDifference(scheduledTime);
     String formattedScheduledTime = DateFormat('HH:mm น.').format(scheduledTime); // Format time like 21:45 น.

     return Container(
       margin: const EdgeInsets.only(bottom: 15), // Space between cards
       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
       decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15.0), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2), ), ], ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Text(
             // Updated text using time difference
             'ถึงเวลากินยา $timeDifference ($formattedScheduledTime)',
             textAlign: TextAlign.center,
             style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800], ), // Adjusted font size
           ),
           const SizedBox(height: 15), // Reduced space
           _buildDetailRow('ชื่อยา:', medicine.name),
           const SizedBox(height: 5),
           _buildDetailRow('รายละเอียด:', medicine.description),
           const SizedBox(height: 5),
           _buildDetailRow('กินครั้งละ:', dosageInfo),
         ],
       ),
     );
  }
  // --- End Reusable Widget ---

  Widget _buildDetailRow(String label, String value) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 2.0), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( '$label ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54,), ), Expanded( child: Text( value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 16, color: Colors.black87,), ), ), ], ), );
   }
} // End State