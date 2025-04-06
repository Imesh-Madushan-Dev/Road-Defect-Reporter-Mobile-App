import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../screens/auth/login_page.dart';
import '../utils/constants.dart';

/// AuthWrapper is responsible for deciding which screen to show based on authentication state.
/// It provides a central point for handling authentication state changes and routing.
class AuthWrapper extends StatelessWidget {
  final Widget? childIfAuthenticated;

  /// Constructor that takes an optional child widget to display when authenticated
  /// If not provided, it will route to the home page defined in AppConstants
  const AuthWrapper({Key? key, this.childIfAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the auth controller for state changes
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // Show loading state while determining auth state
        if (authController.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, show the home page or provided child
        if (authController.user != null) {
          if (childIfAuthenticated != null) {
            return childIfAuthenticated!;
          } else {
            // Navigate to home route if no specific child is provided
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }
        // If not authenticated, show the login page
        else {
          return const LoginPage();
        }
      },
    );
  }
}
