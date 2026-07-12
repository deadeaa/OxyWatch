// utils/languages.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // ========== BOTTOM NAV ==========
  String get bottomDashboard => locale.languageCode == 'id' ? 'Dashboard' : 'Dashboard';
  String get bottomChat => locale.languageCode == 'id' ? 'Chat' : 'Chat';
  String get bottomRiwayat => locale.languageCode == 'id' ? 'Riwayat' : 'History';
  String get bottomProfil => locale.languageCode == 'id' ? 'Profil' : 'Profile';

  // ========== DASHBOARD ==========
  String get dashboard => locale.languageCode == 'id' ? 'Dashboard' : 'Dashboard';
  String get trend7Hari => locale.languageCode == 'id' ? 'Tren 7 Hari' : '7-Day Trend';
  String get spo2 => 'SpO₂';
  String get heartRate => locale.languageCode == 'id' ? 'Detak Jantung' : 'Heart Rate';
  String get normal => locale.languageCode == 'id' ? 'Normal' : 'Normal';
  String get riskScore => locale.languageCode == 'id' ? 'Risk Score' : 'Risk Score';
  String get lowRisk => locale.languageCode == 'id' ? 'RISIKO RENDAH' : 'LOW RISK';
  String get emergencyLabel => '🚨 Emergency';
  String get fillProfileFirst => locale.languageCode == 'id' ? 'Isi profil terlebih dahulu' : 'Fill profile first';
  String get belumAdaData => locale.languageCode == 'id' ? 'Belum ada data' : 'No data yet';
  String get belumAdaRiskScore => locale.languageCode == 'id' ? 'Belum ada data risk score' : 'No risk score data yet';
  String get terakhir => locale.languageCode == 'id' ? 'Terakhir' : 'Latest';

  // ========== EMERGENCY OVERLAY ==========
  String get emergencyCondition => locale.languageCode == 'id' ? '🚨 KONDISI DARURAT!' : '🚨 EMERGENCY!';
  String get spo2Drastis => locale.languageCode == 'id' ? 'SpO₂ turun drastis! Segera lakukan tindakan.' : 'SpO₂ dropped drastically! Take action now.';
  String get openTreatment => locale.languageCode == 'id' ? 'Buka Penanganan' : 'Open Treatment';
  String get close => locale.languageCode == 'id' ? 'Tutup' : 'Close';

  // ========== PROFIL ==========
  String get profilAnak => locale.languageCode == 'id' ? 'Profil Anak' : 'Child Profile';
  String get belumAdaProfil => locale.languageCode == 'id' ? 'Belum ada profil' : 'No profile';
  String get kodeUnikPasien => locale.languageCode == 'id' ? 'KODE UNIK PASIEN' : 'UNIQUE PATIENT CODE';
  String get belumAda => locale.languageCode == 'id' ? 'BELUM ADA' : 'NOT AVAILABLE';
  String get belumTerhubung => locale.languageCode == 'id' ? 'Belum terhubung' : 'Not connected';
  String get terhubung => locale.languageCode == 'id' ? 'Terhubung' : 'Connected';
  String get tidakTerhubung => locale.languageCode == 'id' ? 'Tidak terhubung' : 'Disconnected';
  String get dataDiri => locale.languageCode == 'id' ? 'Data Diri' : 'Personal Data';
  String get usia => locale.languageCode == 'id' ? 'Usia' : 'Age';
  String get bb => locale.languageCode == 'id' ? 'BB' : 'Weight';
  String get tb => locale.languageCode == 'id' ? 'TB' : 'Height';
  String get goldar => locale.languageCode == 'id' ? 'Gol. Darah' : 'Blood Type';
  String get riwayatKondisi => locale.languageCode == 'id' ? 'Riwayat Kondisi' : 'Medical History';
  String get pengaturanAlert => locale.languageCode == 'id' ? 'Pengaturan Alert' : 'Alert Settings';
  String get smartwatch => locale.languageCode == 'id' ? 'Smartwatch' : 'Smartwatch';
  String get profilKosong => locale.languageCode == 'id' ? 'Profil masih kosong' : 'Profile is empty';
  String get klikEdit => locale.languageCode == 'id' ? 'Klik ikon edit di atas untuk mengisi data diri' : 'Tap edit icon above to fill in data';
  String get namaLengkap => locale.languageCode == 'id' ? 'Nama Lengkap' : 'Full Name';
  String get minimal2Huruf => locale.languageCode == 'id' ? 'Minimal 2 huruf' : 'Minimum 2 characters';
  String get hanyaAngka => locale.languageCode == 'id' ? 'Hanya angka' : 'Numbers only';
  String get simpanPerubahan => locale.languageCode == 'id' ? '💾 Simpan Perubahan' : '💾 Save Changes';
  String get profilBerhasil => locale.languageCode == 'id' ? '✅ Profil berhasil diperbarui' : '✅ Profile updated successfully';
  String get namaMinimal2 => locale.languageCode == 'id' ? 'Nama harus minimal 2 huruf' : 'Name must be at least 2 characters';
  String get usiaHarusAngka => locale.languageCode == 'id' ? 'Usia harus berupa angka' : 'Age must be a number';
  String get bbHarusAngka => locale.languageCode == 'id' ? 'BB harus berupa angka' : 'Weight must be a number';
  String get tbHarusAngka => locale.languageCode == 'id' ? 'TB harus berupa angka' : 'Height must be a number';

  // ========== RIWAYAT ==========
  String get riwayatMonitoring => locale.languageCode == 'id' ? 'Riwayat Monitoring' : 'Monitoring History';
  String get rataRataSpo2 => locale.languageCode == 'id' ? 'Rata-rata SpO₂' : 'Average SpO₂';
  String get rataRataHR => locale.languageCode == 'id' ? 'Rata-rata HR' : 'Average HR';
  String get totalAlert => locale.languageCode == 'id' ? 'Total Alert' : 'Total Alerts';
  String get logPengukuran => locale.languageCode == 'id' ? 'Log Pengukuran' : 'Measurement Log';
  String get hariIni => locale.languageCode == 'id' ? 'Hari ini' : 'Today';
  String get mingguIni => locale.languageCode == 'id' ? 'Minggu ini' : 'This Week';
  String get bulanIni => locale.languageCode == 'id' ? 'Bulan ini' : 'This Month';
  String get belumAdaRiwayat => locale.languageCode == 'id' ? 'Belum ada riwayat' : 'No history yet';
  String get isiProfilDulu => locale.languageCode == 'id' ? 'Isi profil anak terlebih dahulu untuk melihat riwayat' : 'Fill child profile first to see history';

  String get jam => locale.languageCode == 'id' ? 'Jam' : 'Hours';
  String get hari => locale.languageCode == 'id' ? 'Hari' : 'Days';
  String get minggu => locale.languageCode == 'id' ? 'Minggu' : 'Weeks';
  String get status => locale.languageCode == 'id' ? 'Status' : 'Status';
  String get ringkasanHarian => locale.languageCode == 'id' ? 'Ringkasan Harian' : 'Daily Summary';
  String get ringkasanMingguan => locale.languageCode == 'id' ? 'Ringkasan Mingguan' : 'Weekly Summary';
  String get exportPDF => locale.languageCode == 'id' ? 'Export PDF' : 'Export PDF';
  String get notifJika => locale.languageCode == 'id' ? 'Notif jika' : 'Notify if';
  String get tahun => locale.languageCode == 'id' ? 'tahun' : 'years';
  String get belumDiisi => locale.languageCode == 'id' ? 'Belum diisi' : 'Not filled';
  String get rataRata => locale.languageCode == 'id' ? 'Rata-rata' : 'Average';
  String get critical => locale.languageCode == 'id' ? 'Kritis' : 'Critical';

  // ========== EXPORT PDF ==========
  String get exportPDFTitle => locale.languageCode == 'id' ? '📄 Export PDF' : '📄 Export PDF';
  String get exportPDFSubtitle => locale.languageCode == 'id' ? 'Export riwayat monitoring dalam format PDF' : 'Export monitoring history as PDF';
  String get exportPDFInfo => locale.languageCode == 'id' ? 'PDF akan mencakup semua data log pengukuran' : 'PDF will include all measurement log data';
  String get exportPDFSuccess => locale.languageCode == 'id' ? '✅ PDF berhasil diexport!' : '✅ PDF exported successfully!';

  // ========== HARI ==========
  String get senin => locale.languageCode == 'id' ? 'Sen' : 'Mon';
  String get selasa => locale.languageCode == 'id' ? 'Sel' : 'Tue';
  String get rabu => locale.languageCode == 'id' ? 'Rab' : 'Wed';
  String get kamis => locale.languageCode == 'id' ? 'Kam' : 'Thu';
  String get jumat => locale.languageCode == 'id' ? 'Jum' : 'Fri';
  String get sabtu => locale.languageCode == 'id' ? 'Sab' : 'Sat';
  String get mingguu => locale.languageCode == 'id' ? 'Min' : 'Sun';

  // ========== STATUS ==========
  String get warning => locale.languageCode == 'id' ? 'Warning' : 'Warning';
  String get kritis => locale.languageCode == 'id' ? 'KRITIS' : 'CRITICAL';
  String get statusLabel => locale.languageCode == 'id' ? 'Status' : 'Status';

  // ========== CHAT ==========
  String get chatDenganDokter => locale.languageCode == 'id' ? 'Chat dengan Dokter' : 'Chat with Doctor';
  String get online => locale.languageCode == 'id' ? 'Online' : 'Online';
  String get offline => locale.languageCode == 'id' ? 'Offline' : 'Offline';
  String get tulisPesan => locale.languageCode == 'id' ? 'Tulis pesan ke dokter...' : 'Write a message to doctor...';
  String get vital => locale.languageCode == 'id' ? 'Vital' : 'Vital';
  String get dataVital => locale.languageCode == 'id' ? 'DATA VITAL' : 'VITAL DATA';
  String get snapshot => locale.languageCode == 'id' ? 'Snapshot' : 'Snapshot';
  String get semuaChatTerbaca => locale.languageCode == 'id' ? 'Semua chat lain sudah terbaca' : 'All other chats have been read';
  String get dokterOnlineLainnya => locale.languageCode == 'id' ? 'DOKTER ONLINE LAINNYA' : 'OTHER ONLINE DOCTORS';

