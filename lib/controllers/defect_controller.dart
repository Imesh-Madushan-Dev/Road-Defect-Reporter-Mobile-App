import 'dart:io';
import 'package:flutter/material.dart';
import '../models/defect_model.dart';
import '../services/defect_service.dart';
import '../services/location_service.dart';

class DefectController with ChangeNotifier {
  final DefectService _defectService = DefectService();
  final LocationService _locationService = LocationService();

  List<DefectModel> _defects = [];
  List<DefectModel> _userDefects = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DefectModel> get defects => _defects;
  List<DefectModel> get userDefects => _userDefects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all defects (for admin view)
  void loadAllDefects() {
    _defectService.getAllDefects().listen(
      (defectsList) {
        _defects = defectsList;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error loading defects: $e';
        notifyListeners();
      },
    );
  }

  // Load user's defects
  void loadUserDefects(String userId) {
    _defectService
        .getDefectsByUser(userId)
        .listen(
          (defectsList) {
            _userDefects = defectsList;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error loading your defects: $e';
            notifyListeners();
          },
        );
  }

  // Create a new defect report
  Future<bool> createDefectReport({
    required String title,
    required String description,
    required List<File> images,
    required String userId,
    required PriorityLevel priority,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _error =
            'Unable to get your location. Please enable location services.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Convert position to string for storage
      final locationString = _locationService.getLocationString(position);

      // Get address from coordinates
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Upload images to Firebase Storage
      final imageUrls = await _defectService.uploadImages(images, userId);

      if (imageUrls.isEmpty) {
        _error = 'Failed to upload images. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create the defect report
      final defectId = await _defectService.createDefectReport(
        title: title,
        description: description,
        location: locationString,
        address: address,
        imageUrls: imageUrls,
        userId: userId,
        priority: priority,
      );

      _isLoading = false;
      notifyListeners();

      return defectId != null;
    } catch (e) {
      _error = 'Error creating report: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update defect status (for admin)
  Future<bool> updateDefectStatus(String defectId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _defectService.updateDefectStatus(defectId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
