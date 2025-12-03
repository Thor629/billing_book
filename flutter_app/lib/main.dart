import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/organization_provider.dart';
import 'providers/party_provider.dart';
import 'providers/item_provider.dart';
import 'providers/godown_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/user_dashboard.dart';
import 'screens/organization/organization_selector_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Safe text theme with fallback
  static TextTheme _getSafeTextTheme(BuildContext context) {
    try {
      return GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      );
    } catch (e) {
      return Theme.of(context).textTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => PartyProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => GodownProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'SaaS Billing Platform',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryDark,
                brightness: Brightness.light,
              ),
              textTheme: _getSafeTextTheme(context),
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/admin': (context) => const AdminDashboard(),
              '/user': (context) => const UserDashboard(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _organizationsLoaded = false;
  bool _isLoadingOrganizations = false;

  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  Future<void> _loadOrganizations(BuildContext context) async {
    if (_organizationsLoaded || _isLoadingOrganizations) return;

    _isLoadingOrganizations = true;
    final orgProvider =
        Provider.of<OrganizationProvider>(context, listen: false);
    await orgProvider.loadOrganizations();

    if (!mounted) return;

    // Auto-select if only one organization (Requirement 18.2)
    if (orgProvider.organizations.length == 1) {
      orgProvider.selectOrganization(orgProvider.organizations.first);
    }

    setState(() {
      _organizationsLoaded = true;
      _isLoadingOrganizations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, OrganizationProvider>(
      builder: (context, authProvider, orgProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated - show login
        if (!authProvider.isAuthenticated) {
          _organizationsLoaded = false; // Reset on logout
          _isLoadingOrganizations = false;
          return const LoginScreen();
        }

        // Admin users bypass organization selection
        if (authProvider.user?.role == 'admin') {
          return const AdminDashboard();
        }

        // Regular users need organization selection
        // Load organizations if not loaded yet
        if (!_organizationsLoaded) {
          if (!_isLoadingOrganizations) {
            _loadOrganizations(context);
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show organization selector if no organization selected
        // Requirement 18.1: No organizations → create screen
        // Requirement 18.3: Multiple organizations → selection screen
        if (!orgProvider.hasOrganization) {
          return const OrganizationSelectorDialog();
        }

        // Organization selected - show user dashboard (Requirement 18.4, 18.5)
        return const UserDashboard();
      },
    );
  }
}
