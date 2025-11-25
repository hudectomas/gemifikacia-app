import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'services/database_service.dart' if (dart.library.html) 'services/database_service_web.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/stamp_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/child/child_home_screen.dart';
import 'screens/employee/employee_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final databaseService = DatabaseService.instance;
  final apiService = ApiService();
  final authService = AuthService(apiService, databaseService);
  final syncService = SyncService(apiService, databaseService, authService);
  
  // Initialize database (not needed for web)
  if (!kIsWeb) {
    await databaseService.initialize();
  }
  
  await authService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<SyncService>.value(value: syncService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, syncService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(databaseService, authService),
        ),
        ChangeNotifierProvider(
          create: (_) => StampProvider(databaseService, authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detský Pas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/child-home': (context) => const ChildHomeScreen(),
        '/employee-home': (context) => const EmployeeHomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
      },
    );
  }
}
