// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/emergency_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/monitoring_provider.dart';
import 'providers/language_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/emergency_monitor_screen.dart';
import 'screens/onboarding_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/register_screen.dart';
import 'utils/languages.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'OxyWatch',
          debugShowCheckedModeBanner: false,
          locale: Locale(languageProvider.currentLanguage),
          supportedLocales: const [Locale('id'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
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
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => SplashScreen(
              onNext: () {
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
                Navigator.pop(context);
              },
            ),
            '/main': (context) => const MainScreen(),
            '/emergency': (context) => const EmergencyMonitorScreen(),
            '/onboarding': (context) => const OnboardingProfileScreen(),
            '/login': (context) => const LoginScreen(),
            // 🔥 FIX: tambahkan role parameter
            '/register': (context) => const RegisterScreen(role: 'parent'),
            '/parent': (context) => const DashboardScreen(),
            '/doctor': (context) => const DoctorDashboard(),
            // main.dart - tambahkan route
            '/role-selection': (context) => const RoleSelectionScreen(),
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
    final lang = AppLocalizations.of(context)!;

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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: lang.bottomDashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat),
            label: lang.bottomChat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: lang.bottomRiwayat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: lang.bottomProfil,
          ),
        ],
      ),
    );
  }
}