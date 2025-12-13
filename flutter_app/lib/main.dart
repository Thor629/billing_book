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
import 'screens/user/settings_screen.dart';
import 'screens/organization/organization_selector_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Modern text theme with Poppins (clean, modern font)
  static TextTheme _getModernTextTheme() {
    try {
      return TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
        ),
      );
    } catch (e) {
      // Fallback to default theme
      return const TextTheme();
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
                seedColor: AppColors.warmPeach,
                primary: AppColors.primary,
                secondary: AppColors.warmOrange,
                tertiary: AppColors.warmPink,
                brightness: Brightness.light,
                surface: AppColors.cardBackground,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.buttonTextDark,
              ),
              scaffoldBackgroundColor: AppColors.background,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: AppColors.cardBackground,
                shadowColor: AppColors.shadowWarm,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmPeach,
                  foregroundColor: AppColors.buttonTextDark,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: AppColors.warmOrange,
                foregroundColor: AppColors.buttonTextDark,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.warmOrange, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                labelStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: AppColors.chipOrange,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
              ),
              dividerTheme: const DividerThemeData(
                color: AppColors.divider,
                thickness: 1,
              ),
              textTheme: _getModernTextTheme(),
              fontFamily: GoogleFonts.poppins().fontFamily,
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/admin': (context) => const AdminDashboard(),
              '/user': (context) => const UserDashboard(),
              '/settings': (context) => const SettingsScreen(),
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
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // If not authenticated after initialization, clear organization data
      if (!authProvider.isAuthenticated) {
        final orgProvider =
            Provider.of<OrganizationProvider>(context, listen: false);
        await orgProvider.clearOrganization();
      }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Not authenticated - show login
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Admin users bypass organization selection
        if (authProvider.user?.role == 'admin') {
          return const AdminDashboard();
        }

        // Regular users need organization selection
        // Show organization selector if no organization selected
        // The dialog handles loading organizations internally
        if (!orgProvider.hasOrganization) {
          return const OrganizationSelectorDialog();
        }

        // Organization selected - show user dashboard
        return const UserDashboard();
      },
    );
  }
}
