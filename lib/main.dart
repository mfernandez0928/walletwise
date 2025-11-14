import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialize Hive FIRST
    print('🔄 Initializing Hive...');
    await Hive.initFlutter();
    print('✓ Hive initialized successfully');

    // 2. Initialize Firebase SECOND
    print('🔄 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');

    // 3. Initialize Currency Converter with real-time rates THIRD
    print('🔄 Initializing Currency Converter...');
    await CurrencyConverter.initialize();
    print('✓ Currency Converter initialized successfully');

    print('✓ All services initialized. Starting app...');
  } catch (e) {
    print('✗ Initialization error: $e');
  }

  runApp(const WalletWiseApp());
}

class WalletWiseApp extends StatelessWidget {
  const WalletWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - for user authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Account Provider - initialize and load data
        ChangeNotifierProvider(
          create: (_) => AccountProvider()..init(),
        ),

        // Transaction Provider - initialize and load data
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),

        // Expense Provider - for monthly expense tracking
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),

        // Theme Provider - for app theme management
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'WalletWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: AppColors.primary),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show splash while loading
            if (authProvider.isLoading) {
              return const SplashScreen();
            }

            // Show dashboard if logged in
            if (authProvider.isLoggedIn) {
              // Reload data when user logs in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AccountProvider>().notifyListeners();
                context.read<TransactionProvider>().notifyListeners();
              });
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
