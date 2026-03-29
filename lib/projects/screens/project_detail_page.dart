
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../../../doubt_hub/utils/colors.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectId;
  final String currentUserId;

  ProjectDetailPage({
    super.key,
    required this.projectId,
    required this.currentUserId,
  });

  final ProjectService _service = ProjectService();

  static const _black = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Project>(
      stream: _service.streamProject(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: Text("Project not found")));
        }

        final pageContext = context;
        final project = snapshot.data!;
        final isOwner = project.ownerId == currentUserId;
        final isMember = project.members.contains(currentUserId);

        if (!isMember) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [

              // ── HEADER ──
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.28,
                pinned: true,
                backgroundColor: _black,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(project.coverImage, fit: BoxFit.cover),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC1A1A2E)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 60,
                        child: Text(
                          project.title.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'leave') {
                        final confirm = await showDialog<bool>(
                          context: pageContext,
                          builder: (ctx) => _confirmDialog(
                            context: ctx,
                            icon: Icons.exit_to_app,
                            iconColor: Colors.orange,
                            title: "Leave Project",
                            message:
                                "You will be removed from this project and will need to request to join again.",
                            confirmLabel: "Leave",
                            confirmColor: Colors.orange,
                          ),
                        );
                        if (confirm == true) {
                          await _service.leaveProject(
                              projectId: project.id!,
                              userId: currentUserId);
                          Navigator.of(pageContext)
                              .popUntil((route) => route.isFirst);
                        }
                      }

                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: pageContext,
                          builder: (ctx) => _confirmDialog(
                            context: ctx,
                            icon: Icons.delete_outline,
                            iconColor: Colors.red,
                            title: "Delete Project",
                            message:
                                "This will permanently delete the project and remove all members. This cannot be undone.",
                            confirmLabel: "Delete",
                            confirmColor: Colors.red,
                          ),
                        );
                        if (confirm == true) {
                          await _service.deleteProject(
                              projectId: project.id!);
                          Navigator.of(pageContext)
                              .popUntil((route) => route.isFirst);
                        }
                      }

                      if (value == 'transfer') {
                        final selectedMemberId =
                            await showDialog<String>(
                          context: pageContext,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor: AppColors.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text("Transfer Ownership",
                                      style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text)),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Select a member to transfer ownership to",
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 16),
                                  Divider(color: AppColors.background),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxHeight: 300),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: project.members
                                            .where((id) =>
                                                id != currentUserId)
                                            .map((id) =>
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pop(
                                                          ctx, id),
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .only(bottom: 10),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: AppColors
                                                          .background,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(14),
                                                      border: Border.all(
                                                          color: AppColors
                                                              .text
                                                              .withValues(
                                                                  alpha:
                                                                      0.1)),
                                                    ),
                                                    child: FutureBuilder<
                                                        DocumentSnapshot>(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'users')
                                                          .doc(id)
                                                          .get(),
                                                      builder: (_, snap) {
                                                        String name = id;
                                                        if (snap.hasData &&
                                                            snap.data!
                                                                .exists) {
                                                          final raw = (snap
                                                                      .data!
                                                                      .data()
                                                                  as Map<
                                                                      String,
                                                                      dynamic>)[
                                                                  'displayName'] ??
                                                              '';
                                                          if (raw
                                                              .isNotEmpty)
                                                            name = raw;
                                                        }
                                                        return Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 22,
                                                              backgroundColor:
                                                                  Colors.orange
                                                                      .shade100,
                                                              child: Text(
                                                                name[0]
                                                                    .toUpperCase(),
                                                                style: GoogleFonts.inter(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .orange),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    name,
                                                                    style: GoogleFonts.inter(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: AppColors
                                                                            .text),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    "Tap to transfer",
                                                                    style: GoogleFonts.inter(
                                                                        fontSize:
                                                                            11,
                                                                        color: AppColors
                                                                            .textTertiary),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 14,
                                                              color: AppColors
                                                                  .textTertiary,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      child: Text("Cancel",
                                          style: GoogleFonts.inter()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        if (selectedMemberId != null) {
                          await _service.ownerLeaveAndTransfer(
                            projectId: project.id!,
                            currentOwnerId: currentUserId,
                            newOwnerId: selectedMemberId,
                          );
                          Navigator.of(pageContext)
                              .popUntil((route) => route.isFirst);
                        }
                      }
                    },
                    itemBuilder: (_) => isOwner
                        ? [
                            PopupMenuItem(
                              value: 'transfer',
                              child: Text("Leave & Transfer Ownership",
                                  style: GoogleFonts.inter()),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text("Delete Project",
                                  style: GoogleFonts.inter(
                                      color: Colors.red)),
                            ),
                          ]
                        : [
                            PopupMenuItem(
                              value: 'leave',
                              child: Text("Leave Project",
                                  style: GoogleFonts.inter()),
                            ),
                          ],
                  ),
                ],
              ),

              // ── BODY ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ABOUT
                      _card(
                        label: 'ABOUT',
                        child: Text(
                          project.bio,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // TECH STACK
                      _card(
                        label: 'TECH STACK',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.techStack
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.text
                                              .withValues(alpha: 0.15)),
                                    ),
                                    child: Text(t,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.text,
                                        )),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // STATUS
                      _card(
                        label: 'PROJECT STATUS',
                        trailing: null,
                        child: isOwner
                            ? Row(
                                children: [
                                  _statusToggle(project, 'active',
                                      'Active', const Color(0xFF22C55E)),
                                  const SizedBox(width: 8),
                                  _statusToggle(project, 'finished',
                                      'Finished', const Color(0xFF6B7280)),
                                  const SizedBox(width: 8),
                                  _statusToggle(project, 'on hold',
                                      'On Hold', const Color(0xFFF59E0B)),
                                ],
                              )
                            : _statusBadge(project),
                      ),
                      const SizedBox(height: 12),

                      // MEMBERS
                      _card(
                        label: 'MEMBERS',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.text
                                    .withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            '${project.members.length} / ${project.maxMembers}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: project.members.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3.6,
                          ),
                          itemBuilder: (context, index) {
                            final memberId = project.members[index];
                            final isAdmin =
                                memberId == project.ownerId;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? _black.withValues(alpha: 0.07)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: isAdmin
                                        ? _black.withValues(alpha: 0.3)
                                        : AppColors.text
                                            .withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                children: [
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(memberId)
                                        .get(),
                                    builder: (_, snap) {
                                      String name = memberId;
                                      if (snap.hasData &&
                                          snap.data!.exists) {
                                        final raw = (snap.data!.data()
                                            as Map<String,
                                                dynamic>)['displayName'] ??
                                            '';
                                        if (raw.isNotEmpty) name = raw;
                                      }
                                      return CircleAvatar(
                                        radius: 13,
                                        backgroundColor: isAdmin
                                            ? _black
                                            : AppColors.background,
                                        child: Text(
                                          name[0].toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isAdmin
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(memberId)
                                          .get(),
                                      builder: (_, snap) {
                                        String name = memberId;
                                        if (snap.hasData &&
                                            snap.data!.exists) {
                                          final raw = (snap.data!.data()
                                                  as Map<String,
                                                      dynamic>)[
                                                  'displayName'] ??
                                              '';
                                          if (raw.isNotEmpty) {
                                            name = raw
                                                .split(' ')
                                                .map((w) => w.isEmpty
                                                    ? w
                                                    : w[0].toUpperCase() +
                                                        w
                                                            .substring(1)
                                                            .toLowerCase())
                                                .join(' ');
                                          }
                                        }
                                        final label =
                                            memberId == currentUserId
                                                ? '$name (You)'
                                                : name;
                                        return Text(
                                          label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.text,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (isAdmin)
                                    Text('ADMIN',
                                        style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: _black)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── REUSABLE CARD ──
  Widget _card({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.8)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ── STATUS TOGGLE BUTTON (owner) ──
  Widget _statusToggle(
      Project project, String status, String label, Color color) {
    final selected = project.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => _service.updateProjectStatus(
            projectId: project.id!, status: status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? color : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── STATUS BADGE (member read-only) ──
  Widget _statusBadge(Project project) {
    final color = project.status == 'active'
        ? const Color(0xFF22C55E)
        : project.status == 'finished'
            ? const Color(0xFF6B7280)
            : const Color(0xFFF59E0B);
    final label =
        project.status[0].toUpperCase() + project.status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  // ── CONFIRM DIALOG ──
  Widget _confirmDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: AppColors.text.withValues(alpha: 0.2)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12)),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0),
                    child: Text(confirmLabel,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


