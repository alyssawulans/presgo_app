import 'package:flutter/material.dart';
import 'package:presgo_app/services/storage_service.dart';
import 'package:presgo_app/views/login_view.dart';
import 'package:presgo_app/views/main_navigation_view.dart';

class SplashView1 extends StatefulWidget {
  const SplashView1({super.key});

  @override
  State<SplashView1> createState() => _SplashView1State();
}

class _SplashView1State extends State<SplashView1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // We let the splash animation run for at least 1.8s
    await Future.delayed(const Duration(milliseconds: 1800));
    final token = await StorageService.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationView()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? const Color(0xFF080C24)
        : const Color(0xFFF4F7FC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF90A3BF)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Background gradient selalu tampil ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/bag_1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant gradient background if image is missing
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE6F4F1), Color(0xFF0D9488)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Decorative glow circle — top left ──
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF2E66FF,
                ).withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
          ),

          // ── Decorative glow circle — bottom right ──
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF8F30FF,
                ).withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
          ),

          // ── Decorative glow circle — center right ──
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF10B981,
                ).withValues(alpha: isDark ? 0.10 : 0.07),
              ),
            ),
          ),

          // ── Decorative dot grid (subtle) ──
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter(isDark: isDark)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    // Header logo
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'PRESGO\n',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Presence On The Go',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF8F30FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sistem Absensi Pegawai yang Modern, Akurat, dan Terintegrasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),

                    // Lottie Mascot Animation
                    // ScaleTransition(
                    //   scale: _scaleAnimation,
                    //   child: SizedBox(
                    //     height: 250,
                    //     width: 250,
                    //     child: Lottie.asset(
                    //       'assets/animations/logomaskot.json',
                    //       fit: BoxFit.contain,
                    //       errorBuilder: (context, error, stackTrace) {
                    //         return Container(
                    //           padding: const EdgeInsets.all(20),
                    //           decoration: BoxDecoration(
                    //             color: const Color(0xFF2E66FF).withOpacity(0.1),
                    //             shape: BoxShape.circle,
                    //           ),
                    //           child: const Icon(
                    //             Icons.wallet_membership_rounded,
                    //             size: 80,
                    //             color: Color(0xFF2E66FF),
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),

                    // Get Started Button
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8F30FF).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              'Get Started',
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
                    const SizedBox(height: 24),
                    // Link to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF2E66FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle dot grid background painter ──────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  final bool isDark;
  _DotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF2E66FF) : const Color(0xFF2E66FF))
          .withValues(alpha: isDark ? 0.06 : 0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => old.isDark != isDark;
}
