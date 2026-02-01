import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      debug: true, // Enable debug logs during development
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization error: $e');
    debugPrint('App will continue with local storage only');
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize auth service
  late final AuthService authService;
  try {
    authService = AuthService();
    await authService.initialize();
    debugPrint('✅ AuthService initialized successfully');
  } catch (e) {
    debugPrint('⚠️ AuthService initialization failed: $e');
    debugPrint('Creating fallback AuthService');
    authService = AuthService();
  }

  runApp(TravelPlannerApp(authService: authService));
}

class TravelPlannerApp extends StatelessWidget {
  final AuthService authService;

  const TravelPlannerApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF221E10), // Ghoomo warm dark
        primaryColor: const Color(0xFFF2B90D), // Ghoomo golden yellow
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF2B90D),
          secondary: Color(0xFFE0A800),
          surface: Color(0xFF2C2819),
          background: Color(0xFF221E10),
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2C2819),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _determineInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                ),
              ),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }

  Future<Widget> _determineInitialScreen() async {
    final isLoggedIn = await authService.isLoggedIn();
    final hasSeenOnboarding = await authService.hasSeenOnboarding();

    if (isLoggedIn) {
      return const HomeScreen();
    } else if (hasSeenOnboarding) {
      return const LoginScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
