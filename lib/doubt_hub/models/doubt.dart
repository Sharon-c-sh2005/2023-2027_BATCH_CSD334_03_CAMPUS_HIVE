

import 'package:cloud_firestore/cloud_firestore.dart';                                                                                                                       import 'package:cloud_firestore/cloud_firestore.dart';

class Doubt {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final int replyCount;
  final List<String> tags;
  final List<String> searchKeywords;
  final bool isDeleted;

  Doubt({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.replyCount = 0,
    this.tags = const [],
    this.searchKeywords = const [],
    this.isDeleted = false,
  });

  factory Doubt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doubt(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      authorId: data['authorId'] ?? '',
     // authorName: data['authorName'] ?? 'Anonymous',
      //authorAvatar: data['authorAvatar'] ?? '#E8553A',
      authorName: (data['authorName'] ?? '').toString().trim().isEmpty 
    ? 'Anonymous' 
    : data['authorName'],
authorAvatar: (data['authorAvatar'] ?? '').toString().trim().isEmpty 
    ? '#E8553A' 
    : data['authorAvatar'],
//
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'replyCount': replyCount,
      'tags': tags,
      'searchKeywords': searchKeywords,
      'isDeleted': isDeleted,
    };
  }

  int get score => upvotes - downvotes;

  double get hotScore {
    final hoursElapsed =
        DateTime.now().difference(createdAt).inMinutes / 60.0;
    return score / (hoursElapsed < 1 ? 1 : hoursElapsed);
  }

  Doubt copyWith({
    int? upvotes,
    int? downvotes,
    int? replyCount,
    bool? isDeleted,
  }) {
    return Doubt(
      id: id,
      title: title,
      body: body,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      replyCount: replyCount ?? this.replyCount,
      tags: tags,
      searchKeywords: searchKeywords,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}