// ========== NOTIFIKASI ==========
  String get notifikasi => locale.languageCode == 'id' ? 'Notifikasi' : 'Notifications';
  String get belumDibaca => locale.languageCode == 'id' ? 'BELUM DIBACA' : 'UNREAD';
  String get sudahDibaca => locale.languageCode == 'id' ? 'SUDAH DIBACA' : 'READ';
  String get tandaiSemua => locale.languageCode == 'id' ? 'Tandai Semua' : 'Mark All Read';
  String get tidakAdaNotifikasi => locale.languageCode == 'id' ? 'Tidak ada notifikasi' : 'No notifications';
  String get belumAdaNotifikasi => locale.languageCode == 'id' ? 'Belum ada notifikasi masuk' : 'No notifications yet';
  String get semuaNotifikasiDibaca => locale.languageCode == 'id' ? '✅ Semua notifikasi ditandai telah dibaca' : '✅ All notifications marked as read';
  String get notifikasiBaru => locale.languageCode == 'id' ? '🔔 Notifikasi Baru' : '🔔 New Notification';
  String get tandaiDibaca => locale.languageCode == 'id' ? 'Tandai Dibaca' : 'Mark as Read';
  String get lihatDetail => locale.languageCode == 'id' ? 'Lihat Detail' : 'View Detail';
  String get segeraTindakan => locale.languageCode == 'id' ? 'Segera lakukan tindakan!' : 'Take action now!';
  String get informasi => locale.languageCode == 'id' ? 'Informasi' : 'Info';
  String get tutup => locale.languageCode == 'id' ? 'Tutup' : 'Close';
  String get bukaMonitor => locale.languageCode == 'id' ? 'Buka Monitor' : 'Open Monitor';
  String get kembali => locale.languageCode == 'id' ? 'Kembali' : 'Back';
  String get perluDipantau => locale.languageCode == 'id' ? 'Perlu pemantauan lebih lanjut' : 'Further monitoring needed';
  String get dataNormal => locale.languageCode == 'id' ? 'Data vital dalam batas normal' : 'Vital signs within normal range';

  // ========== PENGATURAN ==========
  String get pengaturan => locale.languageCode == 'id' ? 'Pengaturan' : 'Settings';
  String get bahasa => locale.languageCode == 'id' ? 'Bahasa / Language' : 'Language';
  String get ubahBahasa => locale.languageCode == 'id' ? 'Ubah bahasa tampilan' : 'Change display language';
  String get notifikasiKlinis => locale.languageCode == 'id' ? 'Notifikasi klinis' : 'Clinical notifications';
  String get privasiDataAnak => locale.languageCode == 'id' ? 'Privasi data anak' : 'Child data privacy';
  String get bantuanFAQ => locale.languageCode == 'id' ? 'Bantuan & FAQ' : 'Help & FAQ';
  String get hapusProfil => locale.languageCode == 'id' ? 'Hapus Profil' : 'Delete Profile';
  String get hapusProfilPermanen => locale.languageCode == 'id' ? 'Semua data anak akan dihapus permanen. Yakin ingin melanjutkan?' : 'All child data will be permanently deleted. Are you sure?';
  String get batal => locale.languageCode == 'id' ? 'Batal' : 'Cancel';
  String get hapus => locale.languageCode == 'id' ? 'Hapus' : 'Delete';
  String get profilDihapus => locale.languageCode == 'id' ? '✅ Profil berhasil dihapus' : '✅ Profile deleted successfully';
  String get bahasaDiubah => locale.languageCode == 'id' ? 'Bahasa diubah ke' : 'Language changed to';
  String get indonesia => locale.languageCode == 'id' ? 'Indonesia' : 'Indonesian';
  String get english => locale.languageCode == 'id' ? 'English' : 'English';

  // ========== LOGIN ==========
  String get login => locale.languageCode == 'id' ? 'Login' : 'Login';
  String get daftar => locale.languageCode == 'id' ? 'Daftar' : 'Register';
  String get email => locale.languageCode == 'id' ? 'Email' : 'Email';
  String get password => locale.languageCode == 'id' ? 'Password' : 'Password';
  String get belumPunyaAkun => locale.languageCode == 'id' ? 'Belum punya akun?' : 'Don\'t have an account?';
  String get sudahPunyaAkun => locale.languageCode == 'id' ? 'Sudah punya akun?' : 'Already have an account?';

  // ========== EMERGENCY MONITOR ==========
  String get monitorDarurat => locale.languageCode == 'id' ? 'Monitor Darurat' : 'Emergency Monitor';
  String get aman => locale.languageCode == 'id' ? 'Aman' : 'Safe';
  String get kondisiNormal => locale.languageCode == 'id' ? 'Kondisi Normal' : 'Normal Condition';
  String get aiMonitoring => locale.languageCode == 'id' ? 'AI OxyWatch memantau secara aktif' : 'AI OxyWatch is actively monitoring';
  String get live => locale.languageCode == 'id' ? 'Live' : 'Live';
  String get ambangBatasDarurat => locale.languageCode == 'id' ? 'AMBANG BATAS DARURAT' : 'EMERGENCY THRESHOLD';
  String get alertKritis => locale.languageCode == 'id' ? 'Alert Kritis' : 'Critical Alert';
  String get simulasiDarurat => locale.languageCode == 'id' ? '⚠️ Simulasi Kondisi Darurat' : '⚠️ Simulate Emergency';
  String get emergency => locale.languageCode == 'id' ? 'DARURAT' : 'EMERGENCY';
  String get bukaInhaler => locale.languageCode == 'id' ? 'Buka Inhaler' : 'Open Inhaler';
  String get bantuanNapas => locale.languageCode == 'id' ? 'Bantuan Napas (CPR)' : 'Breathing Assistance (CPR)';
  String get panggilBantuan => locale.languageCode == 'id' ? 'Panggil Bantuan' : 'Call for Help';
  String get stepByStepGuide => locale.languageCode == 'id' ? 'Panduan langkah demi langkah' : 'Step by step guide';
  String get call119 => locale.languageCode == 'id' ? 'Hubungi 119 atau ambulans terdekat' : 'Call 119 or nearest ambulance';
  String get calling => locale.languageCode == 'id' ? 'Menghubungi' : 'Calling';
  String get calling119 => locale.languageCode == 'id' ? 'Sedang menghubungi layanan darurat 119' : 'Connecting to emergency service 119';
  String get helpOnTheWay => locale.languageCode == 'id' ? '📞 Bantuan sedang dalam perjalanan!' : '📞 Help is on the way!';
  String get step => locale.languageCode == 'id' ? 'Langkah' : 'Step';
  String get from => locale.languageCode == 'id' ? 'dari' : 'of';  // Ganti 'of' jadi 'from'
  String get previous => locale.languageCode == 'id' ? 'Sebelumnya' : 'Previous';
  String get next => locale.languageCode == 'id' ? 'Selanjutnya' : 'Next';
  String get done => locale.languageCode == 'id' ? 'Selesai' : 'Done';
  String get inhalerSuccess => locale.languageCode == 'id' ? '✅ Inhaler berhasil digunakan! Tetap pantau kondisi.' : '✅ Inhaler used successfully! Keep monitoring.';
  String get cprSuccess => locale.languageCode == 'id' ? '🆘 Bantuan telah diberikan! Segera hubungi tenaga medis.' : '🆘 Help has been given! Contact medical personnel immediately.';

  // ========== INFO SECTION ==========
  String get infoTips => locale.languageCode == 'id' ? 'Info & Tips Penting' : 'Important Info & Tips';
  String get emergencyContacts => locale.languageCode == 'id' ? 'Kontak Darurat' : 'Emergency Contacts';
  String get ambulance => locale.languageCode == 'id' ? 'Ambulans' : 'Ambulance';
  String get pediatrician => locale.languageCode == 'id' ? 'Dokter Anak' : 'Pediatrician';
  String get call => locale.languageCode == 'id' ? 'Panggil' : 'Call';
  String get symptomsToWatch => locale.languageCode == 'id' ? 'Gejala yang Perlu Diwaspadai' : 'Symptoms to Watch';
  String get symptom1 => locale.languageCode == 'id' ? 'Sesak napas / napas berbunyi (wheezing)' : 'Shortness of breath / wheezing';
  String get symptom2 => locale.languageCode == 'id' ? 'Bibir atau wajah membiru (sianosis)' : 'Blue lips or face (cyanosis)';
  String get symptom3 => locale.languageCode == 'id' ? 'Batuk terus-menerus atau suara serak' : 'Persistent cough or hoarseness';
  String get symptom4 => locale.languageCode == 'id' ? 'Napas cepat (>40 kali/menit untuk anak)' : 'Rapid breathing (>40/min for children)';
  String get preventionTips => locale.languageCode == 'id' ? 'Tips Pencegahan' : 'Prevention Tips';
  String get tip1 => locale.languageCode == 'id' ? 'Hindari paparan asap rokok dan debu' : 'Avoid exposure to cigarette smoke and dust';
  String get tip2 => locale.languageCode == 'id' ? 'Pastikan inhaler selalu tersedia dan siap pakai' : 'Ensure inhaler is always available and ready';
  String get tip3 => locale.languageCode == 'id' ? 'Pantau kondisi secara rutin dengan OxyWatch' : 'Monitor condition regularly with OxyWatch';
  String get attackHistory => locale.languageCode == 'id' ? 'Riwayat Serangan Terakhir' : 'Recent Attack History';

  // ========== INHALER STEPS ==========
  String get inhalerStep1Title => locale.languageCode == 'id' ? 'Lepaskan Tutup' : 'Remove Cap';
  String get inhalerStep1Desc => locale.languageCode == 'id' ? 'Buka tutup inhaler dan kocok perlahan selama 3-5 detik' : 'Open the inhaler cap and shake gently for 3-5 seconds';
  String get inhalerStep2Title => locale.languageCode == 'id' ? 'Posisikan' : 'Position';
  String get inhalerStep2Desc => locale.languageCode == 'id' ? 'Pegang inhaler tegak, letakkan di antara jari telunjuk dan ibu jari' : 'Hold inhaler upright between thumb and index finger';
  String get inhalerStep3Title => locale.languageCode == 'id' ? 'Buang Napas' : 'Exhale';
  String get inhalerStep3Desc => locale.languageCode == 'id' ? 'Buang napas pelan melalui mulut sampai paru-paru kosong' : 'Breathe out slowly through mouth until lungs are empty';
  String get inhalerStep4Title => locale.languageCode == 'id' ? 'Hisap & Semprot' : 'Inhale & Spray';
  String get inhalerStep4Desc => locale.languageCode == 'id' ? 'Masukkan ujung ke mulut, hisap napas dalam sambil menekan inhaler' : 'Place mouthpiece in mouth, inhale deeply while pressing inhaler';
  String get inhalerStep5Title => locale.languageCode == 'id' ? 'Tahan Napas' : 'Hold Breath';
  String get inhalerStep5Desc => locale.languageCode == 'id' ? 'Tahan napas selama 10 detik, lalu hembuskan pelan' : 'Hold breath for 10 seconds, then breathe out slowly';

  // ========== CPR STEPS ==========
  String get cprStep1Title => locale.languageCode == 'id' ? 'Periksa Kesadaran' : 'Check Consciousness';
  String get cprStep1Desc => locale.languageCode == 'id' ? 'Tepuk bahu dan panggil nama anak dengan keras' : 'Tap shoulder and call child\'s name loudly';
  String get cprStep2Title => locale.languageCode == 'id' ? 'Panggil Bantuan' : 'Call for Help';
  String get cprStep2Desc => locale.languageCode == 'id' ? 'Minta orang lain untuk memanggil ambulans (119)' : 'Ask someone to call ambulance (119)';
  String get cprStep3Title => locale.languageCode == 'id' ? 'Buka Jalan Napas' : 'Open Airway';
  String get cprStep3Desc => locale.languageCode == 'id' ? 'Tengadahkan kepala, angkat dagu untuk membuka jalan napas' : 'Tilt head back, lift chin to open airway';
  String get cprStep4Title => locale.languageCode == 'id' ? 'Periksa Napas' : 'Check Breathing';
  String get cprStep4Desc => locale.languageCode == 'id' ? 'Dengar dan rasakan napas selama 10 detik' : 'Listen and feel for breathing for 10 seconds';
  String get cprStep5Title => locale.languageCode == 'id' ? 'Kompresi Dada' : 'Chest Compression';
  String get cprStep5Desc => locale.languageCode == 'id' ? 'Kompresi dada 30 kali dengan kedalaman 5 cm, kecepatan 100-120/menit' : 'Chest compression 30 times, 5 cm depth, 100-120/min speed';

  // ========== ONBOARDING ==========
  String get lengkapiProfil => locale.languageCode == 'id' ? 'Lengkapi Profil' : 'Complete Profile';
  String get skip => locale.languageCode == 'id' ? 'Skip' : 'Skip';
  String get dataDiriAnak => locale.languageCode == 'id' ? 'Data Diri Anak' : 'Child Personal Data';
  String get isiDataDiri => locale.languageCode == 'id' ? 'Isi data diri anak untuk memulai monitoring' : 'Fill child data to start monitoring';
  String get tambahkanRiwayat => locale.languageCode == 'id' ? 'Tambahkan riwayat kondisi kesehatan anak' : 'Add child\'s medical history';
  String get tambahKondisi => locale.languageCode == 'id' ? 'Tambah kondisi...' : 'Add condition...';
  String get belumAdaKondisi => locale.languageCode == 'id' ? 'Belum ada kondisi tambahan' : 'No additional conditions';
  String get aturNotifikasi => locale.languageCode == 'id' ? 'Atur notifikasi peringatan kesehatan' : 'Set health alert notifications';
  String get connectSmartwatch => locale.languageCode == 'id' ? 'Connect Smartwatch' : 'Connect Smartwatch';
  String get hubungkanSmartwatch => locale.languageCode == 'id' ? 'Hubungkan smartwatch untuk monitoring real-time' : 'Connect smartwatch for real-time monitoring';
  String get cariPerangkat => locale.languageCode == 'id' ? 'Cari Perangkat Bluetooth' : 'Find Bluetooth Device';
  String get scanPerangkat => locale.languageCode == 'id' ? 'Scan untuk mencari perangkat terdekat' : 'Scan for nearby devices';
  String get pastikanBluetooth => locale.languageCode == 'id' ? 'Pastikan Bluetooth aktif dan smartwatch dalam mode pairing' : 'Make sure Bluetooth is on and smartwatch is in pairing mode';
  String get skipConnect => locale.languageCode == 'id' ? 'Kamu bisa skip dan menghubungkan nanti di halaman Profil' : 'You can skip and connect later in Profile page';
  String get skipConnectBtn => locale.languageCode == 'id' ? 'Skip Connect' : 'Skip Connect';
  String get connect => locale.languageCode == 'id' ? 'Connect' : 'Connect';
  String get mencari => locale.languageCode == 'id' ? 'Mencari...' : 'Searching...';
  String get cariPerangkatBaru => locale.languageCode == 'id' ? 'Cari Perangkat Baru' : 'Find New Device';
  String get pilihPerangkat => locale.languageCode == 'id' ? 'Pilih Perangkat Bluetooth' : 'Select Bluetooth Device';
  String get menghubungkan => locale.languageCode == 'id' ? '🔄 Menghubungkan ke' : '🔄 Connecting to';
  String get connectSelesai => locale.languageCode == 'id' ? 'Connect & Selesai' : 'Connect & Done';
  String get back => locale.languageCode == 'id' ? 'Kembali' : 'Back';
  String get nextOnboarding => locale.languageCode == 'id' ? 'Next →' : 'Next →';

  // ========== SMARTWATCH CONNECT ==========
  String get tidakAdaPerangkat => locale.languageCode == 'id' ? 'Tidak ada perangkat terhubung' : 'No device connected';
  String get klikHubungkan => locale.languageCode == 'id' ? 'Klik tombol di bawah untuk menghubungkan' : 'Click the button below to connect';
  String get hubungkan => locale.languageCode == 'id' ? 'Hubungkan' : 'Connect';
  String get putuskan => locale.languageCode == 'id' ? 'Putuskan' : 'Disconnect';
  String get baterai => locale.languageCode == 'id' ? 'Baterai' : 'Battery';
  String get smartwatchTerhubung => locale.languageCode == 'id' ? '✅ Smartwatch berhasil terhubung!' : '✅ Smartwatch connected successfully!';
  String get smartwatchDiputuskan => locale.languageCode == 'id' ? '❌ Smartwatch diputuskan' : '❌ Smartwatch disconnected';

