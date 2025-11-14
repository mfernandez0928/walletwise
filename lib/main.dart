import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive FIRST
  await Hive.initFlutter();

  // 2. Initialize Firebase SECOND
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Currency Converter with real-time rates THIRD
  await CurrencyConverter.initialize();

  runApp(const WalletWiseApp());
}

class WalletWiseApp extends StatelessWidget {
  const WalletWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => AccountProvider()..init(),
        ),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'WalletWise',
        debugShowCheckedModeBanner: false, // Add this to remove DEBUG banner
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show splash while loading
            if (authProvider.isLoading) {
              return const SplashScreen();
            }

            // Show dashboard if logged in
            if (authProvider.isLoggedIn) {
              return const DashboardScreen();
            }

            // Show login screen by default
            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
