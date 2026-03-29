
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../../../doubt_hub/utils/colors.dart';

class LiveProjectCard extends StatelessWidget {
  final Project project;
  final bool requested;
  final VoidCallback onJoin;

  const LiveProjectCard({
    super.key,
    required this.project,
    required this.requested,
    required this.onJoin,
  });

  static const _black = Color(0xFF1A1A2E);

  String get _statusLabel => project.status == 'active'
      ? 'Active'
      : project.status == 'on hold'
          ? 'On Hold'
          : 'Finished';

  Color get _statusColor => project.status == 'active'
      ? const Color(0xFF22C55E)
      : project.status == 'on hold'
          ? const Color(0xFFF59E0B)
          : const Color(0xFF6B7280);

  void _showPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // COVER IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(
                project.coverImage.isNotEmpty
                    ? project.coverImage
                    : 'assets/covers/cover1.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.background,
                  child: Center(
                    child: Icon(Icons.rocket_launch_outlined,
                        color: AppColors.textTertiary, size: 40),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TITLE + STATUS
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(_statusLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // MEMBER COUNT
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${project.members.length}/${project.maxMembers} Members',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: AppColors.background, thickness: 1.5),
                  const SizedBox(height: 10),

                  // ABOUT
                  Text('ABOUT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.8,
                      )),
                  const SizedBox(height: 6),
                  Text(project.bio,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5)),

                  const SizedBox(height: 14),

                  // TECH STACK
                  Text('TECH STACK',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.8,
                      )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.techStack
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.text
                                        .withValues(alpha: 0.15)),
                              ),
                              child: Text(t,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // JOIN BUTTON — black
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: requested
                          ? null
                          : () {
                              onJoin();
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            requested ? Colors.grey.shade200 : _black,
                        foregroundColor: requested
                            ? Colors.grey.shade500
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        requested ? 'Request Pending' : 'Join Project',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // COVER IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                project.coverImage.isNotEmpty
                    ? project.coverImage
                    : 'assets/covers/cover1.png',
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: AppColors.background,
                  child: Center(
                    child: Icon(Icons.rocket_launch_outlined,
                        color: AppColors.textTertiary, size: 28),
                  ),
                ),
              ),
            ),

            // CARD BODY
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // TITLE
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // TECH STACK
                  Text(
                    project.techStack.take(3).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: AppColors.textTertiary),
                  ),

                  const SizedBox(height: 8),

                  // MEMBERS + JOIN BUTTON
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${project.members.length}/${project.maxMembers}',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.textTertiary),
                        ),
                      ),

                      // JOIN BUTTON — black
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: requested ? null : onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: requested
                                ? Colors.grey.shade100
                                : _black,
                            foregroundColor: requested
                                ? Colors.grey.shade400
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                          ),
                          child: Text(
                            requested ? 'Pending' : 'Join',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import '../project_model.dart';

class LiveProjectCard extends StatelessWidget {
  final Project project;
  final bool requested;
  final VoidCallback onJoin;

  const LiveProjectCard({
    super.key,
    required this.project,
    required this.requested,
    required this.onJoin,
  });

  static const _primary =  Color(0xFF1A1A2E);

  String get _statusLabel => project.status == 'active'
      ? 'Active'
      : project.status == 'on hold'
          ? 'On Hold'
          : 'Finished';

  Color get _statusColor => project.status == 'active'
      ? const Color(0xFF22C55E)
      : project.status == 'on hold'
          ? const Color(0xFFF59E0B)
          : const Color(0xFF6B7280);

  void _showPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // COVER IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(
                project.coverImage.isNotEmpty
                    ? project.coverImage
                    : 'assets/covers/cover1.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: _primary.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.rocket_launch_outlined,
                        color: _primary, size: 40),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TITLE + STATUS ROW
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _statusColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // MEMBER COUNT
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${project.members.length}/${project.maxMembers} Members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // BIO
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A9A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // TECH STACK
                  const Text(
                    'TECH STACK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A9A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.techStack
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _primary.withOpacity(0.2)),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // JOIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: requested ? null : () {
                        onJoin();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: requested
                            ? Colors.grey.shade200
                            : const Color(0xFF1A1A2E),
                        foregroundColor: requested
                            ? Colors.grey.shade500
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        requested ? 'Request Pending' : 'Join Project',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // COVER IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                project.coverImage.isNotEmpty
                    ? project.coverImage
                    : 'assets/covers/cover1.png',
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.rocket_launch_outlined,
                        color: _primary, size: 28),
                  ),
                ),
              ),
            ),

            // CONTENT
          // CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // TITLE
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 3),

                  // TECH STACK dots
                  Text(
                    project.techStack.take(3).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // MEMBER COUNT + JOIN BUTTON ROW
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${project.members.length}/${project.maxMembers}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),

                      // JOIN BUTTON
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: requested
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: requested ? null : onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: requested
                                  ? Colors.grey.shade100
                                  :  const Color(0xFF1A1A2E),
                              foregroundColor: requested
                                  ? Colors.grey.shade400
                                  : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                            ),
                            child: Text(
                              requested ? 'Pending' : 'Join',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




/*

import 'package:flutter/material.dart';
import '../project_model.dart';

class LiveProjectCard extends StatelessWidget {
  final Project project;
  final bool requested;
  final VoidCallback onJoin;

  const LiveProjectCard({
    super.key,
    required this.project,
    required this.requested,
    required this.onJoin,
  });

  @override
Widget build(BuildContext context) {
   final statusColor = project.status == 'active'
      ? const Color(0xFF22C55E)
      : project.status == 'on hold'
          ? const Color(0xFFF59E0B)
          : const Color(0xFF6B7280);

  final statusLabel = project.status == 'active'
      ? 'Active'
      : project.status == 'on hold'
          ? 'On Hold'
          : 'Finished';

  return SizedBox(
     height: 95,
  child: Container(
  margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        // IMAGE
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
           project.coverImage.isNotEmpty
      ? project.coverImage
      : 'assets/covers/cover1.png',
  width: 48,
  height: 49,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF5E6AD2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.rocket_launch_outlined,
        color: Color(0xFF5E6AD2),
        size: 22,
      ),
    );
  },
          ),
        ),

        const SizedBox(width: 12),

        // TITLE + BIO + STATUS
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                project.bio,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8F8F8F),
                ),
              ),
              const SizedBox(height: 4),
              // STATUS BADGE
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: statusColor.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // MEMBERS COUNT
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${project.members.length}/${project.maxMembers}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8F8F8F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // JOIN / PENDING BUTTON
        SizedBox(
          width: 76,
          height: 34,
          child: ElevatedButton(
            onPressed: requested ? null : onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: requested
                  ? Colors.grey.shade200
                  : const Color(0xFF6C63FF),
              foregroundColor: requested
                  ? Colors.grey.shade500
                  : Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              requested ? 'Pending' : 'Join',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  ),
  );



  
}
}
*/
*/