import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_top_bar.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'register_site_screen.dart';
import 'reports_screen.dart';
import 'site_list_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0; // 0..4: Dashboard, Sites, Map, Reports, Profile
  int _refreshToken = 0;

  String _titleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Sites';
      case 2:
        return 'Map';
      case 3:
        return 'Reports';
      case 4:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  String _subtitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Search and review saved sites';
      case 2:
        return 'Offline area overview';
      case 3:
        return 'Local summaries and counts';
      case 4:
        return 'Enumerator profile';
      default:
        return 'Offline-first census app';
    }
  }

  Future<void> _openRegister() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterSiteScreen()),
    );

    if (saved == true && mounted) {
      setState(() {
        _refreshToken += 1;
        _currentIndex = 0; // Jump back to dashboard
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Site saved locally.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: RuralMapAppBar(
        title: _titleForIndex(_currentIndex),
        subtitle: _subtitleForIndex(_currentIndex),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _refreshToken += 1),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            // 0
            refreshToken: _refreshToken,
            currentUserEmail: auth.currentUser?.email,
            onNavigate: (index) => setState(() => _currentIndex = index),
            onOpenRegister: _openRegister,
          ),
          const SiteListScreen(), // 1
          MapScreen(refreshToken: _refreshToken), // 2
          const ReportsScreen(), // 3
          const ProfileScreen(), // 4
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onRegisterTap: _openRegister,
      ),
    );
  }
}
