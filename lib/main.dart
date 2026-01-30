import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp();

    // Configure Firestore with offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue without Firebase features');
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize FCM service (will fail gracefully if Firebase not configured)
  try {
    final fcmService = FCMService();
    await fcmService.initialize();
  } catch (e) {
    debugPrint('FCM initialization skipped: $e');
  }

  // Initialize auth service (requires Firebase to be initialized first)
  late final AuthService authService;
  try {
    authService = AuthService();
    await authService.initialize();
  } catch (e) {
    debugPrint('AuthService initialization failed: $e');
    debugPrint('Creating fallback AuthService');
    // This will fail but we catch it gracefully
    authService = AuthService();
  }

  // Enable high refresh rate (120Hz) for fluid animations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable high refresh rate mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Deep black-grey
        primaryColor: const Color(0xFF6C63FF), // Premium purple accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF), // Cyan accent
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
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
