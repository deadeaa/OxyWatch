import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Helper untuk cek bahasa
  bool get isId => locale.languageCode == 'id';
  bool get isEn => locale.languageCode == 'en';

  // ========== BOTTOM NAV ==========
  String get bottomDashboard => isId ? 'Dashboard' : 'Dashboard';
  String get bottomChat => isId ? 'Chat' : 'Chat';
  String get bottomRiwayat => isId ? 'Riwayat' : 'History';
  String get bottomProfil => isId ? 'Profil' : 'Profile';

  // ========== DASHBOARD ==========
  String get dashboard => isId ? 'Dashboard' : 'Dashboard';
  String get trend7Hari => isId ? 'Tren 7 Hari' : '7-Day Trend';
  String get spo2 => 'SpO₂';
  String get heartRate => isId ? 'Detak Jantung' : 'Heart Rate';
  String get normal => isId ? 'Normal' : 'Normal';
  String get riskScore => isId ? 'Risk Score' : 'Risk Score';
  String get lowRisk => isId ? 'RISIKO RENDAH' : 'LOW RISK';
  String get emergencyLabel => '🚨 Emergency';
  String get fillProfileFirst => isId ? 'Isi profil terlebih dahulu' : 'Fill profile first';
  String get belumAdaData => isId ? 'Belum ada data' : 'No data yet';
  String get belumAdaRiskScore => isId ? 'Belum ada data risk score' : 'No risk score data yet';
  String get terakhir => isId ? 'Terakhir' : 'Latest';

  // ========== EMERGENCY OVERLAY ==========
  String get emergencyCondition => isId ? '🚨 KONDISI DARURAT!' : '🚨 EMERGENCY!';
  String get spo2Drastis => isId ? 'SpO₂ turun drastis! Segera lakukan tindakan.' : 'SpO₂ dropped drastically! Take action now.';
  String get openTreatment => isId ? 'Buka Penanganan' : 'Open Treatment';
  String get close => isId ? 'Tutup' : 'Close';

  // ========== PROFIL ==========
  String get profilAnak => isId ? 'Profil Anak' : 'Child Profile';
  String get belumAdaProfil => isId ? 'Belum ada profil' : 'No profile';
  String get kodeUnikPasien => isId ? 'KODE UNIK PASIEN' : 'UNIQUE PATIENT CODE';
  String get belumAda => isId ? 'BELUM ADA' : 'NOT AVAILABLE';
  String get belumTerhubung => isId ? 'Belum terhubung' : 'Not connected';
  String get terhubung => isId ? 'Terhubung' : 'Connected';
  String get tidakTerhubung => isId ? 'Tidak terhubung' : 'Disconnected';
  String get dataDiri => isId ? 'Data Diri' : 'Personal Data';
  String get usia => isId ? 'Usia' : 'Age';
  String get bb => isId ? 'BB' : 'Weight';
  String get tb => isId ? 'TB' : 'Height';
  String get goldar => isId ? 'Gol. Darah' : 'Blood Type';
  String get riwayatKondisi => isId ? 'Riwayat Kondisi' : 'Medical History';
  String get pengaturanAlert => isId ? 'Pengaturan Alert' : 'Alert Settings';
  String get smartwatch => isId ? 'Smartwatch' : 'Smartwatch';
  String get profilKosong => isId ? 'Profil masih kosong' : 'Profile is empty';
  String get klikEdit => isId ? 'Klik ikon edit di atas untuk mengisi data diri' : 'Tap edit icon above to fill in data';
  String get namaLengkap => isId ? 'Nama Lengkap' : 'Full Name';
  String get minimal2Huruf => isId ? 'Minimal 2 huruf' : 'Minimum 2 characters';
  String get hanyaAngka => isId ? 'Hanya angka' : 'Numbers only';
  String get simpanPerubahan => isId ? '💾 Simpan Perubahan' : '💾 Save Changes';
  String get profilBerhasil => isId ? '✅ Profil berhasil diperbarui' : '✅ Profile updated successfully';
  String get namaMinimal2 => isId ? 'Nama harus minimal 2 huruf' : 'Name must be at least 2 characters';
  String get usiaHarusAngka => isId ? 'Usia harus berupa angka' : 'Age must be a number';
  String get bbHarusAngka => isId ? 'BB harus berupa angka' : 'Weight must be a number';
  String get tbHarusAngka => isId ? 'TB harus berupa angka' : 'Height must be a number';

  // ========== RIWAYAT ==========
  String get riwayatMonitoring => isId ? 'Riwayat Monitoring' : 'Monitoring History';
  String get rataRataSpo2 => isId ? 'Rata-rata SpO₂' : 'Average SpO₂';
  String get rataRataHR => isId ? 'Rata-rata HR' : 'Average HR';
  String get totalAlert => isId ? 'Total Alert' : 'Total Alerts';
  String get logPengukuran => isId ? 'Log Pengukuran' : 'Measurement Log';
  String get hariIni => isId ? 'Hari ini' : 'Today';
  String get mingguIni => isId ? 'Minggu ini' : 'This Week';
  String get bulanIni => isId ? 'Bulan ini' : 'This Month';
  String get belumAdaRiwayat => isId ? 'Belum ada riwayat' : 'No history yet';
  String get isiProfilDulu => isId ? 'Isi profil anak terlebih dahulu untuk melihat riwayat' : 'Fill child profile first to see history';

  String get jam => isId ? 'Jam' : 'Hours';
  String get hari => isId ? 'Hari' : 'Days';
  String get minggu => isId ? 'Minggu' : 'Weeks';
  String get status => isId ? 'Status' : 'Status';
  String get ringkasanHarian => isId ? 'Ringkasan Harian' : 'Daily Summary';
  String get ringkasanMingguan => isId ? 'Ringkasan Mingguan' : 'Weekly Summary';
  String get exportPDF => isId ? 'Export PDF' : 'Export PDF';
  String get notifJika => isId ? 'Notif jika' : 'Notify if';
  String get tahun => isId ? 'tahun' : 'years';
  String get belumDiisi => isId ? 'Belum diisi' : 'Not filled';
  String get rataRata => isId ? 'Rata-rata' : 'Average';
  String get critical => isId ? 'Kritis' : 'Critical';

  // ========== EXPORT PDF ==========
  String get exportPDFTitle => isId ? '📄 Export PDF' : '📄 Export PDF';
  String get exportPDFSubtitle => isId ? 'Export riwayat monitoring dalam format PDF' : 'Export monitoring history as PDF';
  String get exportPDFInfo => isId ? 'PDF akan mencakup semua data log pengukuran' : 'PDF will include all measurement log data';
  String get exportPDFSuccess => isId ? '✅ PDF berhasil diexport!' : '✅ PDF exported successfully!';

  // ========== HARI ==========
  String get senin => isId ? 'Sen' : 'Mon';
  String get selasa => isId ? 'Sel' : 'Tue';
  String get rabu => isId ? 'Rab' : 'Wed';
  String get kamis => isId ? 'Kam' : 'Thu';
  String get jumat => isId ? 'Jum' : 'Fri';
  String get sabtu => isId ? 'Sab' : 'Sat';
  String get mingguu => isId ? 'Min' : 'Sun';

  // ========== STATUS ==========
  String get warning => isId ? 'Warning' : 'Warning';
  String get kritis => isId ? 'KRITIS' : 'CRITICAL';
  String get statusLabel => isId ? 'Status' : 'Status';

  // ========== CHAT ==========
  String get chatDenganDokter => isId ? 'Chat dengan Dokter' : 'Chat with Doctor';
  String get online => isId ? 'Online' : 'Online';
  String get offline => isId ? 'Offline' : 'Offline';
  String get tulisPesan => isId ? 'Tulis pesan ke dokter...' : 'Write a message to doctor...';
  String get vital => isId ? 'Vital' : 'Vital';
  String get dataVital => isId ? 'DATA VITAL' : 'VITAL DATA';
  String get snapshot => isId ? 'Snapshot' : 'Snapshot';
  String get semuaChatTerbaca => isId ? 'Semua chat lain sudah terbaca' : 'All other chats have been read';
  String get dokterOnlineLainnya => isId ? 'DOKTER ONLINE LAINNYA' : 'OTHER ONLINE DOCTORS';

  // ========== NOTIFIKASI ==========
  String get notifikasi => isId ? 'Notifikasi' : 'Notifications';
  String get belumDibaca => isId ? 'BELUM DIBACA' : 'UNREAD';
  String get sudahDibaca => isId ? 'SUDAH DIBACA' : 'READ';
  String get tandaiSemua => isId ? 'Tandai Semua' : 'Mark All Read';
  String get tidakAdaNotifikasi => isId ? 'Tidak ada notifikasi' : 'No notifications';
  String get belumAdaNotifikasi => isId ? 'Belum ada notifikasi masuk' : 'No notifications yet';
  String get semuaNotifikasiDibaca => isId ? '✅ Semua notifikasi ditandai telah dibaca' : '✅ All notifications marked as read';
  String get notifikasiBaru => isId ? '🔔 Notifikasi Baru' : '🔔 New Notification';
  String get tandaiDibaca => isId ? 'Tandai Dibaca' : 'Mark as Read';
  String get lihatDetail => isId ? 'Lihat Detail' : 'View Detail';
  String get segeraTindakan => isId ? 'Segera lakukan tindakan!' : 'Take action now!';
  String get informasi => isId ? 'Informasi' : 'Info';
  String get tutup => isId ? 'Tutup' : 'Close';
  String get bukaMonitor => isId ? 'Buka Monitor' : 'Open Monitor';
  String get kembali => isId ? 'Kembali' : 'Back';
  String get perluDipantau => isId ? 'Perlu pemantauan lebih lanjut' : 'Further monitoring needed';
  String get dataNormal => isId ? 'Data vital dalam batas normal' : 'Vital signs within normal range';

  // ========== PENGATURAN ==========
  String get pengaturan => isId ? 'Pengaturan' : 'Settings';
  String get bahasa => isId ? 'Bahasa / Language' : 'Language';
  String get ubahBahasa => isId ? 'Ubah bahasa tampilan' : 'Change display language';
  String get notifikasiKlinis => isId ? 'Notifikasi klinis' : 'Clinical notifications';
  String get privasiDataAnak => isId ? 'Privasi data anak' : 'Child data privacy';
  String get bantuanFAQ => isId ? 'Bantuan & FAQ' : 'Help & FAQ';
  String get hapusProfil => isId ? 'Hapus Profil' : 'Delete Profile';
  String get hapusProfilPermanen => isId ? 'Semua data anak akan dihapus permanen. Yakin ingin melanjutkan?' : 'All child data will be permanently deleted. Are you sure?';
  String get batal => isId ? 'Batal' : 'Cancel';
  String get hapus => isId ? 'Hapus' : 'Delete';
  String get profilDihapus => isId ? '✅ Profil berhasil dihapus' : '✅ Profile deleted successfully';
  String get bahasaDiubah => isId ? 'Bahasa diubah ke' : 'Language changed to';
  String get indonesia => isId ? 'Indonesia' : 'Indonesian';
  String get english => isId ? 'English' : 'English';

  // ========== LOGIN ==========
  String get login => isId ? 'Login' : 'Login';
  String get daftar => isId ? 'Daftar' : 'Register';
  String get email => isId ? 'Email' : 'Email';
  String get password => isId ? 'Password' : 'Password';
  String get belumPunyaAkun => isId ? 'Belum punya akun?' : 'Don\'t have an account?';
  String get sudahPunyaAkun => isId ? 'Sudah punya akun?' : 'Already have an account?';

  // Login placeholders - FIXED
  String get emailHint => isId ? 'nama@email.com' : 'name@email.com';
  String get passwordHint => isId ? 'Masukkan kata sandi' : 'Enter password';
  String get loginTitle => isId ? 'Masuk ke akun Anda' : 'Sign in to your account';
  String get welcomeBack => isId ? 'Selamat datang' : 'Welcome';
  String get forgotPasswordText => isId ? 'Lupa kata sandi?' : 'Forgot password?';
  String get loginButton => isId ? 'Masuk' : 'Login';
  String get registerLink => isId ? 'Belum punya akun? Daftar' : 'Don\'t have an account? Register';
  String get emailRequired => isId ? 'Email wajib diisi' : 'Email is required';
  String get invalidEmail => isId ? 'Email tidak valid' : 'Invalid email';
  String get passwordRequired => isId ? 'Password wajib diisi' : 'Password is required';
  String get passwordMin6 => isId ? 'Password minimal 6 karakter' : 'Password must be at least 6 characters';
  String get forgotPasswordComingSoon => isId ? 'Fitur lupa kata sandi segera hadir' : 'Forgot password feature coming soon';

  // ========== DOCTOR ==========
  String get doctor => isId ? 'Dokter' : 'Doctor';

  // ========== DOCTOR PROFILE ==========
  String get licenseNumber => isId ? 'No. SIP' : 'License No.';
  String get institution => isId ? 'Institusi' : 'Institution';
  String get specialization => isId ? 'Spesialisasi' : 'Specialization';
  String get validUntil => isId ? 'Aktif hingga' : 'Valid until';

  // ========== DOCTOR CHAT ==========
  String get noMessageYet => isId ? 'Belum ada pesan' : 'No message yet';
  String get tapToStartChat => isId ? 'Ketuk untuk mulai chat' : 'Tap to start chat';
  String get noConversation => isId ? 'Belum ada percakapan' : 'No conversations yet';
  String get startChatFromPatients => isId ? 'Mulai chat dari halaman daftar pasien.' : 'Start chat from patient list page.';
  String get sendMessageToParent => isId ? 'Kirim pesan ke orang tua...' : 'Send message to parent...';

  // ========== DOCTOR DASHBOARD ==========
  String get searchPatient => isId ? 'Cari pasien...' : 'Search patient...';
  String get needImmediateAttention => isId ? '⚠ PERLU PERHATIAN SEGERA' : '⚠ NEED IMMEDIATE ATTENTION';
  String get allPatients => isId ? 'SEMUA PASIEN' : 'ALL PATIENTS';
  String get unreadChats => isId ? 'BELUM DIBACA / DIBALAS' : 'UNREAD / UNREPLIED';
  String get readChats => isId ? 'SUDAH DIBACA' : 'READ';
  String get noChats => isId ? 'Belum ada percakapan' : 'No conversations yet';
  String get logoutConfirm => isId ? 'Apakah kamu yakin ingin logout?' : 'Are you sure you want to logout?';
  String get logout => isId ? 'Keluar' : 'Logout';
  String get cancel => isId ? 'Batal' : 'Cancel';

  // ========== DOCTOR DASHBOARD STATS ==========
  String get avgSpO2 => isId ? 'Rata-rata SpO₂ Pasien' : 'Avg SpO₂ Patients';
  String get needAttention => isId ? 'Pasien Perlu Perhatian' : 'Patients Need Attention';
  String get consultationsToday => isId ? 'Konsultasi Hari Ini' : 'Today\'s Consultations';
  String get activeAlerts => isId ? 'Alert Aktif' : 'Active Alerts';

  // ========== DOCTOR DASHBOARD TIPS ==========
  String get globalHealthUpdate => isId ? 'UPDATE KESEHATAN GLOBAL' : 'GLOBAL HEALTH UPDATE';
  String get clinicalTips => isId ? 'TIPS KLINIS HARI INI' : 'TODAY\'S CLINICAL TIPS';
  String get seasonWarning => isId ? 'PERINGATAN MUSIM' : 'SEASON WARNING';
  String get seasonWarningDesc => isId
      ? 'Musim kemarau — risiko ISPA meningkat. Pasien asma perlu pemantauan SpO₂ lebih sering.'
      : 'Dry season — risk of respiratory infections increases. Asthma patients need more frequent SpO₂ monitoring.';

  // ========== DOCTOR PROFILE ==========
  String get licenseSIP => isId ? 'LISENSI & SIP' : 'LICENSE & SIP';
  String get settings => isId ? 'PENGATURAN' : 'SETTINGS';
  String get language => isId ? 'Bahasa / Language' : 'Language';
  String get changeLanguage => isId ? 'Ubah bahasa dashboard' : 'Change dashboard language';
  String get patientAlerts => isId ? 'Notifikasi alert pasien' : 'Patient alert notifications';
  String get alertNotifications => isId ? 'Pengaturan notifikasi' : 'Notification settings';
  String get accountSecurity => isId ? 'Keamanan akun' : 'Account security';
  String get securitySettings => isId ? 'Pengaturan keamanan' : 'Security settings';

  // ========== DOCTOR NOTIFICATIONS ==========
  String get notifications => isId ? 'NOTIFIKASI PASIEN' : 'PATIENT NOTIFICATIONS';
  String get markAllRead => isId ? 'Tandai Semua' : 'Mark All Read';
  String get noNotifications => isId ? 'Tidak ada notifikasi' : 'No notifications';
  String get allNotificationsRead => isId ? '✅ Semua notifikasi ditandai telah dibaca' : '✅ All notifications marked as read';

  // ========== DOCTOR BOTTOM NAV ==========
  String get patients => isId ? 'Pasien' : 'Patients';
  String get chat => isId ? 'Chat' : 'Chat';
  String get profile => isId ? 'Profil' : 'Profile';

  // ========== DOCTOR LOGIN ==========
  String get doctorLogin => isId ? 'Login Dokter' : 'Doctor Login';
  String get doctorLoginSubtitle => isId ? 'Press Healthcare — OxyWatch Clinic' : 'Press Healthcare — OxyWatch Clinic';
  String get institutionalEmail => isId ? 'Email Institusi' : 'Institutional Email';
  String get institutionalEmailHint => isId
      ? 'nama.dokter@presuhealthcare.doc.ac.id'
      : 'doctor.name@presuhealthcare.doc.ac.id';
  String get institutionalEmailNote => isId
      ? 'Gunakan email institusi @presuhealthcare.doc.ac.id'
      : 'Use institutional email @presuhealthcare.doc.ac.id';
  String get emailMustUseDomain => isId
      ? 'Email harus menggunakan domain @presuhealthcare.doc.ac.id'
      : 'Email must use domain @presuhealthcare.doc.ac.id';
  String get emailValid => isId ? 'Email valid' : 'Email valid';
  String get loginAsDoctor => isId ? 'Masuk sebagai Dokter' : 'Login as Doctor';
  String get contactIT => isId
      ? 'Hubungi IT Press Healthcare untuk akses akun dokter'
      : 'Contact IT Press Healthcare for doctor account access';
  String get doctorPasswordHint => isId ? 'Masukkan kata sandi' : 'Enter password';

  // ========== REGISTER DOCTOR ==========
  String get registerAsDoctor => isId ? 'Daftar sebagai Dokter' : 'Register as Doctor';
  String get registerAsParent => isId ? 'Daftar sebagai Orang Tua' : 'Register as Parent';
  String get fullNameHint => isId ? 'Masukkan nama lengkap' : 'Enter full name';
  String get nameRequired => isId ? 'Nama wajib diisi' : 'Name is required';
  String get confirmPassword => isId ? 'Konfirmasi Password' : 'Confirm Password';
  String get confirmPasswordHint => isId ? 'Masukkan ulang password' : 'Re-enter password';
  String get confirmPasswordRequired => isId ? 'Konfirmasi password wajib diisi' : 'Confirm password is required';
  String get passwordNotMatch => isId ? 'Password tidak cocok' : 'Passwords do not match';
  String get registerSuccess => isId ? '✅ Register berhasil! Silakan login' : '✅ Register successful! Please login';
  String get registerFailed => isId ? '❌ Register gagal' : '❌ Register failed';
  String get alreadyHaveAccount => isId ? 'Sudah punya akun? Login' : 'Already have an account? Login';
  String get dontHaveAccount => isId ? 'Belum punya akun? Daftar' : 'Don\'t have an account? Register';

  // ========== EMERGENCY MONITOR ==========
  String get monitorDarurat => isId ? 'Monitor Darurat' : 'Emergency Monitor';
  String get aman => isId ? 'Aman' : 'Safe';
  String get kondisiNormal => isId ? 'Kondisi Normal' : 'Normal Condition';
  String get aiMonitoring => isId ? 'AI OxyWatch memantau secara aktif' : 'AI OxyWatch is actively monitoring';
  String get live => isId ? 'Live' : 'Live';
  String get ambangBatasDarurat => isId ? 'AMBANG BATAS DARURAT' : 'EMERGENCY THRESHOLD';
  String get alertKritis => isId ? 'Alert Kritis' : 'Critical Alert';
  String get simulasiDarurat => isId ? '⚠️ Simulasi Kondisi Darurat' : '⚠️ Simulate Emergency';
  String get emergency => isId ? 'DARURAT' : 'EMERGENCY';
  String get bukaInhaler => isId ? 'Buka Inhaler' : 'Open Inhaler';
  String get bantuanNapas => isId ? 'Bantuan Napas (CPR)' : 'Breathing Assistance (CPR)';
  String get panggilBantuan => isId ? 'Panggil Bantuan' : 'Call for Help';
  String get stepByStepGuide => isId ? 'Panduan langkah demi langkah' : 'Step by step guide';
  String get call119 => isId ? 'Hubungi 119 atau ambulans terdekat' : 'Call 119 or nearest ambulance';
  String get calling => isId ? 'Menghubungi' : 'Calling';
  String get calling119 => isId ? 'Sedang menghubungi layanan darurat 119' : 'Connecting to emergency service 119';
  String get helpOnTheWay => isId ? '📞 Bantuan sedang dalam perjalanan!' : '📞 Help is on the way!';
  String get step => isId ? 'Langkah' : 'Step';
  String get from => isId ? 'dari' : 'of';
  String get previous => isId ? 'Sebelumnya' : 'Previous';
  String get next => isId ? 'Selanjutnya' : 'Next';
  String get done => isId ? 'Selesai' : 'Done';
  String get inhalerSuccess => isId ? '✅ Inhaler berhasil digunakan! Tetap pantau kondisi.' : '✅ Inhaler used successfully! Keep monitoring.';
  String get cprSuccess => isId ? '🆘 Bantuan telah diberikan! Segera hubungi tenaga medis.' : '🆘 Help has been given! Contact medical personnel immediately.';

  // ========== INFO SECTION ==========
  String get infoTips => isId ? 'Info & Tips Penting' : 'Important Info & Tips';
  String get emergencyContacts => isId ? 'Kontak Darurat' : 'Emergency Contacts';
  String get ambulance => isId ? 'Ambulans' : 'Ambulance';
  String get pediatrician => isId ? 'Dokter Anak' : 'Pediatrician';
  String get call => isId ? 'Panggil' : 'Call';
  String get symptomsToWatch => isId ? 'Gejala yang Perlu Diwaspadai' : 'Symptoms to Watch';
  String get symptom1 => isId ? 'Sesak napas / napas berbunyi (wheezing)' : 'Shortness of breath / wheezing';
  String get symptom2 => isId ? 'Bibir atau wajah membiru (sianosis)' : 'Blue lips or face (cyanosis)';
  String get symptom3 => isId ? 'Batuk terus-menerus atau suara serak' : 'Persistent cough or hoarseness';
  String get symptom4 => isId ? 'Napas cepat (>40 kali/menit untuk anak)' : 'Rapid breathing (>40/min for children)';
  String get preventionTips => isId ? 'Tips Pencegahan' : 'Prevention Tips';
  String get tip1 => isId ? 'Hindari paparan asap rokok dan debu' : 'Avoid exposure to cigarette smoke and dust';
  String get tip2 => isId ? 'Pastikan inhaler selalu tersedia dan siap pakai' : 'Ensure inhaler is always available and ready';
  String get tip3 => isId ? 'Pantau kondisi secara rutin dengan OxyWatch' : 'Monitor condition regularly with OxyWatch';
  String get attackHistory => isId ? 'Riwayat Serangan Terakhir' : 'Recent Attack History';

  // ========== INHALER STEPS ==========
  String get inhalerStep1Title => isId ? 'Lepaskan Tutup' : 'Remove Cap';
  String get inhalerStep1Desc => isId ? 'Buka tutup inhaler dan kocok perlahan selama 3-5 detik' : 'Open the inhaler cap and shake gently for 3-5 seconds';
  String get inhalerStep2Title => isId ? 'Posisikan' : 'Position';
  String get inhalerStep2Desc => isId ? 'Pegang inhaler tegak, letakkan di antara jari telunjuk dan ibu jari' : 'Hold inhaler upright between thumb and index finger';
  String get inhalerStep3Title => isId ? 'Buang Napas' : 'Exhale';
  String get inhalerStep3Desc => isId ? 'Buang napas pelan melalui mulut sampai paru-paru kosong' : 'Breathe out slowly through mouth until lungs are empty';
  String get inhalerStep4Title => isId ? 'Hisap & Semprot' : 'Inhale & Spray';
  String get inhalerStep4Desc => isId ? 'Masukkan ujung ke mulut, hisap napas dalam sambil menekan inhaler' : 'Place mouthpiece in mouth, inhale deeply while pressing inhaler';
  String get inhalerStep5Title => isId ? 'Tahan Napas' : 'Hold Breath';
  String get inhalerStep5Desc => isId ? 'Tahan napas selama 10 detik, lalu hembuskan pelan' : 'Hold breath for 10 seconds, then breathe out slowly';

  // ========== CPR STEPS ==========
  String get cprStep1Title => isId ? 'Periksa Kesadaran' : 'Check Consciousness';
  String get cprStep1Desc => isId ? 'Tepuk bahu dan panggil nama anak dengan keras' : 'Tap shoulder and call child\'s name loudly';
  String get cprStep2Title => isId ? 'Panggil Bantuan' : 'Call for Help';
  String get cprStep2Desc => isId ? 'Minta orang lain untuk memanggil ambulans (119)' : 'Ask someone to call ambulance (119)';
  String get cprStep3Title => isId ? 'Buka Jalan Napas' : 'Open Airway';
  String get cprStep3Desc => isId ? 'Tengadahkan kepala, angkat dagu untuk membuka jalan napas' : 'Tilt head back, lift chin to open airway';
  String get cprStep4Title => isId ? 'Periksa Napas' : 'Check Breathing';
  String get cprStep4Desc => isId ? 'Dengar dan rasakan napas selama 10 detik' : 'Listen and feel for breathing for 10 seconds';
  String get cprStep5Title => isId ? 'Kompresi Dada' : 'Chest Compression';
  String get cprStep5Desc => isId ? 'Kompresi dada 30 kali dengan kedalaman 5 cm, kecepatan 100-120/menit' : 'Chest compression 30 times, 5 cm depth, 100-120/min speed';

  // ========== ONBOARDING ==========
  String get lengkapiProfil => isId ? 'Lengkapi Profil' : 'Complete Profile';
  String get skip => isId ? 'Skip' : 'Skip';
  String get dataDiriAnak => isId ? 'Data Diri Anak' : 'Child Personal Data';
  String get isiDataDiri => isId ? 'Isi data diri anak untuk memulai monitoring' : 'Fill child data to start monitoring';
  String get tambahkanRiwayat => isId ? 'Tambahkan riwayat kondisi kesehatan anak' : 'Add child\'s medical history';
  String get tambahKondisi => isId ? 'Tambah kondisi...' : 'Add condition...';
  String get belumAdaKondisi => isId ? 'Belum ada kondisi tambahan' : 'No additional conditions';
  String get aturNotifikasi => isId ? 'Atur notifikasi peringatan kesehatan' : 'Set health alert notifications';
  String get connectSmartwatch => isId ? 'Connect Smartwatch' : 'Connect Smartwatch';
  String get hubungkanSmartwatch => isId ? 'Hubungkan smartwatch untuk monitoring real-time' : 'Connect smartwatch for real-time monitoring';
  String get cariPerangkat => isId ? 'Cari Perangkat Bluetooth' : 'Find Bluetooth Device';
  String get scanPerangkat => isId ? 'Scan untuk mencari perangkat terdekat' : 'Scan for nearby devices';
  String get pastikanBluetooth => isId ? 'Pastikan Bluetooth aktif dan smartwatch dalam mode pairing' : 'Make sure Bluetooth is on and smartwatch is in pairing mode';
  String get skipConnect => isId ? 'Kamu bisa skip dan menghubungkan nanti di halaman Profil' : 'You can skip and connect later in Profile page';
  String get skipConnectBtn => isId ? 'Skip Connect' : 'Skip Connect';
  String get connect => isId ? 'Connect' : 'Connect';
  String get mencari => isId ? 'Mencari...' : 'Searching...';
  String get cariPerangkatBaru => isId ? 'Cari Perangkat Baru' : 'Find New Device';
  String get pilihPerangkat => isId ? 'Pilih Perangkat Bluetooth' : 'Select Bluetooth Device';
  String get menghubungkan => isId ? '🔄 Menghubungkan ke' : '🔄 Connecting to';
  String get connectSelesai => isId ? 'Connect & Selesai' : 'Connect & Done';
  String get back => isId ? 'Kembali' : 'Back';
  String get nextOnboarding => isId ? 'Next →' : 'Next →';

  // ========== SMARTWATCH CONNECT ==========
  String get tidakAdaPerangkat => isId ? 'Tidak ada perangkat terhubung' : 'No device connected';
  String get klikHubungkan => isId ? 'Klik tombol di bawah untuk menghubungkan' : 'Click the button below to connect';
  String get hubungkan => isId ? 'Hubungkan' : 'Connect';
  String get putuskan => isId ? 'Putuskan' : 'Disconnect';
  String get baterai => isId ? 'Baterai' : 'Battery';
  String get smartwatchTerhubung => isId ? '✅ Smartwatch berhasil terhubung!' : '✅ Smartwatch connected successfully!';
  String get smartwatchDiputuskan => isId ? '❌ Smartwatch diputuskan' : '❌ Smartwatch disconnected';

  // ========== PROFIL ==========
  String get patientIdCopied => isId ? 'ID Pasien disalin!' : 'Patient ID copied!';
  String get connectTo => isId ? 'Hubungkan ke' : 'Connect to';
  String get connected => isId ? 'berhasil terhubung!' : 'connected successfully!';
  String get disconnectConfirm => isId ? 'Yakin ingin memutuskan koneksi smartwatch?' : 'Are you sure you want to disconnect the smartwatch?';
  String get disconnectWarning => isId ? 'Data monitoring akan berhenti' : 'Monitoring data will stop';
  String get selectBluetooth => isId ? 'Pilih Perangkat Bluetooth' : 'Select Bluetooth Device';
  String get findNewDevice => isId ? 'Cari Perangkat Baru' : 'Find New Device';
  String get scanNearby => isId ? 'Scan untuk mencari perangkat terdekat' : 'Scan for nearby devices';
  String get searching => isId ? 'Mencari perangkat...' : 'Searching for devices...';
  String get ensureBluetooth => isId ? 'Pastikan Bluetooth aktif' : 'Make sure Bluetooth is on';
  String get activated => isId ? 'diaktifkan' : 'activated';
  String get deactivated => isId ? 'dinonaktifkan' : 'deactivated';
  String get activate => isId ? 'Aktifkan' : 'Activate';
  String get deactivate => isId ? 'Nonaktifkan' : 'Deactivate';

  // ========== ROLE SELECTION ==========
  String get whoAreYou => isId ? 'Siapa Anda?' : 'Who Are You?';
  String get selectRole => isId
      ? 'Pilih peran untuk melanjutkan ke halaman yang sesuai'
      : 'Select your role to continue to the appropriate page';
  String get imParent => isId ? 'Saya Orang Tua' : "I'm a Parent";
  String get parentSubtitle => isId
      ? 'Pantau kesehatan anak secara real-time'
      : "Monitor your child's health in real-time";
  String get imDoctor => isId ? 'Saya Dokter' : "I'm a Doctor";
  String get doctorSubtitle => isId
      ? 'Akses dashboard klinis & data pasien'
      : 'Access clinical dashboard & patient data';
  String get aiInfo => isId
      ? 'OxyWatch menggunakan AI untuk pemantauan saturasi oksigen dan detak jantung anak secara real-time.'
      : 'OxyWatch uses AI to monitor children\'s oxygen saturation and heart rate in real-time.';

  String enableAlert(String title) {
    return isId
        ? 'Apakah Anda ingin mengaktifkan alert $title?'
        : 'Do you want to enable alert $title?';
  }

  String disableAlert(String title) {
    return isId
        ? 'Apakah Anda ingin menonaktifkan alert $title?'
        : 'Do you want to disable alert $title?';
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}