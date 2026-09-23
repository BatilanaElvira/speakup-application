import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'screens/admin/admin_web_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/feedback_inbox/feedback_inbox_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/journey/journey_map_screen.dart';
import 'screens/practice/practice_studio_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const SpeakUpApp(),
    ),
  );
}

class SpeakUpApp extends StatelessWidget {
  const SpeakUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'SpeakUp — AI Public Speaking Coach',
          debugShowCheckedModeBanner: false,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primaryBlue,
            brightness: Brightness.light,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              primary: AppColors.primaryBlue,
              secondary: AppColors.secondaryTeal,
              surface: AppColors.white,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF0D0B26),
            primaryColor: AppColors.primaryPurple,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryPurple,
              primary: AppColors.primaryPurple,
              secondary: AppColors.secondaryTeal,
              surface: const Color(0xFF1B164C),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const MainNavigationWrapper(),
        );
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // 1. Show Splash screen if first launch
    if (!provider.hasSeenSplash) {
      return SplashScreen(
        onFinish: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      );
    }

    // 2. Show Auth Screen if not logged in
    if (!provider.isAuthenticated) {
      return const AuthScreen();
    }

    // 3. Show Admin Web Portal if logged in with Admin credentials
    if (provider.userRole == 'Admin') {
      return const AdminWebScreen();
    }

    // 4. Trainee App Responsive Layout
    final List<Widget> pages = [
      HomeScreen(
        onNavigateTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const PracticeStudioScreen(),
      const JourneyMapScreen(),
      const FeedbackInboxScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SpeakUpBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
