import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/colors.dart';
import 'services/secure_auth_service.dart';
import 'services/api_config.dart';

// Auth Screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// Main Screens
import 'screens/transfer_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/parlour_listing.dart';
import 'screens/parlour_detail.dart';
import 'screens/search_filter_screen.dart';
import 'screens/booking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.initialize();
  runApp(const ProviderScope(child: GlowupAIApp()));
}

class GlowupAIApp extends ConsumerWidget {
  const GlowupAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Glowup AI - Professional Makeup Transfer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: _buildRouter(),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        // Auth Routes
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Main App Routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/transfer',
          builder: (context, state) => const TransferScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/parlour-listing',
          builder: (context, state) => const ParlourListingScreen(),
        ),
        GoRoute(
          path: '/parlour-detail',
          builder: (context, state) => const ParlourDetailScreen(),
        ),
        GoRoute(
          path: '/search-filter',
          builder: (context, state) => const SearchFilterScreen(),
        ),
        GoRoute(
          path: '/booking',
          builder: (context, state) => const BookingScreen(),
        ),
      ],
      redirect: (context, state) async {
        final isLoggedIn = await SecureAuthService.isLoggedIn();
        final isSplash = state.uri.path == '/splash';
        final isAuthRoute = state.uri.path == '/login' ||
            state.uri.path == '/signup' ||
            state.uri.path == '/forgot-password';
        final isOnboarding = state.uri.path == '/onboarding';

        // If not logged in and not on auth routes or splash
        if (!isLoggedIn && !isAuthRoute && !isSplash && !isOnboarding) {
          return '/splash';
        }

        // If logged in and on auth routes, go to home
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        return null;
      },
    );
  }
}
