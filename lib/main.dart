import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'controllers/auth_controller.dart';
import 'controllers/defect_controller.dart';
import 'controllers/admin_controller.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/defects/defect_list_view.dart';
import 'screens/defects/report_defect_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/profile_page.dart';
import 'utils/constants.dart';
import 'wrappers/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DefectController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          AppConstants.loginRoute: (context) => const LoginPage(),
          AppConstants.registerRoute: (context) => const RegisterPage(),
          AppConstants.homeRoute: (context) => const HomePage(),
          AppConstants.reportDefectRoute: (context) => const ReportDefectPage(),
          AppConstants.adminDashboardRoute: (context) => const AdminDashboard(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final theme = Theme.of(context);

    // Check authentication using the AuthWrapper
    if (authController.user == null) {
      return const AuthWrapper();
    }

    // Define pages for bottom nav
    final List<Widget> pages = [
      const DefectListView(),
      const ReportDefectPage(),
      if (authController.userData?['isAdmin'] == true) const AdminDashboard(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SalomonBottomBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                // Reports item
                SalomonBottomBarItem(
                  icon: const Icon(Icons.list_alt_rounded),
                  title: const Text('Reports'),
                  selectedColor: theme.colorScheme.primary,
                  unselectedColor: Colors.grey[600],
                ),

                // Add Report item
                SalomonBottomBarItem(
                  icon: const Icon(Icons.add_circle_outline),
                  title: const Text('Report'),
                  selectedColor: theme.colorScheme.primary,
                  unselectedColor: Colors.grey[600],
                ),

                // Admin Dashboard item (if user admin)
                if (authController.userData?['isAdmin'] == true)
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    title: const Text('Admin'),
                    selectedColor: theme.colorScheme.primary,
                    unselectedColor: Colors.grey[600],
                  ),

                // Profile item
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  selectedColor: theme.colorScheme.primary,
                  unselectedColor: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
