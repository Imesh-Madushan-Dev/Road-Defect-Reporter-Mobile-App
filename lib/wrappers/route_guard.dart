import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../utils/constants.dart';

/// RouteGuard is a wrapper widget that protects routes based on authentication
/// and optional role requirements.
class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  /// Constructor that takes the child widget to display if authentication
  /// and role requirements are met.
  ///
  /// The [requireAdmin] parameter, if set to true, will check if the user
  /// has admin privileges before allowing access.
  const RouteGuard({super.key, required this.child, this.requireAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // If still loading auth state, show loading indicator
        if (authController.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not authenticated, redirect to login
        if (authController.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If admin required but user is not admin, show unauthorized message
        if (requireAdmin && authController.userData?['isAdmin'] != true) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Unauthorized'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Unauthorized Access',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You don\'t have permission to access this page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(
                          context,
                          AppConstants.homeRoute,
                        ),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          );
        }

        // All checks passed, show the protected content
        return child;
      },
    );
  }
}
