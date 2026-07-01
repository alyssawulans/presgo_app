import 'package:flutter/material.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/views/home_tab.dart';
import 'package:presgo_app/views/history_tab.dart';
import 'package:presgo_app/views/map_tab.dart';
import 'package:presgo_app/views/profile_tab.dart';
import 'package:presgo_app/views/settings_tab.dart';

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
    final Color navBgColor = isDark ? const Color(0xFF0A0E2A) : Colors.white;
    final Color unselectedColor = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF2E66FF).withOpacity(0.15) : Colors.grey.withOpacity(0.2);

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
      const MapTab(),
      ProfileTab(
        user: _user,
        onProfileUpdated: _loadUserProfile,
      ),
      const SettingsTab(),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: navBgColor,
          selectedItemColor: const Color(0xFF2E66FF),
          unselectedItemColor: unselectedColor,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Lainnya',
            ),
          ],
        ),
      ),
    );
  }
}
