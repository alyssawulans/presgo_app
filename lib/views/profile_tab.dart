import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/views/edit_profile_view.dart';
import 'package:presgo_app/config/app_settings.dart';
import 'package:presgo_app/services/storage_service.dart';
import 'package:presgo_app/views/login_view.dart';

class ProfileTab extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationEnabled = true;

  void _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131738) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF90A3BF)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    final Color subTextColor = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);
    final Color borderColor = isDark
        ? const Color(0xFF2E66FF).withOpacity(0.15)
        : Colors.grey.withOpacity(0.2);

    String joinedDate = '---';
    if (widget.user?.createdAt != null) {
      try {
        DateTime dt = DateTime.parse(widget.user!.createdAt!);
        joinedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
      } catch (_) {}
    }

    final isMale = widget.user?.jenisKelamin == 'L';

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
                // Profile header card with Avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF131738), const Color(0xFF1E244C)]
                          : [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2E66FF),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2E66FF,
                                  ).withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  _getSanitizedImageUrl(
                                        widget.user?.profilePhoto,
                                      ) !=
                                      null
                                  ? Image.network(
                                      "${_getSanitizedImageUrl(widget.user!.profilePhoto!)}?v=${DateTime.now().millisecondsSinceEpoch}",
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: isDark
                                          ? const Color(0xFF080C24)
                                          : Colors.grey.shade100,
                                      child: Icon(
                                        isMale
                                            ? Icons.face_rounded
                                            : Icons.face_3_rounded,
                                        size: 64,
                                        color: const Color(0xFF2E66FF),
                                      ),
                                    ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.user?.name ?? '---',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.user?.email ?? '---',
                        style: TextStyle(fontSize: 13, color: subTextColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Verified Student',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details List Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        'Nama Lengkap',
                        widget.user?.name ?? '---',
                        textColor,
                        subTextColor,
                      ),
                      _buildDivider(borderColor),
                      _buildInfoRow(
                        'Email',
                        widget.user?.email ?? '---',
                        textColor,
                        subTextColor,
                      ),
                      _buildDivider(borderColor),
                      _buildInfoRow(
                        'Batch',
                        widget.user?.batchName ??
                            'Batch ${widget.user?.batchId ?? "---"}',
                        textColor,
                        subTextColor,
                      ),
                      _buildDivider(borderColor),
                      _buildInfoRow(
                        'Training',
                        widget.user?.trainingName ??
                            'Training ${widget.user?.trainingId ?? "---"}',
                        textColor,
                        subTextColor,
                      ),
                      _buildDivider(borderColor),
                      _buildInfoRow(
                        'Bergabung Sejak',
                        joinedDate,
                        textColor,
                        subTextColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Edit Profile Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E66FF), Color(0xFF8F30FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        if (widget.user != null) {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileView(user: widget.user!),
                            ),
                          );
                          if (updated == true) {
                            widget.onProfileUpdated();
                          }
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Header
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Preferensi Section
                Text(
                  'Preferensi',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
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
                      _buildSettingsDivider(borderColor),
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

                // Akun Section
                Text(
                  'Akun',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
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
                            const SnackBar(
                              content: Text(
                                'Fitur Ubah Password dalam pengembangan.',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildSettingsDivider(borderColor),
                      _buildSettingsTile(
                        icon: Icons.security_rounded,
                        title: 'Keamanan',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur Keamanan dalam pengembangan.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lainnya Section
                Text(
                  'Lainnya',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
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
                            const SnackBar(
                              content: Text(
                                'Fitur Bantuan dalam pengembangan.',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildSettingsDivider(borderColor),
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
                            applicationIcon: const Icon(
                              Icons.fingerprint_rounded,
                              color: Color(0xFF2E66FF),
                              size: 48,
                            ),
                            children: const [
                              Text('Aplikasi Presensi Pegawai & Peserta.'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _logout,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color subTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: subTextColor)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getSanitizedImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    String cleaned = url;
    cleaned = cleaned.replaceAll(
      'http://127.0.0.1:8000',
      'https://appabsensi.mobileprojp.com',
    );
    cleaned = cleaned.replaceAll(
      'http://localhost:8000',
      'https://appabsensi.mobileprojp.com',
    );
    cleaned = cleaned.replaceAll(
      'http://localhost',
      'https://appabsensi.mobileprojp.com',
    );

    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      if (cleaned.startsWith('/')) {
        cleaned = 'https://appabsensi.mobileprojp.com$cleaned';
      } else {
        cleaned = 'https://appabsensi.mobileprojp.com/$cleaned';
      }
    }
    return cleaned;
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(color: borderColor, height: 24, thickness: 1);
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
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: subTextColor,
        size: 13,
      ),
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
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E66FF),
        activeTrackColor: const Color(0xFF2E66FF).withOpacity(0.3),
        inactiveThumbColor: isDark
            ? const Color(0xFF90A3BF)
            : Colors.grey.shade400,
        inactiveTrackColor: isDark
            ? const Color(0xFF1E244C)
            : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildSettingsDivider(Color borderColor) {
    return Divider(
      color: borderColor,
      height: 1,
      indent: 16,
      endIndent: 16,
      thickness: 1,
    );
  }
}
