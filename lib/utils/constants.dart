import 'package:flutter/material.dart';

class AppConstants {
  // App general information
  static const String appName = 'Road Defect Reporter';
  static const String appVersion = '1.0.0';

  // Collection names
  static const String usersCollection = 'users';
  static const String defectsCollection = 'defects';

  // Defect Status Constants
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusRejected = 'Rejected';

  static List<String> getAllStatuses() => [
    statusPending,
    statusInProgress,
    statusCompleted,
    statusRejected,
  ];

  // Theme colors
  static const Color primaryColor = Colors.indigo;
  static const Color secondaryColor = Colors.indigo;
  static const Color accentColor = Colors.orange;

  // Status colors
  static const Color pendingColor = Colors.orange;
  static const Color inProgressColor = Colors.blue;
  static const Color completedColor = Colors.greenAccent;
  static const Color rejectedColor = Colors.redAccent;

  // Priority colors
  static const Color lowPriorityColor = Colors.greenAccent;
  static const Color mediumPriorityColor = Colors.orangeAccent;
  static const Color highPriorityColor = Colors.redAccent;

  // Asset paths
  static const String appLogoPath = 'assets/images/logo.png';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String reportDefectRoute = '/report-defect';
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String defectDetailsRoute = '/defect-details';

  // Authentication Success Messages
  static const String successRegistration = 'Registration successful!';
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'You have been logged out successfully.';
  static const String successPasswordReset =
      'Password reset email sent. Please check your inbox.';

  // Authentication Error Messages
  static const String errorUserNotFound =
      'No user found with this email address.';
  static const String errorWrongPassword =
      'Incorrect password. Please try again.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorEmailInUse =
      'This email is already in use by another account.';
  static const String errorWeakPassword =
      'Password is too weak. Please use a stronger password.';
  static const String errorNetwork =
      'Network error. Please check your internet connection.';
  static const String errorTooManyRequests =
      'Too many failed attempts. Please try again later.';
  static const String errorOperationNotAllowed =
      'This operation is not allowed.';
  static const String errorAccountExistsWithDifferentCredential =
      'An account already exists with the same email but different sign-in credentials.';

  // General Error messages
  static const String errorGettingLocation =
      'Could not get your location. Please enable location services.';
  static const String errorUploadingImages =
      'Error uploading images. Please try again.';
  static const String errorSubmittingReport =
      'Error submitting report. Please try again.';
  static const String errorNoImages =
      'Please add at least one image of the defect.';
  static const String errorNotLoggedIn =
      'You must be logged in to use this feature.';

  // Success messages
  static const String successReportSubmitted =
      'Your defect report has been submitted successfully.';
  static const String successStatusUpdated =
      'Status has been updated successfully.';

  // Form validation messages
  static const String validationFieldRequired = 'This field is required';
  static const String validationEmailInvalid =
      'Please enter a valid email address';
  static const String validationPasswordTooShort =
      'Password must be at least 6 characters';
  static const String validationPasswordsDoNotMatch = 'Passwords do not match';
}
