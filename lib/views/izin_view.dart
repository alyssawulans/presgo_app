import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/services/location_service.dart';
import 'package:presgo_app/views/custom_error_dialog.dart';

class IzinView extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool isTab;

  const IzinView({super.key, required this.onSuccess, this.isTab = false});

  @override
  State<IzinView> createState() => _IzinViewState();
}

class _IzinViewState extends State<IzinView> with SingleTickerProviderStateMixin {
  final TextEditingController _alasanCtrl = TextEditingController();

  String _selectedType = 'Sakit';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _locationAddress;
  double? _lat;
  double? _lng;
  bool _isLoadingLocation = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _izinTypes = [
    {'label': 'Sakit', 'icon': Icons.local_hospital_rounded, 'color': const Color(0xFFEF4444)},
    {'label': 'Keperluan Keluarga', 'icon': Icons.family_restroom_rounded, 'color': const Color(0xFFEC4899)},
    {'label': 'Urusan Pribadi', 'icon': Icons.person_rounded, 'color': const Color(0xFF8F30FF)},
    {'label': 'Dinas Luar', 'icon': Icons.work_rounded, 'color': const Color(0xFF2E66FF)},
    {'label': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF64748B)},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _fetchLocation();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationAddress = loc.address;
          _lat = loc.latitude;
          _lng = loc.longitude;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationAddress = 'Lokasi tidak terdeteksi';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: Color(0xFF8F30FF))
                : const ColorScheme.light(primary: Color(0xFF8F30FF)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitIzin() async {
    if (_alasanCtrl.text.trim().isEmpty) {
      _showError('Alasan izin tidak boleh kosong');
      return;
    }
    if (_locationAddress == null || _locationAddress == 'Lokasi tidak terdeteksi') {
      _showError('Gagal mendapatkan lokasi. Coba lagi.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = DateFormat('HH:mm').format(DateTime.now());
      final alasan = '$_selectedType - ${_alasanCtrl.text.trim()}';

      await ApiService.instance.checkIn(
        date: dateStr,
        time: timeStr,
        lat: _lat!,
        lng: _lng!,
        address: _locationAddress!,
        status: 'izin',
        alasanIzin: alasan,
      );

      if (mounted) {
        widget.onSuccess();
        if (!widget.isTab) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Izin berhasil diajukan!'),
              ],
            ),
            backgroundColor: const Color(0xFF8F30FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  void _showError(String msg) {
    CustomErrorDialog.show(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF080C24) : const Color(0xFFF4F7FC);
    final Color cardBg = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subText = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);
    final Color border = isDark
        ? const Color(0xFF2E66FF).withValues(alpha: 0.15)
        : Colors.grey.withValues(alpha: 0.2);

    final dateLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  if (!widget.isTab)
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  Expanded(
                    child: Text(
                      'Ajukan Izin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (!widget.isTab) const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header banner ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8F30FF), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8F30FF).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pengajuan Izin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Isi form di bawah untuk mengajukan izin tidak hadir',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Tanggal ──
                      Text(
                        'Tanggal Izin',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8F30FF).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Color(0xFF8F30FF),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dateLabel,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, color: subText),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Jenis Izin ──
                      Text(
                        'Jenis Izin',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _izinTypes.map((type) {
                          final isSelected = _selectedType == type['label'];
                          final color = type['color'] as Color;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = type['label']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? color : cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? color : border,
                                  width: isSelected ? 0 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    color: isSelected ? Colors.white : color,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // ── Alasan ──
                      Text(
                        'Alasan / Keterangan',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: TextField(
                          controller: _alasanCtrl,
                          maxLines: 4,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Tuliskan alasan izin Anda secara singkat...',
                            hintStyle: TextStyle(color: subText, fontSize: 13),
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Lokasi ──
                      Text(
                        'Lokasi Saat Ini',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E66FF).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E66FF),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF2E66FF),
                                      size: 18,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isLoadingLocation
                                    ? 'Mendapatkan lokasi...'
                                    : (_locationAddress ?? 'Lokasi tidak tersedia'),
                                style: TextStyle(
                                  color: _locationAddress == null || _isLoadingLocation
                                      ? subText
                                      : textColor,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Submit Button ──
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _isSubmitting ? null : _submitIzin,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isSubmitting
                                    ? [Colors.grey, Colors.grey.shade600]
                                    : [const Color(0xFF8F30FF), const Color(0xFF6D28D9)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isSubmitting
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF8F30FF).withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 10),
                                        Text(
                                          'Ajukan Izin',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
