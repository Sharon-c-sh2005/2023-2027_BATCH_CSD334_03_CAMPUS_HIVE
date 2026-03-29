
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import 'my_project_tile.dart';
import '../../../doubt_hub/utils/colors.dart';

class MyProjectsSection extends StatelessWidget {
  final String currentUserId;

  const MyProjectsSection({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My Projects',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(height: 1, color: AppColors.background),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('projects')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final projects = snapshot.data!.docs
                  .map((d) => Project.fromFirestore(d))
                  .where((p) => p.members.contains(currentUserId))
                  .toList();

              if (projects.isEmpty) {
                return Center(
                  child: Text(
                    'No projects yet',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final project = projects[i];
                  return MyProjectTile(
                    project: project,
                    hasNotification: project.pendingRequests.isNotEmpty,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../project_model.dart';
import '../my_project_tile.dart';

class MyProjectsSection extends StatelessWidget {
  final String currentUserId;

  const MyProjectsSection({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
  children: [
    const Text(
      'My Projects',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
        color: Colors.black87,
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Container(
        height: 1,
        color: Color(0xFFF6F7FB),//Colors.grey.shade300,
      ),
    ),
  ],
),
        const SizedBox(height: 12),

        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('projects')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final projects = snapshot.data!.docs
                  .map((d) => Project.fromFirestore(d))
                  .where((p) => p.members.contains(currentUserId))
                  .toList();

              if (projects.isEmpty) {
                return const Center(child: Text('No projects yet'));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final project = projects[i];
                  return MyProjectTile(
                    project: project,
                    hasNotification:
                        project.pendingRequests.isNotEmpty,
                  );
                },
              );
            },
          ),
        ),

       
      ],
    );
  }
}*/