import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminProfile extends StatelessWidget {
  const SuperAdminProfile({super.key});

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
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data =
              snap.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['displayName'] ?? 'Super Admin';
          final email = data['email'] ?? '';
          final photoUrl = data['photoUrl'] as String?;

          return CustomScrollView(
            slivers: [
              // HEADER
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1A2E), _primary],
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
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          backgroundImage: photoUrl != null &&
                                  photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
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
                            color:
                                Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Super Admin',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
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
                      // INFO
                      _card(children: [
                        _infoRow(Icons.mail_outline, 'Email', email),
                        const Divider(height: 24),
                        _infoRow(Icons.shield_outlined, 'Role',
                            'Super Administrator'),
                      ]),

                      const SizedBox(height: 20),

                      // PENDING REQUESTS SECTION
                      Row(
                        children: [
                          const Text('Forum Account Requests',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          const SizedBox(width: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('forum_requests')
                                .where('status', isEqualTo: 'pending')
                                .snapshots(),
                            builder: (_, s) {
                              final count =
                                  s.data?.docs.length ?? 0;
                              if (count == 0) {
                                return const SizedBox();
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Text('$count',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold)),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // REQUESTS LIST
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('forum_requests')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return _card(children: [
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('No requests yet',
                                      style: TextStyle(
                                          color: _textSecondary)),
                                ),
                              ),
                            ]);
                          }

                          return Column(
                            children: docs.map((doc) {
                              final d = doc.data()
                                  as Map<String, dynamic>;
                              return _requestCard(
                                  context, doc.id, d);
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // SIGN OUT
                      _card(children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(10),
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
                      const SizedBox(height: 32),
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

  Widget _requestCard(
      BuildContext context, String docId, Map<String, dynamic> d) {
    final status = d['status'] ?? 'pending';
    final isPending = status == 'pending';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E6EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary)),
                    const SizedBox(height: 2),
                    Text(d['email'] ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: _textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon,
                        color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(status.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _detailRow(Icons.groups_outlined, 'Forum',
              d['forumName'] ?? ''),
          const SizedBox(height: 4),
          _detailRow(
              Icons.phone_outlined, 'Phone', d['phone'] ?? ''),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              d['reason'] ?? '',
              style: const TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  height: 1.5),
            ),
          ),

          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _reject(context, docId, d['userId']),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _approve(context, docId, d),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context, String docId,
      Map<String, dynamic> d) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update request status
      batch.update(
        FirebaseFirestore.instance
            .collection('forum_requests')
            .doc(docId),
        {'status': 'approved'},
      );

      // 2. Create forum document
      final forumRef =
          FirebaseFirestore.instance.collection('forums').doc();
      batch.set(forumRef, {
        'name': d['forumName'] ?? '',
        'description': 'Managed by ${d['name']}',
        'category': 'General',
        'adminIds': [d['userId']],
        'memberCount': 0,
        'colorIndex': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update user role to forumAdmin + assign forumId + forumName
      batch.update(
        FirebaseFirestore.instance
            .collection('users')
            .doc(d['userId']),
        {
          'role': 'forumAdmin',
          'profileComplete': true,
          'forumId': forumRef.id,
          'forumName': d['forumName'] ?? '',
        },
      );

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${d['name']} approved as forum admin!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, String docId,
      String? userId) async {
    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text(
            'Are you sure you want to reject this forum request?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update request
      batch.update(
        FirebaseFirestore.instance
            .collection('forum_requests')
            .doc(docId),
        {'status': 'rejected'},
      );

      // Update user role back to reflect rejection
      if (userId != null) {
        batch.update(
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId),
          {'role': 'rejected'},
        );
      }

      await batch.commit();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
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
                style: const TextStyle(
                    fontSize: 11, color: _textSecondary)),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 12, color: _textSecondary)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}