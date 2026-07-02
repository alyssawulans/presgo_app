import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/views/home_tab.dart';
import 'package:presgo_app/views/history_tab.dart';
import 'package:presgo_app/views/izin_view.dart';
import 'package:presgo_app/views/statistik_view.dart';
import 'package:presgo_app/views/profile_tab.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  UserModel? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService.instance.getProfile();
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data profil: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF080C24) : const Color(0xFFF4F7FC);
    final Color navBgColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color unselectedColor = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);

    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E66FF)),
        ),
      );
    }

    final List<Widget> tabs = [
      HomeTab(
        user: _user,
        onNavigateToHistory: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const HistoryTab(),
      IzinView(
        isTab: true,
        onSuccess: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const StatistikView(
        history: [], // StatistikView fetches its own data from API
      ),
      ProfileTab(
        user: _user,
        onProfileUpdated: _loadUserProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 65.0,
        color: navBgColor,
        buttonBackgroundColor: const Color(0xFF2E66FF),
        backgroundColor: bgColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          Icon(
            Icons.home_rounded,
            size: 26,
            color: _currentIndex == 0 ? Colors.white : unselectedColor,
          ),
          Icon(
            Icons.history_rounded,
            size: 26,
            color: _currentIndex == 1 ? Colors.white : unselectedColor,
          ),
          Icon(
            Icons.event_note_rounded,
            size: 26,
            color: _currentIndex == 2 ? Colors.white : unselectedColor,
          ),
          Icon(
            Icons.bar_chart_rounded,
            size: 26,
            color: _currentIndex == 3 ? Colors.white : unselectedColor,
          ),
          Icon(
            Icons.person_rounded,
            size: 26,
            color: _currentIndex == 4 ? Colors.white : unselectedColor,
          ),
        ],
      ),
    );
  }
}
