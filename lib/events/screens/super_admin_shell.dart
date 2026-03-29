import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import 'home/explore_tab.dart';
import 'super_admin_profile.dart';

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  int _currentIndex = 0;

  static const _primary = Color(0xFF5E6AD2);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventService(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            ExploreTab(),
            SuperAdminProfile(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: _primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}