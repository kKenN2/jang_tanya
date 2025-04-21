import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Needed for DateFormat
import 'package:medicineproject/screens/inputmed.dart'; // Assuming these screens exist
import 'package:medicineproject/screens/reminder.dart';
import 'package:medicineproject/screens/profile.dart';
import 'package:medicineproject/notificationHelper.dart'; // Your notification helper
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
// For FilteringTextInputFormatter if used elsewhere

// --- Top-Level Function for Parsing Times ---
// Parses the time string like "morning at 7:18 PM, evening at 9:00 PM"
List<TimeOfDay> parseMedicineTimes(String timesString) {
  List<TimeOfDay> parsedTimes = [];
  if (timesString.isEmpty) {
    return parsedTimes;
  }
  // Use locale 'en_US' for reliable AM/PM parsing if needed
  final DateFormat format = DateFormat("h:mm a", "en_US");
  final List<String> timeEntries = timesString.split(',');

  for (String entry in timeEntries) {
    final parts = entry.trim().split(' at ');
    if (parts.length == 2 && parts[1].isNotEmpty) {
      try {
        final String timeStr = parts[1].trim();
        final DateTime parsedDateTime = format.parse(timeStr);
        parsedTimes.add(TimeOfDay.fromDateTime(parsedDateTime));
      } catch (e) {
        print("Error parsing time entry '$entry': $e");
        // Handle error or skip this time
      }
    }
  }
  return parsedTimes;
}
// --- End Top-Level Function ---

// --- Main App Setup ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Consider initializing NotificationHelper here if context isn't strictly needed immediately
  // await NotificationHelper.init(); // Requires modification if context needed later
  runApp(const MyApp());
}

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
        // Consider using one of the fonts defined in pubspec.yaml
        // fontFamily: 'ChakraPetch', // Example
      ),
      home: Builder(
        builder: (context) {
          // Initialize notifications here where context is available
          NotificationHelper.init(context);
          return const HomeScreen();
        },
      ),
      // Define routes if using named navigation
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/input': (context) => const Inputmed(),
      //   '/reminder': (context) => const ReminderPage(),
      //   '/profile': (context) => const ProfilePage(),
      // },
    );
  }
}
// --- End App Setup ---

// --- Medicine Data Model ---
class Medicine {
  final String id; // Unique ID from backend (_id mapped to "id")
  final String name;
  final String description;
  final String mealTimes;
  final String times; // Raw time string, e.g., "morning at 7:18 PM"
  final String quantity; // Use String if backend sends String, use int/double if backend sends number

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.mealTimes,
    required this.times,
    required this.quantity,
  });

  // Factory constructor to create Medicine from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      // Parses the "id" field from JSON (expects String from backend)
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'No Name', // Provide default values
      description: json['description'] ?? '',
      mealTimes: json['mealTimes'] ?? '',
      times: json['times'] ?? '',
      // Adjust parsing based on actual type sent from backend (String or Number)
      quantity: json['quantity']?.toString() ?? '0',
    );
  }
}
// --- End Medicine Data Model ---

// --- Data Fetching Logic ---
Future<List<Medicine>> fetchMedicines() async {
  final url = Uri.parse('http://10.0.2.2:8080/medicines'); // Android Emulator IP for localhost
  print("Fetching medicines from: $url");

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10)); // Add timeout

    // --- Debugging: Print Raw JSON ---
    print("--- Raw JSON Response from /medicines (Status: ${response.statusCode}) ---");
    print(response.body);
    print("----------------------------------------");
    // --- End Debugging ---

    if (response.statusCode == 200) {
      // Decode the response body assuming UTF-8
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Medicine.fromJson(json)).toList();
    } else {
      print("Failed to load medicines. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Failed to load medicines (Status code: ${response.statusCode})');
    }
  } catch (e) {
     print("Error fetching medicines: $e");
     // Rethrow or handle specific errors (e.g., TimeoutException, SocketException)
     throw Exception('Error connecting to server: $e');
  }
}
// --- End Data Fetching Logic ---


