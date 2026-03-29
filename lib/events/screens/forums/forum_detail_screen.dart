import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/forum_model.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/theme.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_screen.dart';

class ForumDetailScreen extends StatelessWidget {
  final ForumModel forum;
  const ForumDetailScreen({super.key, required this.forum});

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.forumColors[forum.colorIndex % AppTheme.forumColors.length];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(forum.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.groups,
                      size: 80, color: Colors.white.withOpacity(0.4)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _badge(forum.category, color),
                      const SizedBox(width: 8),
                      _badge('${forum.memberCount} members', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(forum.description,
                      style:
                          const TextStyle(color: Colors.grey, height: 1.5)),
                  const SizedBox(height: 24),
                  const Text('Events',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
          StreamBuilder<List<EventModel>>(
            stream: context
                .read<EventService>()
                .getAllEvents(forumId: forum.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator())));

              final events = snap.data ?? [];
              if (events.isEmpty)
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No events yet',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                );

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: events[i],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(event: events[i]))),
                      ),
                    ),
                    childCount: events.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}