import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../models/forum_model.dart';
import '../../utils/theme.dart';
import 'create_event_screen.dart';
import 'manage_registration_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _selectedForumId;
  String _userRole = 'student';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) {
      setState(() {
        _userRole = doc.data()?['role'] ?? 'student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventService = context.read<EventService>();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.deepPurple),
      floatingActionButton: _selectedForumId != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CreateEventScreen(forumId: _selectedForumId!))),
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            )
          : null,
      body: Column(
        children: [
          Container(
            color: Colors.deepPurple.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<ForumModel>>(
              stream: eventService.getForums(),
              builder: (_, snap) {
                final forums = snap.data ?? [];

                // superAdmin sees all forums, forumAdmin sees only theirs
                final adminForums = _userRole == 'superAdmin'
                    ? forums
                    : forums
                        .where((f) => f.adminIds.contains(currentUid))
                        .toList();

                if (adminForums.isEmpty) {
                  return const Text('You are not an admin of any forum.');
                }

                if (_selectedForumId == null && adminForums.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      setState(
                          () => _selectedForumId = adminForums.first.id));
                }

                return DropdownButtonFormField<String>(
                  value: _selectedForumId,
                  decoration: const InputDecoration(
                      labelText: 'Select Forum',
                      prefixIcon: Icon(Icons.groups)),
                  items: adminForums
                      .map((f) => DropdownMenuItem(
                          value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedForumId = v),
                );
              },
            ),
          ),
          if (_selectedForumId != null)
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream:
                    eventService.getAllEvents(forumId: _selectedForumId),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final events = snap.data ?? [];
                  final upcoming = events
                      .where((e) => e.status == EventStatus.upcoming)
                      .length;
                  final totalReg =
                      events.fold(0, (s, e) => s + e.registeredCount);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                                child: _stat('Total', '${events.length}',
                                    Icons.event, AppTheme.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _stat('Upcoming', '$upcoming',
                                    Icons.upcoming, Colors.orange)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _stat('Registered', '$totalReg',
                                    Icons.people, Colors.green)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: events.isEmpty
                            ? const Center(
                                child: Text('No events yet',
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: events.length,
                                itemBuilder: (_, i) {
                                  final ev = events[i];
                                  return Card(
                                    margin:
                                        const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _statusColor(ev.status)
                                                .withValues(alpha: 0.15),
                                        child: Icon(Icons.event,
                                            color:
                                                _statusColor(ev.status)),
                                      ),
                                      title: Text(ev.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          '${ev.registeredCount}/${ev.maxParticipants} registered'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.people_outline),
                                            onPressed: () =>
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            ManageRegistrationsScreen(
                                                                event:
                                                                    ev))),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _delete(context, ev),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Color _statusColor(EventStatus s) {
    switch (s) {
      case EventStatus.upcoming:
        return Colors.blue;
      case EventStatus.ongoing:
        return Colors.green;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }

  void _delete(BuildContext context, EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<EventService>().deleteEvent(event.id);
    }
  }
}