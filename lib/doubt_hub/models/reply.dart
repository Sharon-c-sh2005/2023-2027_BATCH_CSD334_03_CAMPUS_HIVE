

import 'package:cloud_firestore/cloud_firestore.dart';                                                                                                                                                   import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String doubtId;
  final String? parentReplyId;
  final String body;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;

  Reply({
    required this.id,
    required this.doubtId,
    this.parentReplyId,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  factory Reply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reply(
      id: doc.id,
      doubtId: data['doubtId'] ?? '',
      parentReplyId: data['parentReplyId'],
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

      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doubtId': doubtId,
      'parentReplyId': parentReplyId,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }

  int get score => upvotes - downvotes;

  Reply copyWith({int? upvotes, int? downvotes}) {
    return Reply(
      id: id,
      doubtId: doubtId,
      parentReplyId: parentReplyId,
      body: body,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }
}