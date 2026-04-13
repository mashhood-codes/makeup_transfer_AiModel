import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/parlour_listing.dart';
import '../screens/parlour_detail.dart';
import '../screens/search_filter_screen.dart';
import '../screens/booking_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const profile = '/profile';
  static const home = '/home';
  static const parlourListing = '/parlour-listing';
  static const parlourDetail = '/parlour-detail';
  static const searchFilter = '/search-filter';
  static const booking = '/booking';

  static final Map<String, Widget Function(BuildContext)> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    profile: (_) => const ProfileScreen(),
    home: (_) => const HomeScreen(),
    parlourListing: (_) => const ParlourListingScreen(),
    parlourDetail: (_) => const ParlourDetailScreen(),
    searchFilter: (_) => const SearchFilterScreen(),
    booking: (_) => const BookingScreen(),
  };
}
