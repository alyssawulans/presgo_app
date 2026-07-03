import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:presgo_app/models/attendance_model.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/services/location_service.dart';
import 'package:presgo_app/views/absen_slider_view.dart';
import 'package:presgo_app/views/izin_view.dart';

class HomeTab extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onNavigateToHistory;

  const HomeTab({
    super.key,
    required this.user,
    required this.onNavigateToHistory,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _history = [];
  bool _isLoadingToday = true;
  bool _isLoadingHistory = true;

  int _totalWorkDays = 24;
  int _hadir = 0;
  int _terlambat = 0;
  int _alpha = 0;
  int _izin = 0;

  String _locationText = 'Mencari lokasi...';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          final parts = loc.address.split(', ');
          if (parts.length > 2) {
            _locationText = '${parts[0]}, ${parts[1]}';
          } else {
            _locationText = loc.address;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Lokasi tidak terdeteksi';
        });
      }
    }
  }

  Future<void> _loadData() async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Future.wait([
      ApiService.instance
          .getTodayAttendance(todayStr)
          .then((val) {
            if (mounted) {
              setState(() {
                _todayAttendance = val;
                _isLoadingToday = false;
              });
            }
          })
          .catchError((_) {
            if (mounted) setState(() => _isLoadingToday = false);
          }),
      ApiService.instance
          .getHistory()
          .then((list) {
            if (mounted) {
              setState(() {
                _history = list;
                _calculateStats(list);
                _isLoadingHistory = false;
              });
            }
          })
          .catchError((_) {
            if (mounted) setState(() => _isLoadingHistory = false);
          }),
    ]);
  }

  void _calculateStats(List<AttendanceModel> list) {
    int h = 0;
    int t = 0;
    int i = 0;
    int a = 0;

    for (var att in list) {
      if (att.status == 'izin') {
        i++;
      } else if (att.status == 'masuk') {
        h++;
        if (att.checkInTime != null) {
          try {
            final parts = att.checkInTime!.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (hour > 8 || (hour == 8 && minute > 0)) {
              t++;
            }
          } catch (_) {}
        }
      }
    }

    _totalWorkDays = list.isEmpty ? 24 : list.length + 3;
    if (_totalWorkDays < (h + i)) {
      _totalWorkDays = h + i + 2;
    }
    a = _totalWorkDays - h - i;
    if (a < 0) a = 0;

    setState(() {
      _hadir = h - t;
      _terlambat = t;
      _izin = i;
      _alpha = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat(
      'd MMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);

    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    if (hour >= 11 && hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore';
    } else if (hour >= 18 || hour < 5) {
      greeting = 'Selamat Malam';
    }

    final headerGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF636ddb), Color(0xFF6066f8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2E66FF),
      backgroundColor: cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ─── Premium Header Card ───
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 40,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: headerGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.user?.name ?? "Pengguna"} 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Semangat hari ini! Konsistensi adalah kunci kesuksesan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '$_locationText • $todayFormatted',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mascot Image on the right side
                      SizedBox(
                        height: 170,
                        width: 170,
                        child: Lottie.asset(
                          'assets/animations/haimaskot.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                  // Floating notification button
                  Positioned(
                    top: 10,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body content (shifts up to overlap header) ───
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Status Card
                    _buildTodayStatusCard(),

                    const SizedBox(height: 24),
                    // Quick Actions Label
                    Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Actions Row - 3 buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPremiumActionBtn(
                            title: 'Absen\nMasuk',
                            icon: Icons.login_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AbsenSliderView(
                                    isCheckIn: true,
                                    onSuccess: _loadData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildPremiumActionBtn(
                            title: 'Absen\nPulang',
                            icon: Icons.logout_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AbsenSliderView(
                                    isCheckIn: false,
                                    onSuccess: _loadData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildPremiumActionBtn(
                            title: 'Ajukan\nIzin',
                            icon: Icons.event_available_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8F30FF), Color(0xFF6D28D9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IzinView(onSuccess: _loadData),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistik Bulanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Bulan Ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Statistics Card
                    _buildStatsCard(),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Terakhir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onNavigateToHistory,
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E66FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Today's Logs and History
                    _buildRecentLogsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatusCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);
    final Color borderColor = isDark
        ? const Color(0xFF2E66FF).withOpacity(0.15)
        : Colors.grey.withOpacity(0.2);

    if (_isLoadingToday) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E66FF)),
        ),
      );
    }

    final Color statusColor = const Color(0xFF1E244C);

    final hasCheckedIn = _todayAttendance != null;
    final inTime = _todayAttendance?.checkInTime ?? '--:--';
    final outTime = _todayAttendance?.checkOutTime ?? '--:--';

    return Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isDark ? 0.75 : 1.0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: hasCheckedIn
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                      boxShadow: hasCheckedIn
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasCheckedIn
                        ? (_todayAttendance?.status == 'izin'
                              ? 'Status: Izin'
                              : 'Status: Masuk Kerja')
                        : 'Status: Belum Absen',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? statusColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasCheckedIn
                      ? (_todayAttendance?.status == 'izin' ? 'IZIN' : 'AKTIF')
                      : 'BELUM AKTIF',
                  style: TextStyle(
                    color: hasCheckedIn
                        ? (_todayAttendance?.status == 'izin'
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF10B981))
                        : Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeTrackColumn(
                  label: 'Absen Masuk',
                  time: inTime,
                  icon: Icons.login_rounded,
                  iconColor: const Color(0xFF10B981),
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
              Container(height: 40, width: 1, color: borderColor),
              Expanded(
                child: _buildTimeTrackColumn(
                  label: 'Absen Pulang',
                  time: outTime,
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFEF4444),
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTrackColumn({
    required String label,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: subTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumActionBtn({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextCol = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);
    final Color borderCol = isDark
        ? const Color(0xFF2E66FF).withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.75 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _DonutChartPainter(
                hadir: _hadir,
                terlambat: _terlambat,
                alpha: _alpha,
                izin: _izin,
                chartBgColor: isDark
                    ? const Color(0xFF1E244C)
                    : Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildStatRow(
                  'Hadir',
                  _hadir,
                  const Color(0xFF10B981),
                  textCol,
                  subTextCol,
                ),
                _buildStatRow(
                  'Terlambat',
                  _terlambat,
                  const Color(0xFFF59E0B),
                  textCol,
                  subTextCol,
                ),
                _buildStatRow(
                  'Alpha',
                  _alpha,
                  const Color(0xFFEF4444),
                  textCol,
                  subTextCol,
                ),
                _buildStatRow(
                  'Cuti / Izin',
                  _izin,
                  const Color(0xFF3B82F6),
                  textCol,
                  subTextCol,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int count,
    Color color,
    Color textCol,
    Color subTextCol,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: subTextCol,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '$count Hari',
            style: TextStyle(
              color: textCol,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF131738) : Colors.white;
    final Color subTextCol = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);

    if (_isLoadingHistory) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E66FF)),
        ),
      );
    }

    if (_history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(isDark ? 0.75 : 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Belum ada riwayat absensi.',
            style: TextStyle(color: subTextCol, fontSize: 13),
          ),
        ),
      );
    }

    final att = _history.first;
    DateTime parsedDate =
        DateTime.tryParse(att.attendanceDate ?? '') ?? DateTime.now();
    final dayStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsedDate);
    final inTime = att.checkInTime ?? '--:--';
    final outTime = att.checkOutTime ?? '--:--';

    String statusText = 'Tepat Waktu';
    Color statusColor = const Color(0xFF10B981);

    if (att.status == 'izin') {
      statusText = 'Izin';
      statusColor = const Color(0xFF3B82F6);
    } else {
      if (att.checkInTime != null) {
        try {
          final parts = att.checkInTime!.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          if (hour > 8 || (hour == 8 && minute > 0)) {
            statusText = 'Terlambat';
            statusColor = const Color(0xFFF59E0B);
          }
        } catch (_) {}
      }
    }

    final Color textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color borderCol = isDark
        ? const Color(0xFF2E66FF).withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.75 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subTextCol,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: subTextCol.withOpacity(0.7),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inTime,
                        style: TextStyle(
                          color: textCol,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Masuk',
                        style: TextStyle(
                          color: subTextCol,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outTime,
                        style: TextStyle(
                          color: textCol,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Pulang',
                        style: TextStyle(
                          color: subTextCol,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final int hadir;
  final int terlambat;
  final int alpha;
  final int izin;
  final Color chartBgColor;

  _DonutChartPainter({
    required this.hadir,
    required this.terlambat,
    required this.alpha,
    required this.izin,
    required this.chartBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = (hadir + terlambat + alpha + izin).toDouble();
    if (total == 0) total = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 14.0;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final pPlaceholder = Paint()
      ..color = chartBgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (hadir == 0 && terlambat == 0 && alpha == 0 && izin == 0) {
      canvas.drawCircle(center, radius - strokeWidth / 2, pPlaceholder);
      return;
    }

    final pHadir = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pLate = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pAlpha = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pIzin = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    void drawSegment(double val, Paint paint) {
      if (val <= 0) return;
      double sweepAngle = (val / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(hadir.toDouble(), pHadir);
    drawSegment(terlambat.toDouble(), pLate);
    drawSegment(alpha.toDouble(), pAlpha);
    drawSegment(izin.toDouble(), pIzin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
