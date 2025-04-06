import 'package:flutter/material.dart';
import '../models/defect_model.dart';
import '../services/defect_service.dart';

class AdminController with ChangeNotifier {
  final DefectService _defectService = DefectService();

  List<DefectModel> _allDefects = [];
  List<DefectModel> _filteredDefects = [];
  String? _filterStatus;
  PriorityLevel? _filterPriority;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DefectModel> get allDefects => _allDefects;
  List<DefectModel> get filteredDefects =>
      _filteredDefects.isEmpty ? _allDefects : _filteredDefects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;
  PriorityLevel? get filterPriority => _filterPriority;

  // Constructor - load all defects
  AdminController() {
    loadAllDefects();
  }

  // Load all defects
  void loadAllDefects() {
    _isLoading = true;
    notifyListeners();

    _defectService.getAllDefects().listen(
      (defectsList) {
        _allDefects = defectsList;
        _applyFilters(); // Apply any existing filters
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error loading defects: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filter by status
  void filterByStatus(String? status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Filter by priority
  void filterByPriority(PriorityLevel? priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredDefects = _allDefects;

    // Apply status filter if set
    if (_filterStatus != null) {
      _filteredDefects =
          _filteredDefects
              .where((defect) => defect.status == _filterStatus)
              .toList();
    }

    // Apply priority filter if set
    if (_filterPriority != null) {
      _filteredDefects =
          _filteredDefects
              .where((defect) => defect.priority == _filterPriority)
              .toList();
    }
  }

  // Update defect status
  Future<bool> updateDefectStatus(String defectId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _defectService.updateDefectStatus(defectId, status);

      // Update the local list to reflect the change
      int index = _allDefects.indexWhere((defect) => defect.id == defectId);
      if (index != -1) {
        _allDefects[index] = DefectModel(
          id: _allDefects[index].id,
          title: _allDefects[index].title,
          description: _allDefects[index].description,
          location: _allDefects[index].location,
          address: _allDefects[index].address,
          imageUrls: _allDefects[index].imageUrls,
          reportedBy: _allDefects[index].reportedBy,
          timestamp: _allDefects[index].timestamp,
          status: status,
          priority: _allDefects[index].priority,
        );

        _applyFilters();
      }

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

  // Clear all filters
  void clearFilters() {
    _filterStatus = null;
    _filterPriority = null;
    _filteredDefects = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
