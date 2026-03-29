import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final List<String> seenBy;
  final String type;
final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.seenBy,
    required this.type,         // ADD
  this.imageUrl,  
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
      type: data['type'] ?? 'text',
imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': seenBy,
      'type': 'text',
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}