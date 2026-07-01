import 'package:flutter/material.dart';
import 'package:presgo_app/config/app_settings.dart';
import 'package:presgo_app/services/storage_service.dart';
import 'package:presgo_app/views/login_view.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notificationEnabled = true;

  void _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131738) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(color: isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await StorageService.clearToken();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);

    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final isDarkMode = settings.themeMode == ThemeMode.dark;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
  
                // Akun Section
                Text(
                  'Akun',
                  style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ubah Password',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Ubah Password dalam pengembangan.')),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.security_rounded,
                        title: 'Keamanan',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Keamanan dalam pengembangan.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
  
                // Preferensi Section
                Text(
                  'Preferensi',
                  style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Mode Gelap',
                        value: isDarkMode,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onChanged: (val) {
                          AppSettingsController.instance.updateTheme(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        value: _notificationEnabled,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onChanged: (val) {
                          setState(() {
                            _notificationEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
  
                // Lainnya Section
                Text(
                  'Lainnya',
                  style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Bantuan dalam pengembangan.')),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'PresGo Absensi',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.fingerprint_rounded, color: Color(0xFF2E66FF), size: 48),
                            children: const [
                              Text('Aplikasi Presensi Pegawai & Peserta PPKD Jakarta Barat.'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
  
                // Logout Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _logout,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E66FF), size: 22),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: subTextColor, size: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color textColor,
    required Color subTextColor,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E66FF), size: 22),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E66FF),
        activeTrackColor: const Color(0xFF2E66FF).withOpacity(0.3),
        inactiveThumbColor: isDark ? const Color(0xFF90A3BF) : Colors.grey.shade400,
        inactiveTrackColor: isDark ? const Color(0xFF1E244C) : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFF2E66FF).withOpacity(0.08),
      height: 1,
      indent: 16,
      endIndent: 16,
      thickness: 1,
    );
  }
}
