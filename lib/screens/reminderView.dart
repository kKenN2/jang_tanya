// --- reminderView.dart (with Image Display Added) ---

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// IMPORTANT: Ensure these functions are accessible. Move them to a shared file if needed.
import 'package:medicineproject/main.dart' show Medicine, fetchMedicines, parseMedicineTimes; // Ensure Medicine model includes imageUrl
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
  List<UpcomingReminderInfo> _upcomingReminders = [];
  Timer? _timer;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeTimezone();
    _findUpcomingReminders();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) { _findUpcomingReminders(); } else { timer.cancel(); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _initializeTimezone() async {
    try { tz.initializeTimeZones(); tz.setLocalLocation(tz.getLocation('Asia/Bangkok')); } catch (e) { print("Error setting timezone: $e"); }
  }

  Future<void> _findUpcomingReminders() async {
     if (!_isLoading && mounted) { setState(() { _isLoading = true; _errorMessage = ''; }); }
     else if (!mounted) return;

    try {
      final List<Medicine> allMedicines = await fetchMedicines();
      List<UpcomingReminderInfo> foundReminders = [];
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime limit = now.add(const Duration(hours: 24));

      for (final medicine in allMedicines) {
        final List<TimeOfDay> times = parseMedicineTimes(medicine.times);
        for (final timeOfDay in times) {
          tz.TZDateTime scheduledDate = tz.TZDateTime( tz.local, now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
          if (scheduledDate.isBefore(now)) { scheduledDate = scheduledDate.add(const Duration(days: 1)); }

          if (scheduledDate.isAfter(now) && scheduledDate.isBefore(limit)) {
            foundReminders.add(UpcomingReminderInfo( medicine: medicine, scheduledTime: scheduledDate, ));
          }
        }
      }
      foundReminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      if (mounted) { setState(() { _upcomingReminders = foundReminders; _isLoading = false; _errorMessage = ''; }); }
    } catch (e) { /* ... error handling ... */ print("Error finding upcoming reminders: $e"); if (mounted) { setState(() { _isLoading = false; _errorMessage = "เกิดข้อผิดพลาด:\n$e"; _upcomingReminders = []; }); } }
  }

  String _formatTimeDifference(DateTime scheduledTime) {
     final now = DateTime.now(); final difference = scheduledTime.difference(now); String remainingText;
     if (difference.isNegative && difference.inMinutes.abs() < 5) { remainingText = "ถึงเวลาแล้ว!"; } else if (difference.isNegative) { remainingText = "ผ่านไปแล้ว"; } else if (difference.inSeconds < 60) { remainingText = "ในอีก ${difference.inSeconds} วินาที"; } else if (difference.inMinutes < 60) { remainingText = "ในอีก ${difference.inMinutes} นาที"; } else if (difference.inHours < 24) { final h = difference.inHours; final m = difference.inMinutes % 60; remainingText = "ในอีก $h ชั่วโมง${m > 0 ? ' $m นาที' : ''}"; } else { remainingText = "ในอีก ${difference.inDays} วัน"; } return remainingText.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar( /* ... AppBar ... */ title: const Text('รายการยาที่ต้องกิน', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.greenAccent, elevation: 1, leading: IconButton( icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop(), ), automaticallyImplyLeading: false,),
      body: RefreshIndicator(
         onRefresh: _findUpcomingReminders,
         child: _isLoading
           ? const Center(child: CircularProgressIndicator())
           : _errorMessage.isNotEmpty
               ? ListView( children: [ Padding( padding: const EdgeInsets.all(32.0), child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[800]))) ], )
               : _upcomingReminders.isEmpty
                   ? ListView( children: const [ Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 50.0), child: Text("ไม่มียาที่ต้องกินใน 24 ชั่วโมงข้างหน้า"))) ], )
                   : ListView.builder(
                       padding: const EdgeInsets.all(15.0),
                       itemCount: _upcomingReminders.length,
                       itemBuilder: (context, index) {
                           final reminderInfo = _upcomingReminders[index];
                           return _buildReminderCard(reminderInfo.medicine, reminderInfo.scheduledTime);
                       },
                     ),
       ),
    );
  }

  // --- Reusable Widget for the Reminder Card (MODIFIED to include Image) ---
  Widget _buildReminderCard(Medicine medicine, DateTime scheduledTime) {
     String dosageInfo = "${medicine.quantity} ${medicine.unit ?? ''}".trim();
     if (dosageInfo.isEmpty) dosageInfo = 'ตามที่ระบุ';

     String timeDifference = _formatTimeDifference(scheduledTime);
     String formattedScheduledTime = DateFormat('HH:mm น.').format(scheduledTime);

     return Container(
       margin: const EdgeInsets.only(bottom: 15),
       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
       decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15.0), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2), ), ], ),
       child: Column( // Use Column to stack Image above Text
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
            // --- ADDED IMAGE DISPLAY ---
            if (medicine.imageUrl.isNotEmpty) // Check if there is an image URL
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0), // Add space below image
                child: Center( // Center the image
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                         // Construct URL to fetch image from backend
                         'http://10.0.2.2:8080/medicines/${medicine.id}/image',
                         height: 150, // Adjust height as needed
                         width: double.infinity, // Take available width
                         fit: BoxFit.contain, // Or BoxFit.cover
                         loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container( // Placeholder while loading
                               height: 150,
                               alignment: Alignment.center,
                               child: CircularProgressIndicator(
                                   value: progress.expectedTotalBytes != null
                                       ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                       : null,
                               ),
                            );
                         },
                         errorBuilder: (context, error, stackTrace) {
                             print("Error loading image for ${medicine.name}: $error");
                             return Container( // Placeholder on error
                                height: 150,
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 50),
                             );
                         },
                      ),
                  ),
                ),
              ),
            // --- END IMAGE DISPLAY ---

           Text(
             'ถึงเวลากินยา $timeDifference ($formattedScheduledTime)',
             textAlign: TextAlign.center,
             style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800], ),
           ),
           const SizedBox(height: 15),
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
    // ... same helper function ...
    return Padding( padding: const EdgeInsets.symmetric(vertical: 2.0), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( '$label ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54,), ), Expanded( child: Text( value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 16, color: Colors.black87,), ), ), ], ), );
   }
} // End State