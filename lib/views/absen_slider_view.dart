import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/services/location_service.dart';
import 'package:presgo_app/views/custom_error_dialog.dart';

class AbsenSliderView extends StatefulWidget {
  final bool isCheckIn;
  final VoidCallback onSuccess;

  const AbsenSliderView({
    super.key,
    required this.isCheckIn,
    required this.onSuccess,
  });

  @override
  State<AbsenSliderView> createState() => _AbsenSliderViewState();
}

class _AbsenSliderViewState extends State<AbsenSliderView> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LocationResult? _location;
  bool _isLoadingLoc = true;
  bool _isSubmitting = false;

  double _dragPosition = 0.0;
  final double _thumbSize = 56.0;

  late AnimationController _slideBackController;
  late Animation<double> _slideBackAnimation;

  // Pulsing animation for the slider path
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadLocation();

    _slideBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideBackAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideBackController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _dragPosition = _slideBackAnimation.value;
        });
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLoc = true;
    });

    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _location = loc;
        _isLoadingLoc = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(loc.latitude, loc.longitude),
            17.0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _isLoadingLoc = false;
        });
      }
    }
  }

  void _triggerAbsen() async {
    if (_location == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      if (widget.isCheckIn) {
        await ApiService.instance.checkIn(
          date: dateStr,
          time: timeStr,
          lat: _location!.latitude,
          lng: _location!.longitude,
          address: _location!.address,
          status: 'masuk',
        );
      } else {
        await ApiService.instance.checkOut(
          date: dateStr,
          time: timeStr,
          lat: _location!.latitude,
          lng: _location!.longitude,
          address: _location!.address,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isCheckIn ? 'Absen Masuk Berhasil!' : 'Absen Pulang Berhasil!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      widget.onSuccess();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String errMsg = e.toString().replaceAll('Exception:', '').trim();
      CustomErrorDialog.show(context, errMsg);
      _resetSlider();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetSlider() {
    _slideBackAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _slideBackController, curve: Curves.easeOut),
    );
    _slideBackController.reset();
    _slideBackController.forward();
  }

  @override
  void dispose() {
    _slideBackController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  final String _darkStyle = jsonEncode([
    {
      "elementType": "geometry",
      "stylers": [
        {"color": "#0d1127"}
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#707b93"}
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#0d1127"}
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#080b1e"}
      ]
    }
  ]);

  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? 'Absen Masuk' : 'Absen Pulang';
    final accentColor = widget.isCheckIn ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final gradientColors = widget.isCheckIn
        ? [const Color(0xFF10B981), const Color(0xFF059669)]
        : [const Color(0xFFEF4444), const Color(0xFFDC2626)];

    LatLng initialPos = const LatLng(-6.200000, 106.816666);
    if (_location != null) {
      initialPos = LatLng(_location!.latitude, _location!.longitude);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080C24),
      body: Stack(
        children: [
          // ── Gradient Background ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0E2E), Color(0xFF080C24)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Main Layout ──
          SafeArea(
            child: Column(
              children: [
                // ── Premium App Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: accentColor, size: 22),
                        onPressed: _loadLocation,
                      ),
                    ],
                  ),
                ),

                // ── Map Card Container ──
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          _isLoadingLoc && _location == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: accentColor),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Mengunci Posisi GPS...',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : GoogleMap(
                                  initialCameraPosition: CameraPosition(target: initialPos, zoom: 17.0),
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _mapController!.setMapStyle(_darkStyle);
                                  },
                                  markers: _location != null
                                      ? {
                                          Marker(
                                            markerId: const MarkerId('current'),
                                            position: LatLng(_location!.latitude, _location!.longitude),
                                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                              widget.isCheckIn
                                                  ? BitmapDescriptor.hueGreen
                                                  : BitmapDescriptor.hueRed,
                                            ),
                                          )
                                        }
                                      : {},
                                  myLocationEnabled: false,
                                  zoomControlsEnabled: false,
                                ),

                          // Floating Map Info Badge
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF080C24).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.isCheckIn ? 'Zona Absen Masuk' : 'Zona Absen Pulang',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Bottom Panel ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1133),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GPS Quality Info
                      Row(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'GPS Terkoneksi',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          if (_location != null)
                            Text(
                              'Akurasi: ±${_location!.accuracy.toStringAsFixed(1)}m',
                              style: const TextStyle(
                                color: Color(0xFF707B93),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Location Title
                      const Text(
                        'Lokasi Presensi Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Full Address Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080C24).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_rounded, color: accentColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _location?.address ?? 'Mencari lokasi presensi...',
                                style: const TextStyle(
                                  color: Color(0xFF90A3BF),
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Interactive Premium Slider Track ──
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxDrag = constraints.maxWidth - _thumbSize;

                          // Compute drag progress (0.0 to 1.0)
                          final double progress = maxDrag > 0 ? (_dragPosition / maxDrag) : 0.0;

                          return Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF080C24),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.15 + (progress * 0.35)),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: progress * 0.15),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Glowing background track as you drag
                                FractionallySizedBox(
                                  widthFactor: progress.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor.withValues(alpha: 0.05),
                                          accentColor.withValues(alpha: 0.25),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),

                                // Shimmer text instructions
                                Center(
                                  child: Opacity(
                                    opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                                    child: Text(
                                      widget.isCheckIn
                                          ? 'Geser ke kanan untuk Masuk'
                                          : 'Geser ke kanan untuk Pulang',
                                      style: TextStyle(
                                        color: isDarkTheme(context)
                                            ? const Color(0xFF90A3BF)
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),

                                // The Draggable Thumb
                                Positioned(
                                  left: _dragPosition,
                                  child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      if (_location == null || _isSubmitting) return;
                                      setState(() {
                                        _dragPosition += details.delta.dx;
                                        if (_dragPosition < 0.0) _dragPosition = 0.0;
                                        if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                                      });
                                    },
                                    onHorizontalDragEnd: (details) {
                                      if (_location == null || _isSubmitting) return;
                                      if (_dragPosition >= maxDrag * 0.88) {
                                        setState(() {
                                          _dragPosition = maxDrag;
                                        });
                                        _triggerAbsen();
                                      } else {
                                        _resetSlider();
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: _isSubmitting ? 0 : 50),
                                      margin: const EdgeInsets.all(2),
                                      width: _thumbSize - 4,
                                      height: _thumbSize - 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _isSubmitting
                                          ? const Center(
                                              child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              progress > 0.8
                                                  ? Icons.check_rounded
                                                  : Icons.keyboard_double_arrow_right_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
