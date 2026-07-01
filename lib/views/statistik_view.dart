import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/models/attendance_model.dart';

class StatistikView extends StatefulWidget {
  final List<AttendanceModel> history;
  final DateTime? selectedMonth;

  const StatistikView({
    super.key,
    required this.history,
    this.selectedMonth,
  });

  @override
  State<StatistikView> createState() => _StatistikViewState();
}

class _StatistikViewState extends State<StatistikView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animRing;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animRing = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Compute stats ──────────────────────────────────────────────────────────
  int get _totalWorkDays => 24;

  int get _hadirCount {
    int count = 0;
    for (final item in widget.history) {
      if (item.status != 'izin' && item.checkInTime != null) count++;
    }
    return count;
  }

  int get _terlambatCount {
    int count = 0;
    for (final item in widget.history) {
      if (item.status != 'izin' && item.checkInTime != null) {
        try {
          final parts = item.checkInTime!.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          if (h > 8 || (h == 8 && m > 0)) count++;
        } catch (_) {}
      }
    }
    return count;
  }

  int get _alphaCount {
    final hadir = _hadirCount;
    final izin = _izinCount;
    final a = _totalWorkDays - hadir - izin;
    return a < 0 ? 0 : a;
  }

  int get _izinCount {
    int count = 0;
    for (final item in widget.history) {
      if (item.status == 'izin') count++;
    }
    return count;
  }

  double get _attendanceRate =>
      _hadirCount / (_totalWorkDays == 0 ? 1 : _totalWorkDays);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF080C24) : const Color(0xFFF4F7FC);
    final Color cardBg = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subText = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);

    final monthLabel = widget.selectedMonth != null
        ? DateFormat('MMMM yyyy', 'id_ID').format(widget.selectedMonth!)
        : 'Semua';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Statistik Absensi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Placeholder so title stays centered
                  const SizedBox(width: 40, height: 40),
                ],
              ),
            ),

            // ── Month label ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E66FF).withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthLabel,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: subText),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 4 Stat Cards ──
                    _buildStatCards(isDark, cardBg, textColor, subText),

                    const SizedBox(height: 24),

                    // ── Donut + Rate ──
                    _buildAttendanceRate(isDark, cardBg, textColor, subText),

                    const SizedBox(height: 24),

                    // ── Trend Chart ──
                    _buildTrendChart(isDark, cardBg, textColor, subText),

                    const SizedBox(height: 24),

                    // ── Rincian Kehadiran ──
                    _buildRincian(isDark, cardBg, textColor, subText),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4 stat cards ────────────────────────────────────────────────────────────
  Widget _buildStatCards(bool isDark, Color cardBg, Color textColor, Color subText) {
    final stats = [
      {'label': 'Total Hari\nKerja', 'value': '$_totalWorkDays', 'color': const Color(0xFF2E66FF)},
      {'label': 'Hadir', 'value': '$_hadirCount', 'color': const Color(0xFF10B981)},
      {'label': 'Terlambat', 'value': '$_terlambatCount', 'color': const Color(0xFFEF4444)},
      {'label': 'Alpha', 'value': '$_alphaCount', 'color': const Color(0xFFF59E0B)},
    ];

    return Row(
      children: stats.map((s) {
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  s['value'] as String,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Donut chart ─────────────────────────────────────────────────────────────
  Widget _buildAttendanceRate(bool isDark, Color cardBg, Color textColor, Color subText) {
    final percent = (_attendanceRate * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animRing,
            builder: (_, __) {
              return SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutPainter(
                    progress: _animRing.value * _attendanceRate,
                    trackColor: isDark
                        ? const Color(0xFF1E244C)
                        : Colors.grey.shade200,
                    fillColor: const Color(0xFF2E66FF),
                    bgColor: cardBg,
                    percent: percent,
                    textColor: textColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Tingkat\nKehadiran',
                style: TextStyle(
                  color: subText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Trend line chart (last 6 weeks stub) ────────────────────────────────────
  Widget _buildTrendChart(bool isDark, Color cardBg, Color textColor, Color subText) {
    // Generate weekly data from history (simplified)
    final List<double> weeklyData = _computeWeeklyTrend();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren Kehadiran (6 Minggu Terakhir)',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineTrendPainter(
                data: weeklyData,
                lineColor: const Color(0xFF2E66FF),
                gridColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                labelColor: subText,
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _computeWeeklyTrend() {
    // Build 6-week attendance rate (simple approximation)
    final now = DateTime.now();
    final List<double> result = [];
    for (int week = 5; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + week * 7));
      final weekEnd = weekStart.add(const Duration(days: 4));
      int hadirInWeek = 0;
      int totalInWeek = 5; // Mon–Fri
      for (final item in widget.history) {
        final d = DateTime.tryParse(item.attendanceDate ?? '');
        if (d != null &&
            !d.isBefore(weekStart) &&
            !d.isAfter(weekEnd) &&
            item.checkInTime != null &&
            item.status != 'izin') {
          hadirInWeek++;
        }
      }
      result.add((hadirInWeek / totalInWeek).clamp(0, 1));
    }
    return result;
  }

  // ── Rincian kehadiran ────────────────────────────────────────────────────────
  Widget _buildRincian(bool isDark, Color cardBg, Color textColor, Color subText) {
    final items = [
      {
        'label': 'Hadir',
        'count': _hadirCount,
        'percent': (_hadirCount / _totalWorkDays * 100).round(),
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Terlambat',
        'count': _terlambatCount,
        'percent': (_terlambatCount / _totalWorkDays * 100).round(),
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'Alpha',
        'count': _alphaCount,
        'percent': (_alphaCount / _totalWorkDays * 100).round(),
        'color': const Color(0xFFEF4444),
      },
      {
        'label': 'Cuti / Izin',
        'count': _izinCount,
        'percent': (_izinCount / _totalWorkDays * 100).round(),
        'color': const Color(0xFF3B82F6),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Kehadiran',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final color = item['color'] as Color;
            final pct = (item['percent'] as int).clamp(0, 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  // Colored dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  // Label
                  SizedBox(
                    width: 80,
                    child: Text(
                      item['label'] as String,
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ),
                  // Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Count & percent
                  Text(
                    '${item['count']} ($pct%)',
                    style: TextStyle(
                      color: subText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Donut Painter ────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final Color bgColor;
  final int percent;
  final Color textColor;

  _DonutPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.bgColor,
    required this.percent,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

// ── Line Trend Painter ────────────────────────────────────────────────────────
class _LineTrendPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  _LineTrendPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final w = size.width;
    final h = size.height - 24; // reserve for x labels

    // Grid lines
    final gridPaint = Paint()..color = gridColor..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = h - (h * i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);

      // y label
      final pct = (i * 25).toString();
      final tp = TextPainter(
        text: TextSpan(
          text: '$pct%',
          style: TextStyle(color: labelColor, fontSize: 9),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 10));
    }

    // Data points
    final n = data.length;
    final xStep = (w - 30) / (n - 1 == 0 ? 1 : n - 1);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < n; i++) {
      final x = 30 + i * xStep;
      final y = h - (data[i] * h);
      points.add(Offset(x, y));
    }

    // Draw fill under line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, h);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(points.last.dx, h);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Draw line
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Dots + x labels
    final labels = ['M-6', 'M-5', 'M-4', 'M-3', 'M-2', 'M-1'];
    for (int i = 0; i < points.length; i++) {
      // dot
      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        points[i],
        2.5,
        Paint()..color = Colors.white,
      );

      // value above dot
      final val = '${(data[i] * 100).round()}%';
      final valTp = TextPainter(
        text: TextSpan(
          text: val,
          style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(points[i].dx - valTp.width / 2, points[i].dy - 18));

      // x label
      final lbl = i < labels.length ? labels[i] : '';
      final lblTp = TextPainter(
        text: TextSpan(
          text: lbl,
          style: TextStyle(color: labelColor, fontSize: 9),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      lblTp.paint(canvas, Offset(points[i].dx - lblTp.width / 2, h + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineTrendPainter old) => old.data != data;
}
