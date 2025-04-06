// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../controllers/auth_controller.dart';
// import '../../utils/validators.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({Key? key}) : super(key: key);

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeIn,
//       ),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _resetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       FocusScope.of(context).unfocus();

//       final authController = Provider.of<AuthController>(
//         context,
//         listen: false,
//       );

//       final success = await authController.(
//         _emailController.text.trim(),
//       );

//       if (success && mounted) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Reset Email Sent'),
//             content: const Text(
//               'A password reset link has been sent to your email. Please check your inbox and follow the instructions.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authController = Provider.of<AuthController>(context);
//     final theme = Theme.of(context);
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Forgot Password',
//           style: TextStyle(
//             color: theme.colorScheme.primary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: GestureDetector(
//             onTap: () => FocusScope.of(context).unfocus(),
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.05),
                    
//                     // App Logo
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.lock_reset_rounded,
//                         size: 60,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Title
//                     Text(
//                       'Reset Your Password',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
                    
//                     Text(
//                       'Enter your email address to receive a password reset link',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
                    
//                     // Error message
//                     if (authController.error != null)
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.red.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.error_outline, color: Colors.red.shade700),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 authController.error!,
//                                 style: TextStyle(color: Colors.red.shade700),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close, size: 16),
//                               onPressed: () => authController.clearError(),
//                               color: Colors.red.shade700,
//                             ),
//                           ],
//                         ),
//                       ),
                    
//                     // Success message
//                     if (authController.successMessage != null)
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade50,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.green.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.check_circle_outline, color: Colors.green.shade700),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 authController.successMessage!,
//                                 style: TextStyle(color: Colors.green.shade700),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close, size: 16),
//                               onPressed: () => authController.clearSuccessMessage(),
//                               color: Colors.green.shade700,
//                             ),
//                           ],
//                         ),
//                       ),
                    
//                     // Form
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           // Email field
//                           TextFormField(
//                             controller: _emailController,
//                             keyboardType: TextInputType.emailAddress,
//                             style: TextStyle(color: Colors.grey[800]),
//                             decoration: InputDecoration(
//                               labelText: 'Email',
//                               hintText: 'Enter your registered email address',
//                               prefixIcon: const Icon(Icons.email_outlined),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[300]!),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey[300]!),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: theme.colorScheme.primary),
//                               ),
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                             ),
//                             validator: (value) => Validators.validateEmail(value),
//                           ),
                          
//                           const SizedBox(height: 30),
                          
//                           // Reset password button
//                           SizedBox(
//                             height: 50,
//                             child: ElevatedButton(
//                               onPressed: authController.isLoading ? null : _resetPassword,
//                               style: ElevatedButton.styleFrom(
//                                 foregroundColor: Colors.white,
//                                 backgroundColor: theme.colorScheme.primary,
//                                 disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
//                                 disabledForegroundColor: Colors.white70,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: authController.isLoading
//                                   ? const SizedBox(
//                                       width: 24,
//                                       height: 24,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                       ),
//                                     )
//                                   : const Text(
//                                       'SEND RESET LINK',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         letterSpacing: 1.2,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
