
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectActivity {
  final String message;
  final Timestamp timestamp;

  ProjectActivity({
    required this.message,
    required this.timestamp,
  });

  factory ProjectActivity.fromMap(Map<String, dynamic> map) {
    return ProjectActivity(
      message: map['message'] ?? '',
      timestamp: map['timestamp'] is Timestamp
        ? map['timestamp'] as Timestamp
        : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': timestamp,
    };
  }
}



class Project {
  final String? id;
  final String title;
  final String bio;
  final String ownerId;

  final List<String> techStack;
  final List<String> categories; // NEW
  final String status; // "active" | "finished"
  final String coverImage;
  final List<ProjectActivity> activities;
  final int maxMembers;
  final bool requiresApproval;

  final List<String> members;
  final List<String> pendingRequests;

  final Timestamp createdAt;

  Project({
    this.id,
    required this.title,
    required this.bio,
    required this.ownerId,
    required this.techStack,
    required this.categories,
    required this.status,
    required this.maxMembers,
    required this.coverImage,
    required this.activities,
    required this.requiresApproval,
    required this.members,
    required this.pendingRequests,
    required this.createdAt,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      bio: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      techStack: List<String>.from(data['techStack'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      status: data['status'] ?? 'active',
      maxMembers: data['maxMembers'] ?? 1,
      coverImage: data['coverImage'] ?? 'assets/stacks/default.png',
      requiresApproval: !(data['isOpenJoin'] ?? true),
      members: List<String>.from(data['members'] ?? []),
      pendingRequests: List<String>.from(data['pendingRequests'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      activities: (data['activities'] as List<dynamic>? ?? [])
    .map((e) => ProjectActivity.fromMap(e))
    .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': bio,
      'ownerId': ownerId,
      'techStack': techStack,
      'categories': categories,
      'status': status,
      'maxMembers': maxMembers,
      'coverImage': coverImage,
      'isOpenJoin': !requiresApproval,
      'members': members,
      'pendingRequests': pendingRequests,
      'createdAt': createdAt,
      'activities': activities.map((e) => e.toMap()).toList(),
    };
  }
}
