import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatService {
  final _db = FirebaseFirestore.instance;

  // STREAM MESSAGES — real time
  Stream<List<Message>> streamMessages(String projectId) {
    return _db
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  // SEND MESSAGE
  Future<void> sendMessage({
    required String projectId,
    required String senderId,
    required String text,
  }) async {
    await _db
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [senderId],
      'type': 'text',
    });

    // UPDATE last message preview
    await _db.collection('chats').doc(projectId).set({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  // MARK MESSAGES AS SEEN
  Future<void> markAsSeen({
    required String projectId,
    required String userId,
  }) async {
  /*  final unread = await _db
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .where('seenBy', arrayContains: userId)
        .get();*/

    // get messages NOT seen by this user
    final allMessages = await _db
        .collection('chats')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();

    final batch = _db.batch();
    for (final doc in allMessages.docs) {
      final seenBy = List<String>.from(doc['seenBy'] ?? []);
      if (!seenBy.contains(userId)) {
        batch.update(doc.reference, {
          'seenBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
    await batch.commit();
  }



// UPLOAD IMAGE AND SEND
Future<void> sendImage({
  required String projectId,
  required String senderId,
  required XFile imageFile,
}) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('chat_images')
      .child(projectId)
      .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

  await ref.putFile(File(imageFile.path));
  final imageUrl = await ref.getDownloadURL();

  await _db
      .collection('chats')
      .doc(projectId)
      .collection('messages')
      .add({
    'senderId': senderId,
    'text': '',
    'imageUrl': imageUrl,
    'timestamp': FieldValue.serverTimestamp(),
    'seenBy': [senderId],
    'type': 'image',
  });
}


  // GET UNREAD COUNT FOR A PROJECT
Stream<int> streamUnreadCount({
  required String projectId,
  required String userId,
}) {
  return _db
      .collection('chats')
      .doc(projectId)
      .collection('messages')
      .snapshots()
      .map((snap) {
    int count = 0;
    for (final doc in snap.docs) {
      final seenBy = List<String>.from(doc['seenBy'] ?? []);
      if (!seenBy.contains(userId)) count++;
    }
    return count;
  });
}
}