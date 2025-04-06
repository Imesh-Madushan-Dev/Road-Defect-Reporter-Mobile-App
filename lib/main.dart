import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/defect_controller.dart';
import 'controllers/admin_controller.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/defects/defect_list_view.dart';
import 'screens/defects/report_defect_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'utils/constants.dart';

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
          ),
          useMaterial3: true,
        ),
        initialRoute: AppConstants.loginRoute,
        routes: {
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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    // If not logged in, redirect to login
    if (authController.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Define pages for bottom nav
    final List<Widget> pages = [
      const DefectListView(), // My Reports
      const ReportDefectPage(), // Report a Defect
      if (authController.userData?['isAdmin'] == true)
        const AdminDashboard(), // Admin Dashboard (if admin)
      _buildProfileView(authController), // Profile
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          if (authController.userData?['isAdmin'] == true)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProfileView(AuthController authController) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              authController.userData?['name'] ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              authController.user?.email ?? 'Email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (authController.userData?['isAdmin'] == true)
              const Chip(
                label: Text('Admin'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () async {
                await authController.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppConstants.loginRoute,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
