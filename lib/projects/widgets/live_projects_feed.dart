import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import 'project_card_live.dart';
import '../services/project_service.dart';

class LiveProjectsFeed extends StatelessWidget {
  final String searchQuery;
  final String category;
  final String currentUserId;
  final String status;

  const LiveProjectsFeed({
    super.key,
    required this.searchQuery,
    required this.category,
    required this.currentUserId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:  ProjectService().getProjectsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = snapshot.data!.docs
            .map((doc) => Project.fromFirestore(doc))
            .where((project) {
              // ❌ DO NOT show projects user already joined
              if (project.members.contains(currentUserId)) return false;
              if (project.members.length >= project.maxMembers) return false;
  final q = searchQuery.toLowerCase();

  

  final matchesSearch = q.isEmpty ||
      project.title.toLowerCase().contains(q) ||
      project.bio.toLowerCase().contains(q) ||
      project.techStack.any((t) => t.toLowerCase().contains(q));

  final matchesCategory = category.isEmpty ||
      project.categories.contains(category) ||
      project.techStack.contains(category);

  final matchesStatus = status.isEmpty || project.status == status;
  return matchesSearch && matchesCategory && matchesStatus;

 
            })
            .toList();

        if (projects.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No live projects found'),
          );
        }
return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: projects.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.88,
  ),
  itemBuilder: (context, index) {
    final project = projects[index];
    final alreadyRequested =
        project.pendingRequests.contains(currentUserId);

    return LiveProjectCard(
      project: project,
      requested: alreadyRequested,
      onJoin: () async {
        if (project.requiresApproval) {
          await ProjectService().requestToJoinProject(
            projectId: project.id!,
            userId: currentUserId,
          );
        } else {
          await ProjectService().joinProject(
            projectId: project.id!,
            userId: currentUserId,
          );
        }
      },
    );
  },
);



      },
    );
  }
}
