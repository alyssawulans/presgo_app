import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/views/edit_profile_view.dart';

class ProfileTab extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF2E66FF).withOpacity(0.15) : Colors.grey.withOpacity(0.2);

    String joinedDate = '---';
    if (user?.createdAt != null) {
      try {
        DateTime dt = DateTime.parse(user!.createdAt!);
        joinedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
      } catch (_) {}
    }

    final isMale = user?.jenisKelamin == 'L';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
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
                  )
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
                          border: Border.all(color: const Color(0xFF2E66FF), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E66FF).withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: _getSanitizedImageUrl(user?.profilePhoto) != null
                              ? Image.network(
                                  "${_getSanitizedImageUrl(user!.profilePhoto!)}?v=${DateTime.now().millisecondsSinceEpoch}",
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: isDark ? const Color(0xFF080C24) : Colors.grey.shade100,
                                  child: Icon(
                                    isMale ? Icons.face_rounded : Icons.face_3_rounded,
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
                    user?.name ?? '---',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '---',
                    style: TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 14),
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
                  _buildInfoRow('Nama Lengkap', user?.name ?? '---', textColor, subTextColor),
                  _buildDivider(borderColor),
                  _buildInfoRow('Email', user?.email ?? '---', textColor, subTextColor),
                  _buildDivider(borderColor),
                  _buildInfoRow('Batch', user?.batchName ?? 'Batch ${user?.batchId ?? "---"}', textColor, subTextColor),
                  _buildDivider(borderColor),
                  _buildInfoRow('Training', user?.trainingName ?? 'Training ${user?.trainingId ?? "---"}', textColor, subTextColor),
                  _buildDivider(borderColor),
                  _buildInfoRow('Bergabung Sejak', joinedDate, textColor, subTextColor),
                ],
              ),
            ),
            const SizedBox(height: 30),
  
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
                    if (user != null) {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileView(user: user!),
                        ),
                      );
                      if (updated == true) {
                        onProfileUpdated();
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
            ),
          ),
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
    cleaned = cleaned.replaceAll('http://127.0.0.1:8000', 'https://appabsensi.mobileprojp.com');
    cleaned = cleaned.replaceAll('http://localhost:8000', 'https://appabsensi.mobileprojp.com');
    cleaned = cleaned.replaceAll('http://localhost', 'https://appabsensi.mobileprojp.com');

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
    return Divider(
      color: borderColor,
      height: 24,
      thickness: 1,
    );
  }
}
