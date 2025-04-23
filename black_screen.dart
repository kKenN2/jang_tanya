/*future: _medicinesFuture,
    builder: (context, snapshot) {
      // --- ADDED LOGS ---
      print("FutureBuilder state: ${snapshot.connectionState}");
      // --- END LOGS ---

      if (snapshot.connectionState == ConnectionState.waiting) {
        // --- ADDED LOGS ---
        print("FutureBuilder showing: Waiting Indicator");
        // --- END LOGS ---
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (snapshot.hasError) {
         // --- ADDED LOGS ---
         print("FutureBuilder showing: Error - ${snapshot.error}");
         // --- END LOGS ---
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading medicines:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
         // --- ADDED LOGS ---
         print("FutureBuilder showing: No Data Text");
         // --- END LOGS ---
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No medicine data found.'),
          ),
        );
      } else {
         // --- ADDED LOGS ---
         print("FutureBuilder showing: ListView with ${snapshot.data!.length} items");
         // --- END LOGS ---
        // Data loaded successfully
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final medicine = snapshot.data![index];
            return MedicineBox(
              medicine: medicine,
              onDelete: _refreshMedicines, // Ensure _refreshMedicines is accessible here
            );
          },
        );
      }
    },
  ),
) // End Padding*/