import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/defect_model.dart';

class DefectService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  DefectService() {
    // Enable persistence for offline capabilities
    _database.setPersistenceEnabled(true);
    // Keep defects synced
    _database.ref().child('defects').keepSynced(true);
  }

  // Upload images to Firebase Storage
  Future<List<String>> uploadImages(List<File> images, String userId) async {
    List<String> imageUrls = [];

    for (File image in images) {
      String imageName = '${_uuid.v4()}.jpg';
      Reference storageRef = _storage.ref().child(
        'defect_images/$userId/$imageName',
      );

      try {
        await storageRef.putFile(image);
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  // Create a new defect report
  Future<String?> createDefectReport({
    required String title,
    required String description,
    required String location,
    String? address,
    required List<String> imageUrls,
    required String userId,
    required PriorityLevel priority,
  }) async {
    try {
      final String defectId = _uuid.v4();
      final DatabaseReference defectRef = _database
          .ref()
          .child('defects')
          .child(defectId);

      final Map<String, dynamic> defectData = {
        'id': defectId,
        'title': title,
        'description': description,
        'location': location,
        'address': address,
        'imageUrls': imageUrls,
        'reportedBy': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'Pending',
        'priority': priority.name,
      };

      // Save defect to Realtime Database
      await defectRef.set(defectData);

      // Create a user-defects reference for quick user-specific queries
      await _database
          .ref()
          .child('user-defects')
          .child(userId)
          .child(defectId)
          .set(true);

      print('Defect created successfully with ID: $defectId'); // Debug log
      return defectId;
    } catch (e) {
      print('Error creating defect report: $e');
      return null;
    }
  }

  // Get all defects
  Stream<List<DefectModel>> getAllDefects() {
    return _database.ref().child('defects').onValue.map((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];

      try {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;
        List<DefectModel> defects = [];

        data.forEach((key, value) {
          try {
            if (value is Map) {
              final Map<String, dynamic> defectData = Map<String, dynamic>.from(
                value,
              );
              defects.add(DefectModel.fromJson(defectData));
            }
          } catch (e) {
            print('Error parsing defect $key: $e');
          }
        });

        // Sort by timestamp descending
        defects.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return defects;
      } catch (e) {
        print('Error processing defects: $e');
        return [];
      }
    });
  }

  // Get defects by user ID
  Stream<List<DefectModel>> getDefectsByUser(String userId) {
    return _database.ref().child('user-defects').child(userId).onValue.asyncMap(
      (event) async {
        if (!event.snapshot.exists || event.snapshot.value == null) return [];

        try {
          final Map<dynamic, dynamic> userDefects =
              event.snapshot.value as Map<dynamic, dynamic>;
          List<DefectModel> defects = [];

          for (String defectId in userDefects.keys) {
            final DataSnapshot defectSnapshot =
                await _database.ref().child('defects').child(defectId).get();

            if (defectSnapshot.exists && defectSnapshot.value != null) {
              try {
                final Map<String, dynamic> defectData =
                    Map<String, dynamic>.from(defectSnapshot.value as Map);
                defects.add(DefectModel.fromJson(defectData));
              } catch (e) {
                print('Error parsing user defect $defectId: $e');
              }
            }
          }

          // Sort by timestamp descending
          defects.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return defects;
        } catch (e) {
          print('Error processing user defects: $e');
          return [];
        }
      },
    );
  }

  // Update defect status (for admins)
  Future<void> updateDefectStatus(String defectId, String status) async {
    try {
      await _database.ref().child('defects').child(defectId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating defect status: $e');
      throw e;
    }
  }
}
