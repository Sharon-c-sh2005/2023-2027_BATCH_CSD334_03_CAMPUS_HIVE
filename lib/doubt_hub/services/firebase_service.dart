import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doubt.dart';
import '../models/reply.dart';
import '../models/vote.dart';
import '../utils/helpers.dart';
class FirebaseService {
final FirebaseFirestore _db = FirebaseFirestore.instance;
// ═══════════════════════════════════════════════
// DOUBTS
// ═══════════════════════════════════════════════
/*
Stream<List<Doubt>> getDoubtsStream() {
return _db
.collection('doubts')
.where('isDeleted', isEqualTo: false)
.orderBy('createdAt', descending: true)
.snapshots()
.map((snapshot) =>
snapshot.docs.map((doc) => Doubt.fromFirestore(doc)).toList())
.handleError((e) {
debugPrint('Error in getDoubtsStream: $e');
return <Doubt>[];
});
}*/
Stream<List<Doubt>> getDoubtsStream() {
  return _db
    .collection('doubts')
    .where('isDeleted', isEqualTo: false)
    .snapshots()
    .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => Doubt.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    })
    .handleError((e) {
      debugPrint('Error in getDoubtsStream: $e');
      return <Doubt>[];
    });
}

Future<List<Doubt>> getDoubtsPaginated({
DocumentSnapshot? lastDoc,
int pageSize = 15,
}) async {
Query query = _db
.collection('doubts')
.where('isDeleted', isEqualTo: false)
.orderBy('createdAt', descending: true)
.limit(pageSize);
if (lastDoc != null) {
query = query.startAfterDocument(lastDoc);
}
final snapshot = await query.get();
return snapshot.docs.map((doc) => Doubt.fromFirestore(doc)).toList();
}
Future<Doubt?> getDoubt(String id) async {
final doc = await _db.collection('doubts').doc(id).get();
if (!doc.exists) return null;
return Doubt.fromFirestore(doc);
}
Future<String> createDoubt({
required String title,
required String body,
required List<String> tags,
required String authorId,
required String authorName,
required String authorAvatar,
}) async {
final docRef = await _db.collection('doubts').add({
'title': title,
'body': body,
'tags': tags,
'authorId': authorId,
'authorName': authorName,
'authorAvatar': authorAvatar,
'createdAt': FieldValue.serverTimestamp(),
'upvotes': 0,
'downvotes': 0,
'replyCount': 0,
'searchKeywords': generateSearchKeywords(title, body),
'isDeleted': false,
});
return docRef.id;
}
Future<void> deleteDoubt(String doubtId) async {
await _db.collection('doubts').doc(doubtId).update({
'isDeleted': true,
});
}
// ═══════════════════════════════════════════════
// REPLIES (Sub-collection under doubts)
// ═══════════════════════════════════════════════
Stream<List<Reply>> getRepliesStream(String doubtId) {
return _db
.collection('doubts')
.doc(doubtId)
.collection('replies')
.orderBy('createdAt', descending: false)
.snapshots()
.map((snapshot) =>
snapshot.docs.map((doc) => Reply.fromFirestore(doc)).toList())
.handleError((e) {
debugPrint('Error in getRepliesStream: $e');
return <Reply>[];
});
}
Future<String> addReply({
required String doubtId,
required String body,
required String authorId,
required String authorName,
required String authorAvatar,
String? parentReplyId,
}) async {
final batch = _db.batch();
final replyRef =
_db.collection('doubts').doc(doubtId).collection('replies').doc();
batch.set(replyRef, {
'doubtId': doubtId,
'parentReplyId': parentReplyId,
'body': body,
'authorId': authorId,
'authorName': authorName,
'authorAvatar': authorAvatar,
'createdAt': FieldValue.serverTimestamp(),
'upvotes': 0,
'downvotes': 0,
});
// Use transaction to safely increment reply count
final doubtRef = _db.collection('doubts').doc(doubtId);
await _db.runTransaction((transaction) async {
final doubtDoc = await transaction.get(doubtRef);
if (!doubtDoc.exists) throw Exception('Doubt not found');
final currentCount = doubtDoc.data()?['replyCount'] ?? 0;
transaction.update(doubtRef, {'replyCount': currentCount + 1});
transaction.set(replyRef, {
'doubtId': doubtId,
'parentReplyId': parentReplyId,
'body': body,
'authorId': authorId,
'authorName': authorName,
'authorAvatar': authorAvatar,
'createdAt': FieldValue.serverTimestamp(),
'upvotes': 0,
'downvotes': 0,
});
});
return replyRef.id;
}
// ═══════════════════════════════════════════════
// VOTING (Transaction-based for concurrency)
// ═══════════════════════════════════════════════
Future<void> vote({
required String userId,
required String itemId,
required String itemCollection, // 'doubts' or path to reply
required VoteType? newVoteType,
String? doubtIdForReply, // needed if voting on a reply
}) async {
try {
final voteDocId = '${userId}_$itemId';
final voteRef = _db.collection('votes').doc(voteDocId);
DocumentReference itemRef;
if (doubtIdForReply != null) {
itemRef = _db
.collection('doubts')
.doc(doubtIdForReply)
.collection('replies')
.doc(itemId);
} else {
itemRef = _db.collection('doubts').doc(itemId);
}
await _db.runTransaction((transaction) async {
final voteDoc = await transaction.get(voteRef);
final itemDoc = await transaction.get(itemRef);
if (!itemDoc.exists) throw Exception('Item not found');
final data = itemDoc.data() as Map<String, dynamic>;
VoteType? currentVote;
if (voteDoc.exists) {
final voteData = voteDoc.data() as Map<String, dynamic>;
currentVote = voteData['type'] == 'up' ? VoteType.up : VoteType.down;
}
int upvotes = data['upvotes'] ?? 0;
int downvotes = data['downvotes'] ?? 0;
// Remove previous vote
if (currentVote == VoteType.up) upvotes--;
if (currentVote == VoteType.down) downvotes--;
// Apply new vote
if (newVoteType == VoteType.up) upvotes++;
if (newVoteType == VoteType.down) downvotes++;
// Update vote document
if (newVoteType == null) {
transaction.delete(voteRef);
} else {
transaction.set(voteRef, {
'userId': userId,
'itemId': itemId,
'type': newVoteType == VoteType.up ? 'up' : 'down',
});
}
// Update item vote counts
transaction.update(itemRef, {
'upvotes': upvotes,
'downvotes': downvotes,
});
});
} catch (e) {
debugPrint('Error voting: $e');
rethrow;
}
}
Future<Map<String, VoteType>> getUserVotes(String userId) async {
final snapshot =
await _db.collection('votes').where('userId', isEqualTo: userId).get();
final votes = <String, VoteType>{};
for (final doc in snapshot.docs) {
final data = doc.data();
votes[data['itemId']] =
data['type'] == 'up' ? VoteType.up : VoteType.down;
}
return votes;
}
// ═══════════════════════════════════════════════
// SEARCH
// ═══════════════════════════════════════════════
Future<List<Doubt>> searchDoubts(String query) async {
final keyword = query.toLowerCase().trim();
if (keyword.isEmpty) return [];
final snapshot = await _db
.collection('doubts')
.where('isDeleted', isEqualTo: false)
.where('searchKeywords', arrayContains: keyword)
.limit(20)
.get();
return snapshot.docs.map((doc) => Doubt.fromFirestore(doc)).toList();
}
}