// --- Home Screen Widget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Medicine>>? _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _loadDataAndSchedule();
  }

  // Helper to load data and schedule notifications
  void _loadDataAndSchedule() {
    _medicinesFuture = fetchMedicines().then((medicines) {
       _scheduleAllNotifications(medicines); // Schedule after fetching
       return medicines; // Return medicines for the FutureBuilder
    }).catchError((error) {
       print("Error fetching/scheduling in initState: $error");
       // Return an error to FutureBuilder
       // Use a specific type or rethrow the original error
       throw Exception("Failed initial load: $error");
    });
  }


  // Refresh function called by RefreshIndicator and potentially after delete/add
  Future<void> _refreshMedicines() async {
    print("Refreshing medicines list...");
    // Trigger reload and reschedule by resetting the future
    setState(() {
       _loadDataAndSchedule();
    });
    // Optionally wait for it to complete if needed, but FutureBuilder handles loading state
    // await _medicinesFuture;
  }

  // Schedule all notifications based on fetched data
  Future<void> _scheduleAllNotifications(List<Medicine> medicines) async {
      print("Attempting to schedule notifications...");
      await NotificationHelper.cancelAllNotifications(); // Clear old ones first
      int notificationScheduledCount = 0;

      for (final medicine in medicines) {
        if (medicine.id.isEmpty) {
          print("Skipping scheduling for medicine '${medicine.name}' due to empty ID.");
          continue; // Skip if ID is missing (shouldn't happen if backend is correct)
        }

        // Example ID generation (consider improving robustness later)
        int baseId = medicine.id.hashCode.abs() % 100000; // Use modulo to keep it smaller

        List<TimeOfDay> timesToSchedule = parseMedicineTimes(medicine.times); // Use top-level function

        print("Parsed times for ${medicine.name} (ID: ${medicine.id}): $timesToSchedule");

        for (int i = 0; i < timesToSchedule.length; i++) {
            TimeOfDay time = timesToSchedule[i];
            // Ensure unique ID generation logic is robust
            int uniqueNotificationId = (baseId * 10) + i; // Example

           try {
             await NotificationHelper.scheduleSingleMedicineNotification(
              notificationId: uniqueNotificationId,
              medicineName: medicine.name,
              quantity: medicine.quantity, // Pass quantity
              time: time,
            );
            notificationScheduledCount++;
           } catch (e) {
               print("Error scheduling notification $uniqueNotificationId for ${medicine.name}: $e");
               // Consider showing an error message to the user
           }
        }
      }
      print("Attempted to schedule $notificationScheduledCount total notifications.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text(
          'สมศัก จริงดิ', // Replace with actual user name if available
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMedicines,
        child: SingleChildScrollView( // Ensures content is scrollable if list gets long
          physics: const AlwaysScrollableScrollPhysics(), // Allows scrolling even if list is short for refresh
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar( // Placeholder for profile picture
                radius: 45,
                backgroundColor: Colors.teal, // Changed color slightly
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'ยาของฉันวันนี้',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const TimeDisplay(), // Displays current clock time
              const SizedBox(height: 20),
              Padding( // Use Padding instead of Container for consistency
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<Medicine>>(
                  future: _medicinesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          // Show error details for debugging, user-friendly message for release
                          child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลยา:\n${snapshot.error}', textAlign: TextAlign.center),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('ไม่พบข้อมูลยา'),
                        ));
                    } else {
                      // Data loaded successfully
                      return ListView.builder(
                        shrinkWrap: true, // Important inside SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // List shouldn't scroll independently
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final medicine = snapshot.data![index];
                          return MedicineBox(
                              medicine: medicine,
                              // Pass _refreshMedicines so list reloads after delete
                              onDelete: _refreshMedicines
                           );
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.greenAccent,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // Add labels for clarity
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Add Med'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
        onTap: (index) {
           // Consider using a StatefulWidget for the main screen
           // and managing the current index for the body and Nav Bar state.
           // Simple push navigation for now:
          if (index == 0) {
             // Already on home, refresh
             _refreshMedicines();
          } else if (index == 1) {
            // Navigate to Inputmed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Inputmed()),
            ).then((_) {
                // Refresh when coming back from adding potentially
                print("Returned from Inputmed, refreshing...");
                _refreshMedicines();
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReminderPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        // Keep labels visually hidden if desired, but provide them for accessibility
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
// --- End Home Screen ---


// --- Medicine Display Box Widget (Includes Delete) ---
class MedicineBox extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onDelete; // Callback function when delete is successful

  const MedicineBox({
    super.key,
    required this.medicine,
    required this.onDelete, // Make onDelete required
  });

  // --- Function to handle Deletion ---
  Future<void> _deleteMedicine(BuildContext context) async {
    // Ensure ID is not empty before attempting delete
     if (medicine.id.isEmpty) {
       print('Error: Cannot delete medicine "${medicine.name}" with empty ID.');
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("ข้อผิดพลาด: ไม่พบ ID ของยา")),
       );
       return;
     }

    // Build the correct URL using the medicine ID
    final url = Uri.parse('http://10.0.2.2:8080/medicines/${medicine.id}');
    print('Attempting DELETE request to: $url');

    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10)); // Add timeout
      print('Delete Response Status Code: ${response.statusCode}');
      print('Delete Response Body: ${response.body}'); // Print body for debugging

      // Check for successful status codes
      if (response.statusCode == 200 || response.statusCode == 204) { // 200 OK or 204 No Content
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ลบยา '${medicine.name}' แล้ว")), // Medicine deleted
        );
        onDelete(); // Call the callback to refresh the list/reschedule notifications
      } else {
        // Handle specific errors based on status code if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ลบยา '${medicine.name}' ไม่สำเร็จ: ${response.statusCode} ${response.body}")),
        );
      }
    } catch (e) {
      print('Error during delete request for ${medicine.name}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการลบยา: $e")),
      );
    }
  }
 // --- End Delete Function ---

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Slightly reduced elevation
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Adjusted margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Adjusted padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
          children: [
            Icon(Icons.medication_liquid, size: 40, color: Colors.teal[700]), // Changed icon slightly
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Use 'N/A' if name is empty
                    'ชื่อยา: ${medicine.name.isNotEmpty ? medicine.name : 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  if (medicine.description.isNotEmpty) // Only show if not empty
                    Text('สรรพคุณ: ${medicine.description}'),
                  if (medicine.times.isNotEmpty) // Only show if not empty
                    Text('เวลา: ${medicine.times}'),
                  if (medicine.quantity.isNotEmpty) // Only show if not empty
                    Text('จำนวน: ${medicine.quantity}'),
                ],
              ),
            ),
            // --- Delete Button ---
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent), // Changed icon
              iconSize: 24, // Adjusted size
              visualDensity: VisualDensity.compact, // Make it less bulky
              padding: EdgeInsets.zero, // Remove extra padding
              tooltip: 'Delete ${medicine.name}',
              onPressed: () {
                   // Confirmation Dialog before deleting
                   showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('ยืนยันการลบ'),
                        content: Text('คุณต้องการลบยา "${medicine.name}" ใช่หรือไม่?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('ยกเลิก'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close the dialog
                              _deleteMedicine(context); // Proceed with delete
                            },
                          ),
                        ],
                      );
                    },
                  );
              },
            ),
             // --- End Delete Button ---
          ],
        ),
      ),
    );
  }
}
// --- End Medicine Box ---


// --- Clock Display Widget ---
class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize time immediately
    _currentTime = _formatDateTime(DateTime.now());
    // Start timer
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
      // Ensure locale is set if needed, e.g., 'th_TH' for Thai buddhist calendar/locale
      // Requires intl initialization for specific locales
     return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  void _updateTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _currentTime = _formatDateTime(DateTime.now());
        });
      } else {
         timer.cancel(); // Stop timer if widget is disposed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: const TextStyle(fontSize: 16, color: Colors.teal), // Consider slightly darker color
    );
  }
}
// --- End Clock Display ---