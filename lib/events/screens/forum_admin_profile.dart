import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumAdminProfile extends StatelessWidget {
  const ForumAdminProfile({super.key});

  static const _primary = Color(0xFF5E6AD2);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _bg = Color(0xFFF0F2F5);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['displayName'] ?? 'Forum Admin';
          final email = data['email'] ?? '';
          final forumName = data['forumName'] ?? 'My Forum';
          final photoUrl = data['photoUrl'] as String?;

          return CustomScrollView(
            slivers: [
              // ── HEADER ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _primary,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primary, Color(0xFF818CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Forum Admin',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── BODY ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // INFO CARD
                      _card(children: [
                        _infoRow(Icons.mail_outline, 'Email', email),
                        const Divider(height: 24),
                        _infoRow(Icons.groups_outlined, 'Forum', forumName),
                      ]),

                      const SizedBox(height: 20),

                      // ── MY EVENTS ──
                      const Text('My Events',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary)),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .where('createdBy', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, eventSnap) {
                          if (!eventSnap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final docs = eventSnap.data!.docs;

                          if (docs.isEmpty) {
                            return _card(children: [
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('No events created yet',
                                      style:
                                          TextStyle(color: _textSecondary)),
                                ),
                              ),
                            ]);
                          }

                          return Column(
                            children: docs.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final title = d['title'] ?? '';
                              final status = d['status'] ?? 'upcoming';
                              final registered = d['registeredCount'] ?? 0;
                              final max = d['maxParticipants'] ?? 0;

                              Color statusColor;
                              switch (status) {
                                case 'ongoing':
                                  statusColor = Colors.green;
                                  break;
                                case 'completed':
                                  statusColor = Colors.grey;
                                  break;
                                case 'cancelled':
                                  statusColor = Colors.red;
                                  break;
                                default:
                                  statusColor = Colors.blue;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFE4E6EB)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                            alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.event,
                                          color: statusColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: _textPrimary),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text('$registered/$max registered',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: _textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                            alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(status.toUpperCase(),
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // SIGN OUT
                      _card(children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout,
                                color: Colors.red, size: 18),
                          ),
                          title: const Text('Sign Out',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ]),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E6EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: _textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
          ],
        ),
      ],
    );
  }
}