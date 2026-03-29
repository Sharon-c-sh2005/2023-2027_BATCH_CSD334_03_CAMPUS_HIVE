import 'package:cloud_firestore/cloud_firestore.dart';

class ForumModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? logoUrl;
  final String? bannerUrl;
  final List<String> adminIds;
  final int memberCount;
  final int colorIndex;
  final bool isActive;
  final DateTime createdAt;

  ForumModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.bannerUrl,
    required this.adminIds,
    this.memberCount = 0,
    this.colorIndex = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ForumModel.fromMap(Map<String, dynamic> map, String id) {
    return ForumModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      logoUrl: map['logoUrl'],
      bannerUrl: map['bannerUrl'],
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      colorIndex: map['colorIndex'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'category': category,
        'logoUrl': logoUrl,
        'bannerUrl': bannerUrl,
        'adminIds': adminIds,
        'memberCount': memberCount,
        'colorIndex': colorIndex,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}