import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme_constants.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();

  bool _isLocked = true;
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background - lock it
      if (_isEnabled) {
        setState(() => _isLocked = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground - verify if locked
      if (_isEnabled && _isLocked) {
        _authenticate();
      }
    }
  }

  Future<void> _checkLockStatus() async {
    // Check if biometric login is enabled
    // We check this by seeing if we have saved credentials
    final hasCredentials = await _authService.hasBiometricCredentials();

    if (mounted) {
      setState(() {
        _isEnabled = hasCredentials;
        // If enabled, stay locked. If not, unlock.
        _isLocked = hasCredentials;
        _isLoading = false;
      });

      if (_isEnabled && _isLocked) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    try {
      final result = await _authService.authenticateWithBiometrics();

      if (mounted) {
        if (result != null && result.success) {
          setState(() => _isLocked = false);
        }
      }
    } catch (e) {
      debugPrint('App lock auth error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(color: GhoomoColors.backgroundDark);
    }

    return Stack(
      textDirection: TextDirection.ltr, // Required for Stack at root
      children: [
        widget.child,
        if (_isEnabled && _isLocked)
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: GhoomoColors.backgroundDark,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: GhoomoColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ghoomo Locked',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unlock with Biometrics',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GhoomoColors.primary,
                        foregroundColor: GhoomoColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Unlock',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
