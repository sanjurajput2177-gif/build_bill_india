import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'services/ad_service.dart';
import 'screens/billing_screen.dart';
import 'screens/calculators_screen.dart';
import 'screens/history_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize AdMob in background (don't await)
  unawaited(MobileAds.instance.initialize());
  
  // Start pre-loading immediately (don't await)
  InterstitialAdManager.instance.loadAd();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..loadData(),
      child: const BuildBillApp(),
    ),
  );
}

// Simple unawaited helper
void unawaited(Future<void> future) {}

class BuildBillApp extends StatelessWidget {
  const BuildBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildBill India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue-600
          primary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Gray-50
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)), // Gray-200
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    int selectedIndex = appState.selectedIndex;

    final List<Widget> _screens = [
      const BillingScreen(),
      const CalculatorsScreen(),
      const HistoryScreen(),
      const PaymentsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) => appState.updateSelectedIndex(index),
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Billing'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calculator), label: 'Calculators'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.creditCard), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
