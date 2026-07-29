import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'providers/emergency_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/monitoring_provider.dart';
import 'providers/language_provider.dart';
import 'models/user_model.dart';
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
import 'screens/doctor_login_screen.dart';
import 'services/chat_service.dart';
import 'utils/patient_status_utils.dart';

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
          supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
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
                  final isDoctor = authProvider.currentUser?.role == UserRole.doctor;
                  if (isDoctor) {
                    // Dokter selalu langsung ke dashboard dokter,
                    // tidak lewat pengecekan isProfileCompleted
                    // (field itu cuma relevan untuk profil anak di sisi parent).
                    Navigator.pushReplacementNamed(context, '/doctor');
                  } else if (authProvider.isProfileCompleted) {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    Navigator.pushReplacementNamed(context, '/onboarding');
                  }
                } else {
                  Navigator.pushReplacementNamed(context, '/role-selection');
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
            '/role-selection': (context) => const RoleSelectionScreen(),
            '/doctor-login': (context) => DoctorLoginScreen(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            '/register': (context) => const RegisterScreen(role: 'parent'),
            '/register-doctor': (context) => const RegisterScreen(role: 'doctor'),
            '/parent': (context) => const DashboardScreen(),
            '/doctor': (context) => const DoctorMainScreen(),
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
            icon: _buildChatIconWithBadge(const Icon(Icons.chat_outlined)),
            activeIcon: _buildChatIconWithBadge(const Icon(Icons.chat)),
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

  // 🔥 BARU: badge angka merah di icon Chat kalau ada pesan belum dibaca.
  Widget _buildChatIconWithBadge(Widget icon) {
    return StreamBuilder<int>(
      stream: ChatService().streamTotalUnreadCount(),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            if (unread > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
// ==========================
// DOCTOR MAIN SCREEN - shell bottom nav buat dokter (Beranda/Pasien/Chat/Profil)
// Digabung di sini, sama polanya dengan MainScreen di atas (buat parent).
// ==========================
class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedIndex = 1; // default tab "Pasien", sesuai desain Figma
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dokterNama = auth.currentUser?.fullName ?? 'Dokter';
    final initials = dokterNama.trim().isNotEmpty
        ? dokterNama.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'DR';

    // Search bar ini nge-filter tab "Pasien" dan tab "Chat" sekaligus.
    final screens = [
      const DoctorHomeScreen(),
      DoctorDashboard(searchQuery: _searchQuery),
      ChatListScreen(searchQuery: _searchQuery),
      const DoctorProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex != 3)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3A5C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dokterNama,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text('Dokter Anak · SpA', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        Consumer<NotifikasiProvider>(
                          builder: (context, notifProvider, _) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                                    );
                                  },
                                ),
                                if (notifProvider.belumDibaca > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        '${notifProvider.belumDibaca}',
                                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari pasien...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B3A5C),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Pasien'),
          BottomNavigationBarItem(
            icon: _buildChatIconWithBadge(const Icon(Icons.chat_bubble_outline)),
            activeIcon: _buildChatIconWithBadge(const Icon(Icons.chat_bubble)),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildChatIconWithBadge(Widget icon) {
    return StreamBuilder<int>(
      stream: ChatService().streamTotalUnreadCount(),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            if (unread > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ==========================
// DOCTOR HOME SCREEN (tab "Beranda" dokter)
// ==========================
class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KONTEN STATIS - bukan feed berita real-time. Kalau ditanya
          // penguji, ini konten kuratif/ilustratif, bukan live data.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B3A5C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'UPDATE KESEHATAN GLOBAL',
                  style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'WHO: Infeksi Saluran Napas Anak Meningkat 12% di Asia Tenggara',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                ),
                SizedBox(height: 6),
                Text(
                  'Pantau pasien dengan riwayat asma dan prematur lebih intensif.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text('5 Juli 2026 · WHO Report', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 KARTU STATISTIK - dihitung dari data Firestore REAL
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'parent')
                .where('profileCompleted', isEqualTo: true)
                .snapshots(),
            builder: (context, patientSnap) {
              double avgSpo2 = 0;
              int urgentCount = 0;
              int alertActiveCount = 0;

              if (patientSnap.hasData) {
                final docs = patientSnap.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['nama'] ?? '').toString().trim().isNotEmpty;
                }).toList();

                final spo2Values = <double>[];
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final score = severityScore(data['spo2'], data['heartRate']);
                  if (score >= 1) alertActiveCount++;
                  if (score == 2) urgentCount++;

                  final spo2 = data['spo2'];
                  final spo2Num = spo2 is num ? spo2.toDouble() : double.tryParse('$spo2');
                  if (spo2Num != null) spo2Values.add(spo2Num);
                }

                if (spo2Values.isNotEmpty) {
                  avgSpo2 = spo2Values.reduce((a, b) => a + b) / spo2Values.length;
                }
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ChatService().streamMyConversations(),
                builder: (context, convoSnap) {
                  int consultationsToday = 0;
                  if (convoSnap.hasData) {
                    final now = DateTime.now();
                    for (final doc in convoSnap.data!.docs) {
                      final lastMessageAt = doc.data()['lastMessageAt'];
                      if (lastMessageAt is Timestamp) {
                        final date = lastMessageAt.toDate();
                        if (date.year == now.year && date.month == now.month && date.day == now.day) {
                          consultationsToday++;
                        }
                      }
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _doctorStatCard(
                              label: 'Rata-rata SpO2 Pasien',
                              value: patientSnap.hasData ? '${avgSpo2.toStringAsFixed(1)}%' : '-',
                              color: const Color(0xFF3B82F6),
                              bgColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _doctorStatCard(
                              label: 'Pasien Perlu Perhatian',
                              value: '$urgentCount',
                              color: const Color(0xFFEF4444),
                              bgColor: const Color(0xFFFFF5F5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _doctorStatCard(
                              label: 'Konsultasi Hari Ini',
                              value: '$consultationsToday',
                              color: const Color(0xFF22C55E),
                              bgColor: const Color(0xFFF0FDF4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _doctorStatCard(
                              label: 'Alert Aktif',
                              value: '$alertActiveCount',
                              color: const Color(0xFFF59E0B),
                              bgColor: const Color(0xFFFFFBEB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // TIPS KLINIS - KONTEN STATIS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIPS KLINIS HARI INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3A5C))),
                SizedBox(height: 10),
                _DoctorTipItem(text: 'SpO2 < 94% → segera evaluasi oksigenasi'),
                SizedBox(height: 6),
                _DoctorTipItem(text: 'HR > 140 bpm anak < 5thn → cek demam & distres'),
                SizedBox(height: 6),
                _DoctorTipItem(text: 'Rekam baseline vital sebelum terapi inhalasi'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PERINGATAN MUSIM - KONTEN STATIS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERINGATAN MUSIM',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Musim kemarau — risiko ISPA meningkat. Pasien asma perlu pemantauan SpO2 lebih sering.',
                        style: TextStyle(fontSize: 12, color: Colors.brown.shade700, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _doctorStatCard({required String label, required String value, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _DoctorTipItem extends StatelessWidget {
  final String text;
  const _DoctorTipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.circle, size: 6, color: Color(0xFF4FC3F7)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4))),
      ],
    );
  }
}

// ==========================
// DOCTOR PROFILE SCREEN (tab "Profil" dokter)
// ==========================
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final fullName = user?.fullName ?? 'Dokter';
    final email = user?.email ?? '-';
    final userCode = user?.userCode ?? '-';
    final initials = fullName.trim().isNotEmpty
        ? fullName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'DR';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B3A5C), Color(0xFF2E5A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: Color(0xFF1B3A5C)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kode Dokter', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(userCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}