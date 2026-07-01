import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:presgo_app/models/attendance_model.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/views/detail_riwayat_view.dart';
import 'package:presgo_app/views/statistik_view.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<AttendanceModel> _history = [];
  bool _isLoading = true;
  DateTime? _selectedMonth;

  // default current month selected
  late DateTime _currentMonth;

  final List<DateTime> _monthOptions = List.generate(12, (index) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - index, 1);
  });

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _selectedMonth = _currentMonth;
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      String? start;
      String? end;
      if (_selectedMonth != null) {
        start = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(_selectedMonth!.year, _selectedMonth!.month, 1));
        end = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0));
      }
      final list = await ApiService.instance.getHistory(start: start, end: end);
      if (mounted) {
        setState(() {
          _history = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Group history by date string
  Map<String, List<AttendanceModel>> _groupByDate() {
    final Map<String, List<AttendanceModel>> grouped = {};
    for (final item in _history) {
      final key = item.attendanceDate ?? '';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF080C24) : const Color(0xFFF4F7FC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subText = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);
    final Color divider = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.withValues(alpha: 0.15);

    final monthLabel = _selectedMonth != null
        ? DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth!)
        : 'Semua';

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month filter
                GestureDetector(
                  onTap: () =>
                      _showMonthPicker(context, isDark, textColor, subText),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131738) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E66FF).withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          monthLabel,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: subText,
                        ),
                      ],
                    ),
                  ),
                ),

                // Statistics button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatistikView(
                          history: _history,
                          selectedMonth: _selectedMonth,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E66FF), Color(0xFF8F30FF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Statistik',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Title ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Absensi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── List ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHistory,
              color: const Color(0xFF2E66FF),
              backgroundColor: isDark ? const Color(0xFF131738) : Colors.white,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E66FF),
                      ),
                    )
                  : _history.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 250,
                                height: 250,
                                child: Lottie.asset(
                                  'assets/animations/loadingpres.json',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.blur_circular,
                                      size: 80,
                                      color: Color(0xFF2E66FF),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada riwayat',
                                style: TextStyle(
                                  color: subText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _buildGroupedList(bg, textColor, subText, divider, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(
    Color bg,
    Color textColor,
    Color subText,
    Color dividerColor,
    bool isDark,
  ) {
    final grouped = _groupByDate();
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final items = grouped[dateKey]!;

        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(dateKey);
        } catch (_) {
          parsedDate = DateTime.now();
        }

        final dayLabel = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(parsedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              dayLabel,
              style: TextStyle(
                color: subText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => _buildItemCard(
                item,
                textColor,
                subText,
                dividerColor,
                isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(
    AttendanceModel item,
    Color textColor,
    Color subText,
    Color dividerColor,
    bool isDark,
  ) {
    final inTime = item.checkInTime ?? '--:--';
    final outTime = item.checkOutTime ?? '--:--';

    String statusText = 'Tepat Waktu';
    Color statusColor = const Color(0xFF10B981);

    if (item.status == 'izin') {
      statusText = 'Izin';
      statusColor = const Color(0xFF3B82F6);
    } else if (item.checkInTime != null) {
      try {
        final parts = item.checkInTime!.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour > 8 || (hour == 8 && minute > 0)) {
          statusText = 'Terlambat';
          statusColor = const Color(0xFFF59E0B);
        }
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailRiwayatView(
              attendance: item,
              onDeleteSuccess: _fetchHistory,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
        ),
        child: Row(
          children: [
            // Masuk column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 6),
                      Text(
                        inTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Masuk',
                      style: TextStyle(color: subText, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Pulang column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      const SizedBox(width: 6),
                      Text(
                        outTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Pulang',
                      style: TextStyle(color: subText, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Status + arrow
            Row(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: subText.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subText,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF131738) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: subText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Bulan',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: _monthOptions.map((dt) {
                  final label = DateFormat('MMMM yyyy', 'id_ID').format(dt);
                  final isSelected =
                      _selectedMonth?.year == dt.year &&
                      _selectedMonth?.month == dt.month;
                  return ListTile(
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2E66FF) : textColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: Color(0xFF2E66FF))
                        : null,
                    onTap: () {
                      setState(() => _selectedMonth = dt);
                      Navigator.pop(context);
                      _fetchHistory();
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
