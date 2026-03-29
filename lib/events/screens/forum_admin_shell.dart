import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/event_service.dart';
import 'home/explore_tab.dart';
import 'admin/create_event_screen.dart';
import 'forum_admin_profile.dart';

class ForumAdminShell extends StatefulWidget {
  const ForumAdminShell({super.key});

  @override
  State<ForumAdminShell> createState() => _ForumAdminShellState();
}

class _ForumAdminShellState extends State<ForumAdminShell> {
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
            ForumAdminProfile(),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  // get their forumId then open create event
                  _openCreateEvent(context);
                },
                backgroundColor: _primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Event',
                    style: TextStyle(color: Colors.white)),
              )
            : null,
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
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateEvent(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Get their forum from forum_requests (approved ones have forumId set)
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final forumId = userDoc.data()?['forumId'] ?? '';

    if (!context.mounted) return;

    if (forumId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No forum assigned. Contact super admin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => EventService(),
          child: CreateEventScreen(forumId: forumId),
        ),
      ),
    );
  }
}