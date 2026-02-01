import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/currency.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../services/trip_storage_service.dart';
import '../services/cache_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();
  final TripStorageService _tripStorage = TripStorageService();
  final CacheService _cacheService = CacheService();

  User? _currentUser;
  UserPreferences? _preferences;
  String _appVersion = '';
  String _cacheSize = 'Calculating...';
  bool _isLoading = true;
  bool _biometricAvailable = false;
  bool _hasBiometricCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _currentUser = _authService.currentUser;
    _preferences = await _preferencesService.getPreferences();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      _appVersion = '1.0.0';
    }

    // Load cache size
    try {
      await _cacheService.estimateCacheSize();
      final size = await _cacheService.getCacheSize();
      _cacheSize = _cacheService.formatCacheSize(size);
    } catch (e) {
      _cacheSize = 'Unknown';
    }

    // Check biometric availability
    _biometricAvailable = await _authService.isBiometricAvailable();
    _hasBiometricCredentials = await _authService.hasBiometricCredentials();

    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Logout',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Delete Account',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete your account and all your trips. This action cannot be undone.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.deleteAccount();
      await _tripStorage.clearAllTrips();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Clear Cache',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'This will clear all cached data ($_cacheSize). Your trips will not be affected.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: GoogleFonts.outfit(color: const Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      final success = await _cacheService.clearAllCaches();

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Cache cleared successfully' : 'Failed to clear cache',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadData(); // Reload to update cache size
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.3),
            const Color(0xFF6C63FF).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(
              _currentUser?.getInitials() ?? '?',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.name ?? 'User',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              // Reload data after returning from edit profile
              _loadData();
            },
            icon: const Icon(Icons.edit, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Preferences',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildSettingsCard([
          _buildCurrencyTile(),
          const Divider(color: Colors.white12, height: 1),
          _buildNotificationTile(),
          const Divider(color: Colors.white12, height: 1),
          _buildThemeTile(),
        ]),
      ],
    );
  }

  Widget _buildCurrencyTile() {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: Color(0xFF6C63FF)),
      title: Text(
        'Default Currency',
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      subtitle: Text(
        _preferences?.defaultCurrency ?? 'USD',
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _showCurrencyPicker(),
    );
  }

  Widget _buildNotificationTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: Color(0xFF6C63FF)),
      title: Text(
        'Notifications',
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      subtitle: Text(
        'Receive trip reminders and updates',
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
      ),
      value: _preferences?.notificationsEnabled ?? true,
      activeThumbColor: const Color(0xFF6C63FF),
      onChanged: (value) async {
        await _preferencesService.updateNotificationsEnabled(value);
        _loadData();
      },
    );
  }

  Widget _buildThemeTile() {
    return ListTile(
      leading: const Icon(Icons.palette, color: Color(0xFF6C63FF)),
      title: Text(
        'Theme',
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      subtitle: Text(
        _preferences?.theme.toUpperCase() ?? 'DARK',
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _showThemePicker(),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Security',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildSettingsCard([
          _buildBiometricTile(),
        ]),
      ],
    );
  }

  Widget _buildBiometricTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint, color: Color(0xFF6C63FF)),
      title: Text(
        'Biometric Login',
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      subtitle: Text(
        _biometricAvailable
            ? (_hasBiometricCredentials
                ? 'Enabled - Requires fingerprint to open app'
                : 'Tap to enable biometric login')
            : 'Not available on this device',
        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
      ),
      value: _hasBiometricCredentials,
      activeThumbColor: const Color(0xFF6C63FF),
      onChanged: _biometricAvailable
          ? (value) async {
              if (value && !_hasBiometricCredentials) {
                // Enable biometric - ask for password
                await _showEnableBiometricDialog();
              } else if (!value && _hasBiometricCredentials) {
                // Disable biometric - clear credentials
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2A2A2A),
                    title: Text(
                      'Disable Biometric Login',
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    content: Text(
                      'This will remove your saved biometric credentials. You can re-enable it by logging in with "Remember me" checked.',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Disable',
                          style: GoogleFonts.outfit(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _authService.clearBiometricCredentials();
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Biometric login disabled',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            }
          : null,
    );
  }

  Future<void> _showEnableBiometricDialog() async {
    final passwordController = TextEditingController();
    bool isVerifying = false;
    String? error;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text(
            'Enable Biometric Login',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter your password to enable biometric login.',
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.outfit(color: Colors.white54),
                  errorText: error,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isVerifying ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: isVerifying
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        setState(() => error = 'Password required');
                        return;
                      }

                      setState(() {
                        isVerifying = true;
                        error = null;
                      });

                      // Verify password by logging in
                      final result = await _authService.login(
                        email: _currentUser?.email ?? '',
                        password: passwordController.text,
                        rememberCredentials: true, // This enables biometric
                      );

                      if (result.success) {
                        if (mounted) {
                          Navigator.pop(context);
                          _loadData(); // Refresh state
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Biometric login enabled',
                                style: GoogleFonts.outfit(),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          isVerifying = false;
                          error = result.error ?? 'Verification failed';
                        });
                      }
                    },
              child: isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Enable',
                      style: GoogleFonts.outfit(color: const Color(0xFF6C63FF)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Data Management',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildSettingsCard([
          _buildListTile(
            icon: Icons.cleaning_services,
            title: 'Clear Cache',
            subtitle: 'Free up storage space ($_cacheSize)',
            onTap: _handleClearCache,
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildListTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            iconColor: Colors.red,
            onTap: _handleDeleteAccount,
          ),
        ]),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'About',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildSettingsCard([
          _buildListTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: _appVersion,
            onTap: null,
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildListTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              );
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          _buildListTile(
            icon: Icons.star,
            title: 'Rate App',
            onTap: _handleRateApp,
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF6C63FF)),
      title: Text(
        title,
        style: GoogleFonts.outfit(color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.white54)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: Text(
          'Logout',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _showThemePicker() async {
    final themes = ['Dark', 'Light', 'System'];
    final currentTheme = _preferences?.theme ?? 'dark';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Select Theme',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            final isSelected =
                theme.toLowerCase() == currentTheme.toLowerCase();
            return ListTile(
              title: Text(
                theme,
                style: GoogleFonts.outfit(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
              ),
              onTap: () => Navigator.pop(context, theme.toLowerCase()),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      await _preferencesService.updateTheme(selected);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Theme will be applied in future updates',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: const Color(0xFF6C63FF),
          ),
        );
      }
    }
  }

  Future<void> _handleRateApp() async {
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.ghoomo.travel_planner';

    // For Android, use Play Store URL; for iOS, use App Store URL
    // In a real app, you'd detect the platform
    // ignore: unused_local_variable
    const url = playStoreUrl;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Rate Ghoomo',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Enjoying Ghoomo? Please take a moment to rate us on the app store!',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Later',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Rate Now',
              style: GoogleFonts.outfit(color: const Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not open app store',
                  style: GoogleFonts.outfit(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error opening app store: $e',
                style: GoogleFonts.outfit(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showCurrencyPicker() async {
    final currencies = Currency.allCurrencies;
    final selected = await showDialog<Currency>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Select Currency',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text(
                  '${currency.code} - ${currency.name}',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
                subtitle: Text(
                  currency.symbol,
                  style: GoogleFonts.outfit(color: Colors.white54),
                ),
                onTap: () => Navigator.pop(context, currency),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      await _preferencesService.updateDefaultCurrency(selected.code);
      _loadData();
    }
  }
}
