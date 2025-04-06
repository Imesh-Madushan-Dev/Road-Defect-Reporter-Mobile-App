import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/defect_model.dart';

class DefectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

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
      String defectId = _uuid.v4();

      DefectModel defect = DefectModel(
        id: defectId,
        title: title,
        description: description,
        location: location,
        address: address,
        imageUrls: imageUrls,
        reportedBy: userId,
        timestamp: DateTime.now(),
        status: 'Pending',
        priority: priority,
      );

      // Save defect to Firestore
      await _firestore.collection('defects').doc(defectId).set(defect.toJson());

      // Don't update user's report list since reportIds field was removed
      // await _firestore.collection('users').doc(userId).update({
      //   'reportIds': FieldValue.arrayUnion([defectId]),
      // });

      return defectId;
    } catch (e) {
      print('Error creating defect report: $e');
      return null;
    }
  }

  // Get all defects
  Stream<List<DefectModel>> getAllDefects() {
    return _firestore
        .collection('defects')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DefectModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  // Get defects by user ID
  Stream<List<DefectModel>> getDefectsByUser(String userId) {
    return _firestore
        .collection('defects')
        .where('reportedBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DefectModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  // Update defect status (for admins)
  Future<void> updateDefectStatus(String defectId, String status) async {
    await _firestore.collection('defects').doc(defectId).update({
      'status': status,
    });
  }
}
