// screens/emergency_monitor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/monitoring_provider.dart';

class EmergencyMonitorScreen extends StatefulWidget {
  const EmergencyMonitorScreen({super.key});

  @override
  State<EmergencyMonitorScreen> createState() => _EmergencyMonitorScreenState();
}

class _EmergencyMonitorScreenState extends State<EmergencyMonitorScreen>
    with SingleTickerProviderStateMixin {
  // ========== STATE ==========
  String _currentView = 'normal';
  String _guideType = 'inhaler';
  int _currentStep = 0;
  late AnimationController _pulseController;

  // Data dummy riwayat serangan
  final List<Map<String, String>> _history = [
    {'date': '17 Jun 2025', 'time': '02:14', 'spo2': '89%', 'status': 'Kritis'},
    {'date': '15 Jun 2025', 'time': '18:30', 'spo2': '92%', 'status': 'Warning'},
    {'date': '12 Jun 2025', 'time': '10:00', 'spo2': '90%', 'status': 'Kritis'},
  ];

  final List<Map<String, String>> _inhalerSteps = [
    {'title': '1. Lepaskan Tutup', 'desc': 'Buka tutup inhaler dan kocok perlahan selama 3-5 detik'},
    {'title': '2. Posisikan', 'desc': 'Pegang inhaler tegak, letakkan di antara jari telunjuk dan ibu jari'},
    {'title': '3. Buang Napas', 'desc': 'Buang napas pelan melalui mulut sampai paru-paru kosong'},
    {'title': '4. Hisap & Semprot', 'desc': 'Masukkan ujung ke mulut, hisap napas dalam sambil menekan inhaler'},
    {'title': '5. Tahan Napas', 'desc': 'Tahan napas selama 10 detik, lalu hembuskan pelan'},
  ];

  final List<Map<String, String>> _cprSteps = [
    {'title': '1. Periksa Kesadaran', 'desc': 'Tepuk bahu dan panggil nama anak dengan keras'},
    {'title': '2. Panggil Bantuan', 'desc': 'Minta orang lain untuk memanggil ambulans (119)'},
    {'title': '3. Buka Jalan Napas', 'desc': 'Tengadahkan kepala, angkat dagu untuk membuka jalan napas'},
    {'title': '4. Periksa Napas', 'desc': 'Dengar dan rasakan napas selama 10 detik'},
    {'title': '5. Kompresi Dada', 'desc': 'Kompresi dada 30 kali dengan kedalaman 5 cm, kecepatan 100-120/menit'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resetToNormal() {
    setState(() {
      _currentView = 'normal';
      _currentStep = 0;
      _guideType = 'inhaler';
    });
  }

  void _goToEmergency() {
    setState(() {
      _currentView = 'emergency';
      _currentStep = 0;
    });
  }

  void _goToGuide(String type) {
    setState(() {
      _currentView = 'guide';
      _guideType = type;
      _currentStep = 0;
    });
  }

  void _goBackToEmergency() {
    setState(() {
      _currentView = 'emergency';
      _currentStep = 0;
    });
  }

  void _nextStep() {
    final steps = _guideType == 'inhaler' ? _inhalerSteps : _cprSteps;
    if (_currentStep < steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _goBackToEmergency();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _guideType == 'inhaler'
                ? '✅ Inhaler berhasil digunakan! Tetap pantau kondisi.'
                : '🆘 Bantuan telah diberikan! Segera hubungi tenaga medis.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'guide') {
      return _buildStepByStepGuide();
    }

    if (_currentView == 'emergency') {
      return _buildEmergencyView();
    }

    return _buildNormalView();
  }

  // ========== NORMAL VIEW ==========
  Widget _buildNormalView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Monitor Darurat'),
        backgroundColor: const Color(0xFF1B3A5C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Aman',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A1628), Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF22C55E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kondisi Normal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'AI OxyWatch memantau secara aktif',
                          style: TextStyle(
                            color: const Color(0xFF94A3B8).withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Live',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Threshold info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AMBANG BATAS DARURAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildThresholdRow('SpO₂ < 94% → Alert Kritis', true),
                  const SizedBox(height: 4),
                  _buildThresholdRow('HR > 140 bpm → Alert Kritis', true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 🔥 INFO PENTING - TAMBAHAN
            _buildInfoSection(),

            const SizedBox(height: 12),

            // 🔥 TOMBOL SIMULASI
            GestureDetector(
              onTap: _goToEmergency,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                    SizedBox(width: 8),
                    Text(
                      '⚠️ Simulasi Kondisi Darurat',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ========== INFO SECTION ==========
  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF4FC3F7), size: 18),
            const SizedBox(width: 8),
            const Text(
              'Info & Tips Penting',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B3A5C),
              ),
            ),
          ],
        ),
        children: [
          // Kontak Darurat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, color: Color(0xFFEF4444), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'KONTAK DARURAT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildContactRow('🏥 Ambulans', '119'),
                _buildContactRow('🚑 PMI', '1500-567'),
                _buildContactRow('👨‍⚕️ Dokter Anak', '021-1234567'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Gejala yang perlu diwaspadai
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'GEJALA YANG PERLU DIWASPADAI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('• Sesak napas / napas berbunyi (wheezing)', style: _gejalaStyle()),
                Text('• Bibir atau wajah membiru (sianosis)', style: _gejalaStyle()),
                Text('• Batuk terus-menerus atau suara serak', style: _gejalaStyle()),
                Text('• Napas cepat (>40 kali/menit untuk anak)', style: _gejalaStyle()),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tips pencegahan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFF4FC3F7), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'TIPS PENCEGAHAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B3A5C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('• Hindari paparan asap rokok dan debu', style: _tipsStyle()),
                Text('• Pastikan inhaler selalu tersedia dan siap pakai', style: _tipsStyle()),
                Text('• Pantau kondisi secara rutin dengan OxyWatch', style: _tipsStyle()),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Riwayat serangan terakhir
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF64748B).withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Color(0xFF64748B), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'RIWAYAT SERANGAN TERAKHIR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ..._history.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item['status'] == 'Kritis'
                              ? Colors.red
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item['date']} ${item['time']} - SpO₂ ${item['spo2']} (${item['status']})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _gejalaStyle() {
    return const TextStyle(
      fontSize: 11,
      color: Color(0xFF475569),
      height: 1.6,
    );
  }

  TextStyle _tipsStyle() {
    return const TextStyle(
      fontSize: 11,
      color: Color(0xFF475569),
      height: 1.6,
    );
  }

  Widget _buildContactRow(String name, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF475569),
            ),
          ),
          const Spacer(),
          Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B3A5C),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📞 Memanggil $number...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Panggil',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(String text, bool isAman) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1B3A5C),
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Aman',
            style: TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ========== EMERGENCY VIEW ==========
  Widget _buildEmergencyView() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF7F1D1D).withOpacity(0.4),
                ],
                radius: 0.8,
                center: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1628).withOpacity(0.95),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1628).withOpacity(0.98),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _resetToNormal,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1 + _pulseController.value * 0.05;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withOpacity(0.5),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'DARURAT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '🆘 Penanganan Darurat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih tindakan yang sesuai dengan kondisi',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildEmergencyActionCard(
                    icon: Icons.medical_services,
                    title: 'Buka Inhaler',
                    desc: 'Panduan langkah demi langkah',
                    color: const Color(0xFF4FC3F7),
                    onTap: () => _goToGuide('inhaler'),
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyActionCard(
                    icon: Icons.favorite,
                    title: 'Bantuan Napas (CPR)',
                    desc: 'Panduan CPR untuk anak',
                    color: const Color(0xFFEF4444),
                    onTap: () => _goToGuide('cpr'),
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyActionCard(
                    icon: Icons.phone,
                    title: 'Panggil Bantuan Medis',
                    desc: 'Hubungi 119 atau ambulans terdekat',
                    color: const Color(0xFFFF6B35),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A2A3A),
                          title: const Text(
                            '📞 Menghubungi...',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                              SizedBox(height: 16),
                              Text(
                                'Sedang menghubungi layanan darurat 119',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 3), () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📞 Bantuan sedang dalam perjalanan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyActionCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ========== STEP-BY-STEP GUIDE ==========
  Widget _buildStepByStepGuide() {
    final steps = _guideType == 'inhaler' ? _inhalerSteps : _cprSteps;
    final step = steps[_currentStep];
    final color = _guideType == 'inhaler' ? const Color(0xFF4FC3F7) : const Color(0xFFEF4444);
    final icon = _guideType == 'inhaler' ? Icons.medical_services : Icons.favorite;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _goBackToEmergency,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _guideType == 'inhaler' ? '💨 Cara Pakai Inhaler' : '🫀 Cara Bantuan Napas (CPR)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ...List.generate(steps.length, (index) {
                    final isActive = index == _currentStep;
                    final isDone = index < _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isDone
                              ? color
                              : isActive
                              ? color.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Langkah ${_currentStep + 1} dari ${steps.length}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step['desc']!,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: _prevStep,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(
                            child: Text(
                              '← Sebelumnya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentStep > 0 ? 1 : 2,
                    child: GestureDetector(
                      onTap: _nextStep,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _currentStep == steps.length - 1 ? color : color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _currentStep == steps.length - 1 ? '✅ Selesai' : 'Selanjutnya →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}