// ========== PROFIL ==========
  String get patientIdCopied => locale.languageCode == 'id' ? 'ID Pasien disalin!' : 'Patient ID copied!';
  String get connectTo => locale.languageCode == 'id' ? 'Hubungkan ke' : 'Connect to';
  String get connected => locale.languageCode == 'id' ? 'berhasil terhubung!' : 'connected successfully!';
  String get disconnectConfirm => locale.languageCode == 'id' ? 'Yakin ingin memutuskan koneksi smartwatch?' : 'Are you sure you want to disconnect the smartwatch?';
  String get disconnectWarning => locale.languageCode == 'id' ? 'Data monitoring akan berhenti' : 'Monitoring data will stop';
  String get selectBluetooth => locale.languageCode == 'id' ? 'Pilih Perangkat Bluetooth' : 'Select Bluetooth Device';
  String get findNewDevice => locale.languageCode == 'id' ? 'Cari Perangkat Baru' : 'Find New Device';
  String get scanNearby => locale.languageCode == 'id' ? 'Scan untuk mencari perangkat terdekat' : 'Scan for nearby devices';
  String get searching => locale.languageCode == 'id' ? 'Mencari perangkat...' : 'Searching for devices...';
  String get ensureBluetooth => locale.languageCode == 'id' ? 'Pastikan Bluetooth aktif' : 'Make sure Bluetooth is on';
  String get activated => locale.languageCode == 'id' ? 'diaktifkan' : 'activated';
  String get deactivated => locale.languageCode == 'id' ? 'dinonaktifkan' : 'deactivated';
  String get activate => locale.languageCode == 'id' ? 'Aktifkan' : 'Activate';
  String get deactivate => locale.languageCode == 'id' ? 'Nonaktifkan' : 'Deactivate';

  String enableAlert(String title) {
    return locale.languageCode == 'id'
        ? 'Apakah Anda ingin mengaktifkan alert $title?'
        : 'Do you want to enable alert $title?';
  }

  String disableAlert(String title) {
    return locale.languageCode == 'id'
        ? 'Apakah Anda ingin menonaktifkan alert $title?'
        : 'Do you want to disable alert $title?';
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}