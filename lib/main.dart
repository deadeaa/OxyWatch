// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/emergency_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/monitoring_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/emergency_monitor_screen.dart';
import 'screens/onboarding_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'OxyWatch',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF1B3A5C),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1B3A5C),
              elevation: 0,
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF1B3A5C),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              const TextTheme(
                bodyLarge: TextStyle(color: Color(0xFF1B3A5C)),
                bodyMedium: TextStyle(color: Color(0xFF1B3A5C)),
              ),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            useMaterial3: true,
          ),
          // 🔥 INITIAL ROUTE: SPLASH SCREEN
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => SplashScreen(
              onNext: () {
                // Navigasi ke halaman berikutnya setelah splash
                final authProvider = context.read<AuthProvider>();
                if (authProvider.isLoggedIn) {
                  if (authProvider.isProfileCompleted) {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    Navigator.pushReplacementNamed(context, '/onboarding');
                  }
                } else {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              onBack: () {
                // Kembali ke halaman sebelumnya (jika ada)
                Navigator.pop(context);
              },
            ),
            '/main': (context) => const MainScreen(),
            '/emergency': (context) => const EmergencyMonitorScreen(),
            '/onboarding': (context) => const OnboardingProfileScreen(),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatListScreen(),
    RiwayatScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}