
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/doubts_provider.dart';
import '../../auth/auth_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../widgets/avatar_widget.dart';
import '../../projects/models/project_model.dart';
import 'doubt_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _editing = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoubtsProvider>();
    final name = provider.userName;
    final userId = provider.userId;

    final myDoubts = provider.doubts
        .where((d) => !d.isDeleted && d.authorId == userId)
        .toList();

    final totalUpvotes =
        myDoubts.fold<int>(0, (sum, d) => sum + d.upvotes);
    final totalReplies =
        myDoubts.fold<int>(0, (sum, d) => sum + d.replyCount);
    final votesGiven = provider.userVotes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── AVATAR + NAME ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      AvatarWidget(
                        name: name,
                        color: AppColors.getAvatarColor(name),
                        size: 80,
                      ),
                      const SizedBox(height: 14),
                      if (_editing)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your name',
                                    hintStyle: GoogleFonts.inter(
                                        color: AppColors.textTertiary),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2),
                                    ),
                                  ),
                                  onSubmitted: (_) async {
                                    if (_nameController.text
                                        .trim()
                                        .isNotEmpty) {
                                      await _authService
                                          .updateDisplayName(
                                              _nameController.text
                                                  .trim());
                                    }
                                    setState(() => _editing = false);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  if (_nameController.text
                                      .trim()
                                      .isNotEmpty) {
                                    await _authService.updateDisplayName(
                                        _nameController.text.trim());
                                  }
                                  setState(() => _editing = false);
                                },
                                child: const Icon(Icons.check_circle,
                                    size: 28, color: AppColors.success),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            _nameController.text = name;
                            HapticFeedback.lightImpact();
                            setState(() => _editing = true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit,
                                  size: 16,
                                  color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Community Member',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── STATS ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatCard(
                          icon: Icons.help_outline,
                          label: 'Doubts',
                          value: myDoubts.length,
                          color: AppColors.primary),
                      _StatCard(
                          icon: Icons.keyboard_arrow_up,
                          label: 'Upvotes',
                          value: totalUpvotes,
                          color: AppColors.upvote),
                      _StatCard(
                          icon: Icons.chat_bubble_outline,
                          label: 'Replies',
                          value: totalReplies,
                          color: AppColors.accent),
                      _StatCard(
                          icon: Icons.thumb_up_outlined,
                          label: 'Votes Given',
                          value: votesGiven,
                          color: AppColors.downvote),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── MY DOUBTS ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'My Doubts',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                if (myDoubts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'No doubts posted yet.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...myDoubts.map((doubt) => GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoubtDetailScreen(
                                  doubtId: doubt.id),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.text
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doubt.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatTimeAgo(doubt.createdAt),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.keyboard_arrow_up,
                                      size: 14,
                                      color: AppColors.upvote),
                                  Text(
                                    '${doubt.upvotes}',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.chat_bubble_outline,
                                      size: 12,
                                      color: AppColors.textTertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doubt.replyCount} replies',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),

                const SizedBox(height: 24),

                // ── PROJECTS JOINED ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Projects Joined',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('projects')
                      .where('members', arrayContains: userId)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      );
                    }
                    final projects = snap.data!.docs
                        .map((d) => Project.fromFirestore(d))
                        .toList();

                    if (projects.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'No projects joined yet.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: projects
                          .map((project) => Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 5),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Image.asset(
                                        project.coverImage,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                          width: 48,
                                          height: 48,
                                          color: const Color(0xFF1A1A2E)
                                              .withValues(alpha: 0.1),
                                          child: const Icon(
                                              Icons
                                                  .rocket_launch_outlined,
                                              size: 20,
                                              color:
                                                  Color(0xFF1A1A2E)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: AppColors.text,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            project.techStack
                                                .take(3)
                                                .join(' • '),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: project.ownerId == userId
                                            ? const Color(0xFF1A1A2E)
                                                .withValues(alpha: 0.1)
                                            : Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        project.ownerId == userId
                                            ? 'Owner'
                                            : 'Member',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: project.ownerId ==
                                                  userId
                                              ? const Color(0xFF1A1A2E)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    );
                    


                  },
                ),

                const SizedBox(height: 24),

                // ── MY EVENTS ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('My Events',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text)),
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('registrations')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, regSnap) {
                    if (!regSnap.hasData) return const SizedBox();
                    final docs = regSnap.data!.docs;

                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('No events registered yet.',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ),
                      );
                    }

                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final eventId = d['eventId'] ?? '';
                        final regStatus = d['status'] ?? 'approved';

                        final statusColor = regStatus == 'approved'
                            ? Colors.green
                            : regStatus == 'pending'
                                ? Colors.orange
                                : Colors.red;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('events')
                              .doc(eventId)
                              .get(),
                          builder: (context, evSnap) {
                            if (!evSnap.hasData) return const SizedBox();
                               // if event was deleted, hide it
                            if (evSnap.data?.exists == false) return const SizedBox();

                            final ev = evSnap.data?.data()
                                    as Map<String, dynamic>? ??
                                {};
                            final title = ev['title'] ?? 'Event';
                            final date = ev['startDate'] != null
                                ? (ev['startDate'] as Timestamp).toDate()
                                : null;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                        Icons.confirmation_num_outlined,
                                        color: AppColors.primary,
                                        size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        if (date != null)
                                          Text(
                                            '${date.day}/${date.month}/${date.year}',
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(regStatus.toUpperCase(),
                                        style: TextStyle(
                                            color: statusColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── ACCOUNT / SIGN OUT ──


                // ── ACCOUNT / SIGN OUT ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                  'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await _authService.signOut();
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout,
                                  size: 20, color: AppColors.error),
                              const SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right,
                                  size: 16,
                                  color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 42) / 2;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/doubts_provider.dart';
import '../../auth/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/avatar_widget.dart';


class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});
@override
State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
final AuthService _authService = AuthService();
bool _editing = false;
final _nameController = TextEditingController();
@override
void dispose() {
_nameController.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
final provider = context.watch<DoubtsProvider>();
final name = provider.userName;

final activeDoubts = provider.doubts
    .where((d) => !d.isDeleted && d.authorName == name)
    .toList();
final totalUpvotes = activeDoubts.fold<int>(0, (sum, d) => sum + d.upvotes);
final totalReplies =
    activeDoubts.fold<int>(0, (sum, d) => sum + d.replyCount);
/*
final activeDoubts =
provider.doubts.where((d) => !d.isDeleted && d.authorName == name);
final totalUpvotes = activeDoubts.fold<int>(0, (sum, d) => sum + d.upvotes);
final totalReplies =
activeDoubts.fold<int>(0, (sum, d) => sum + d.replyCount);
*/
final votesGiven = provider.userVotes.length;
return Scaffold(
backgroundColor: AppColors.background,
body: CustomScrollView(
slivers: [
SliverAppBar(
floating: true,
backgroundColor: AppColors.surface,
surfaceTintColor: Colors.transparent,
title: Text(
'Profile',
style: GoogleFonts.inter(
fontSize: 24,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
),
SliverToBoxAdapter(
child: Column(
children: [
// Profile section
Padding(
padding: const EdgeInsets.symmetric(vertical: 28),
child: Column(
children: [
AvatarWidget(
name: name,
color: AppColors.getAvatarColor(name),
size: 80,
),
const SizedBox(height: 14),
if (_editing)
Padding(
padding: const EdgeInsets.symmetric(horizontal: 40),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Expanded(
child: TextField(
controller: _nameController,
autofocus: true,
textAlign: TextAlign.center,
style: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
decoration: InputDecoration(
hintText: 'Enter your name',
hintStyle: GoogleFonts.inter(
color: AppColors.textTertiary,
),
border: UnderlineInputBorder(
borderSide: BorderSide(
color: AppColors.primary,
width: 2,
),
),
focusedBorder: UnderlineInputBorder(
borderSide: BorderSide(
color: AppColors.primary,
width: 2,
),
),
),
onSubmitted: (_) async {
if (_nameController.text
.trim()
.isNotEmpty) {
await _authService.updateDisplayName(
_nameController.text.trim());
}
setState(() => _editing = false);
},
),
),
const SizedBox(width: 10),
GestureDetector(
onTap: () async {
if (_nameController.text.trim().isNotEmpty) {
await _authService.updateDisplayName(
_nameController.text.trim());
}
setState(() => _editing = false);
},
child: const Icon(
Icons.check_circle,
size: 28,
color: AppColors.success,
),
),
],
),
)
else
GestureDetector(
onTap: () {
_nameController.text = name;
HapticFeedback.lightImpact();
setState(() => _editing = true);
},
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
name,
style: GoogleFonts.inter(
fontSize: 22,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(width: 8),
const Icon(
Icons.edit,
size: 16,
color: AppColors.textTertiary,
),
],
),
),
const SizedBox(height: 6),
Text(
'Community Member',
style: GoogleFonts.inter(
fontSize: 13,
color: AppColors.textTertiary,
),
),
],
),
),
// Stats grid
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: Wrap(
spacing: 10,
runSpacing: 10,
children: [
_StatCard(
icon: Icons.help_outline,
label: 'Doubts',
value: activeDoubts.length,
color: AppColors.primary,
),
_StatCard(
icon: Icons.keyboard_arrow_up,
label: 'Upvotes',
value: totalUpvotes,
color: AppColors.upvote,
),
_StatCard(
icon: Icons.chat_bubble_outline,
label: 'Replies',
value: totalReplies,
color: AppColors.accent,
),
_StatCard(
icon: Icons.thumb_up_outlined,
label: 'Votes Given',
value: votesGiven,
color: AppColors.downvote,
),
],
),
),
// About section
Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 8),
Text(
'About',
style: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(height: 12),
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(14),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Icon(
Icons.info_outline,
size: 20,
color: AppColors.textSecondary,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'Ask questions, share knowledge, and help others in the community. Your contributions make everyone smarter.',
style: GoogleFonts.inter(
fontSize: 14,
color: AppColors.textSecondary,
height: 1.4,
),
),
),
],
),
),
// Sign out
const SizedBox(height: 24),
Text(
'Account',
style: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(height: 12),
GestureDetector(
onTap: () {
HapticFeedback.lightImpact();
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Sign Out'),
content: const Text(
'Are you sure you want to sign out?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx),
child: const Text('Cancel'),
),
TextButton(
onPressed: () async {
Navigator.pop(ctx);
await _authService.signOut();
},
style: TextButton.styleFrom(
foregroundColor: AppColors.error,
),
child: const Text('Sign Out'),
),
],
),
);
},
child: Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(14),
),
child: Row(
children: [
const Icon(
Icons.logout,
size: 20,
color: AppColors.error,
),
const SizedBox(width: 12),
Text(
'Sign Out',
style: GoogleFonts.inter(
fontSize: 15,
fontWeight: FontWeight.w500,
color: AppColors.error,
),
),
const Spacer(),
const Icon(
Icons.chevron_right,
size: 16,
color: AppColors.textTertiary,
),
],
),
),
),
const SizedBox(height: 80),
],
),
),
],
),
),
],
),
);
}
}
class _StatCard extends StatelessWidget {
final IconData icon;
final String label;
final int value;
final Color color;
const _StatCard({
required this.icon,
required this.label,
required this.value,
required this.color,
});
@override
Widget build(BuildContext context) {
final width = (MediaQuery.of(context).size.width - 42) / 2;
return SizedBox(
width: width,
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(14),
),
child: Column(
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: color.withValues(alpha: 0.1),
shape: BoxShape.circle,
),
child: Icon(icon, size: 20, color: color),
),
const SizedBox(height: 8),
Text(
'$value',
style: GoogleFonts.inter(
fontSize: 24,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(height: 2),
Text(
label,
style: GoogleFonts.inter(
fontSize: 12,
fontWeight: FontWeight.w500,
color: AppColors.textSecondary,
),
),
],
),
),
);
}
}
*/