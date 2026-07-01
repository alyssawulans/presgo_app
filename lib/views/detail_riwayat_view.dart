import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/models/attendance_model.dart';
import 'package:presgo_app/services/api_service.dart';

class DetailRiwayatView extends StatefulWidget {
  final AttendanceModel attendance;
  final VoidCallback onDeleteSuccess;

  const DetailRiwayatView({
    super.key,
    required this.attendance,
    required this.onDeleteSuccess,
  });

  @override
  State<DetailRiwayatView> createState() => _DetailRiwayatViewState();
}

class _DetailRiwayatViewState extends State<DetailRiwayatView> {
  bool _isDeleting = false;

  void _confirmDelete() {
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
            'Hapus Absensi',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data absensi ini? Tindakan ini tidak dapat dibatalkan.',
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
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAbsen();
              },
              child: const Text(
                'Hapus',
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

  void _deleteAbsen() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await ApiService.instance.deleteAttendance(widget.attendance.id ?? 0);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data absensi berhasil dihapus.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onDeleteSuccess();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String errMsg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // Dark maps style
  final String _darkStyle = jsonEncode([
    {
      "elementType": "geometry",
      "stylers": [
        {"color": "#1d2c4d"},
      ],
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#8ec3b9"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#0e1626"},
      ],
    },
  ]);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? const Color(0xFF080C24)
        : const Color(0xFFF4F7FC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final att = widget.attendance;
    DateTime parsedDate =
        DateTime.tryParse(att.attendanceDate ?? '') ?? DateTime.now();
    final dayStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsedDate);

    String statusText = 'Tepat Waktu';
    Color statusColor = const Color(0xFF10B981); // Green

    if (att.status == 'izin') {
      statusText = 'Izin';
      statusColor = const Color(0xFF3B82F6); // Blue
    } else {
      if (att.checkInTime != null) {
        try {
          final parts = att.checkInTime!.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          if (hour > 8 || (hour == 8 && minute > 0)) {
            statusText = 'Terlambat';
            statusColor = const Color(0xFFF59E0B); // Orange
          }
        } catch (_) {}
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Riwayat',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayStr,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Check In Card
                _buildMapDetailCard(
                  title: 'Lokasi Absen Masuk',
                  time: att.checkInTime ?? '--:--',
                  address: att.checkInAddress ?? 'Alamat tidak tercatat',
                  lat: _parseCoordinate(att.checkInLat),
                  lng: _parseCoordinate(att.checkInLng),
                  iconColor: const Color(0xFF10B981),
                  hue: BitmapDescriptor.hueGreen,
                ),

                const SizedBox(height: 20),

                // Check Out Card
                _buildMapDetailCard(
                  title: 'Lokasi Absen Pulang',
                  time: att.checkOutTime ?? '--:--',
                  address: att.checkOutAddress ?? 'Alamat tidak tercatat',
                  lat: _parseCoordinate(att.checkOutLat),
                  lng: _parseCoordinate(att.checkOutLng),
                  iconColor: const Color(0xFFEF4444),
                  hue: BitmapDescriptor.hueRed,
                ),

                const SizedBox(height: 36),

                // Hapus Data Absen Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isDeleting ? null : _confirmDelete,
                      child: Center(
                        child: _isDeleting
                            ? const CircularProgressIndicator(
                                color: Colors.redAccent,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus Data Absensi',
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
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapDetailCard({
    required String title,
    required String time,
    required String address,
    required double? lat,
    required double? lng,
    required Color iconColor,
    required double hue,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextCol = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);
    final Color borderCol = isDark
        ? const Color(0xFF2E66FF).withOpacity(0.15)
        : Colors.grey.withOpacity(0.2);

    final hasCoords = lat != null && lng != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: iconColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address,
            style: TextStyle(color: subTextCol, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          // Google Map preview
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasCoords
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, lng),
                        zoom: 15.0,
                      ),
                      onMapCreated: (controller) {
                        if (isDark) {
                          controller.setMapStyle(_darkStyle);
                        } else {
                          controller.setMapStyle(null);
                        }
                      },
                      markers: {
                        Marker(
                          markerId: MarkerId(title),
                          position: LatLng(lat, lng),
                          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                        ),
                      },
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                    )
                  : Center(
                      child: Text(
                        'Koordinat peta tidak tersedia',
                        style: TextStyle(color: subTextCol, fontSize: 12),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
