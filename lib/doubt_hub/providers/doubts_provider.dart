import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/doubt.dart';
import '../models/reply.dart';
import '../models/vote.dart';
import '../services/firebase_service.dart';
import '../../auth/auth_service.dart';
import '../utils/colors.dart';


enum FilterType { hot, recent, unsolved }


class DoubtsProvider extends ChangeNotifier {
final FirebaseService _firebaseService = FirebaseService();
final AuthService _authService = AuthService();
List<Doubt> _doubts = [];
Map<String, VoteType> _userVotes = {};
FilterType _filter = FilterType.hot;
String _searchQuery = '';
bool _isLoading = true;
StreamSubscription? _doubtsSubscription;
// ✅ FIX: Cache for replies per doubt (used for optimistic vote updates)
// ignore: prefer_final_fields
Map<String, List<Reply>> _repliesCache = {};
List<Doubt> get doubts => _doubts;
FilterType get filter => _filter;
String get searchQuery => _searchQuery;
bool get isLoading => _isLoading;
Map<String, VoteType> get userVotes => _userVotes;
String get userId => _authService.userId;
//String get userName => _authService.displayName;
String get userName {
  final name = _authService.displayName;
  if (name.isEmpty || name == 'Anonymous') {
    return _authService.currentUser?.email?.split('@').first ?? 'Anonymous';
  }
  return name;
}

List<Doubt> get filteredDoubts {
var result = _doubts.where((d) => !d.isDeleted).toList();
// Apply search
if (_searchQuery.trim().isNotEmpty) {
final q = _searchQuery.toLowerCase().trim();
result = result.where((d) {
return d.title.toLowerCase().contains(q) ||
d.body.toLowerCase().contains(q) ||
d.tags.any((t) => t.toLowerCase().contains(q));
}).toList();
}
// Apply filter
switch (_filter) {
case FilterType.hot:
result.sort((a, b) => b.hotScore.compareTo(a.hotScore));
break;
case FilterType.recent:
result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
break;
case FilterType.unsolved:
result = result.where((d) => d.replyCount == 0).toList();
result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
break;
}
return result;
}
// ─────────────── INIT ───────────────
void init() {
// 1️⃣Show demo doubts immediately
_doubts = _generateDemoData();
_isLoading = false;
notifyListeners();
// 2️⃣Listen to Firebase in background
try {
  /*
_doubtsSubscription = _firebaseService.getDoubtsStream().listen(
(firestoreDoubts) {
final demoDoubts = _generateDemoData();
final combined = [...demoDoubts, ...firestoreDoubts];

// Remove duplicates by ID
final uniqueDoubts = <String, Doubt>{};
for (final d in combined) {
uniqueDoubts[d.id] = d;
}
_doubts = uniqueDoubts.values.toList()
..sort((a, b) => b.createdAt.compareTo(a.createdAt));
notifyListeners();
},*/
_doubtsSubscription = _firebaseService.getDoubtsStream().listen(
  (firestoreDoubts) {
    _doubts = firestoreDoubts;
    notifyListeners();
  },
onError: (e) {
debugPrint('Error listening to doubts: $e');
// Keep demo doubts visible if Firestore fails
},
cancelOnError: false,
);
} catch (e) {
debugPrint('Failed to initialize doubts stream: $e');
// Keep demo doubts
}
// 3️⃣Load user votes
_loadUserVotes();
}
List<Doubt> _generateDemoData() {
return [
Doubt(
id: 'demo1',
title: 'How to learn Flutter?',
body:
'I\'m new to Flutter and want to know the best way to start learning it.',
authorId: 'user1',
authorName: 'Alex',
authorAvatar: '#E8553A',
tags: ['flutter', 'learning'],
createdAt: DateTime.now().subtract(const Duration(days: 2)),
upvotes: 12,
downvotes: 1,
replyCount: 3,
isDeleted: false,
),
Doubt(
id: 'demo2',
title: 'State management best practices',
body: 'What\'s the best approach for managing state in Flutter apps?',
authorId: 'user2',
authorName: 'Jordan',
authorAvatar: '#1A8D7C',
tags: ['flutter', 'state-management'],
createdAt: DateTime.now().subtract(const Duration(days: 1)),
upvotes: 8,
downvotes: 0,
replyCount: 2,
isDeleted: false,
),
];
}
// ─────────────── USER VOTES ───────────────
Future<void> _loadUserVotes() async {
try {
_userVotes = await _firebaseService.getUserVotes(userId);
notifyListeners();
} catch (e) {
debugPrint('Error loading votes: $e');
}
}
// ─────────────── FILTER & SEARCH ───────────────
void setFilter(FilterType filter) {
_filter = filter;
notifyListeners();
}
void setSearchQuery(String query) {
_searchQuery = query;
notifyListeners();
}
VoteType? getVote(String itemId) => _userVotes[itemId];
// ─────────────── VOTING ───────────────
Future<void> voteOnDoubt(String doubtId, VoteType voteType) async {
final currentVote = _userVotes[doubtId];
final newVote = currentVote == voteType ? null : voteType;
final doubtIndex = _doubts.indexWhere((d) => d.id == doubtId);
if (doubtIndex == -1) return;
final doubt = _doubts[doubtIndex];
int newUpvotes = doubt.upvotes;
int newDownvotes = doubt.downvotes;
if (currentVote == VoteType.up) newUpvotes--;
if (currentVote == VoteType.down) newDownvotes--;
if (newVote == VoteType.up) newUpvotes++;
if (newVote == VoteType.down) newDownvotes++;
_doubts[doubtIndex] = doubt.copyWith(
upvotes: newUpvotes,
downvotes: newDownvotes,
);
if (newVote == null) {
_userVotes.remove(doubtId);
} else {
_userVotes[doubtId] = newVote;
}
notifyListeners();
try {
await _firebaseService.vote(
userId: userId,
itemId: doubtId,
itemCollection: 'doubts',
newVoteType: newVote,
);
} catch (e) {
// Rollback on failure
_doubts[doubtIndex] = doubt;
if (currentVote != null) {
_userVotes[doubtId] = currentVote;
} else {
_userVotes.remove(doubtId);
}
notifyListeners();
debugPrint('Vote failed: $e');
}
}
// ✅ FIX: Optimistically update reply vote counts + re-sort
Future<void> voteOnReply({
required String replyId,
required String doubtId,
required VoteType voteType,
}) async {
final currentVote = _userVotes[replyId];
final newVote = currentVote == voteType ? null : voteType;
// Optimistically update vote counts in cache and re-sort
if (_repliesCache.containsKey(doubtId)) {
final replies = _repliesCache[doubtId]!;
final idx = replies.indexWhere((r) => r.id == replyId);
if (idx != -1) {
final r = replies[idx];
int newUp = r.upvotes;
int newDown = r.downvotes;
if (currentVote == VoteType.up) newUp--;
if (currentVote == VoteType.down) newDown--;
if (newVote == VoteType.up) newUp++;
if (newVote == VoteType.down) newDown++;
replies[idx] = r.copyWith(upvotes: newUp, downvotes: newDown);
// ✅ Re-sort: highest net score first
replies.sort((a, b) =>
(b.upvotes - b.downvotes).compareTo(a.upvotes - a.downvotes));
}
}
if (newVote == null) {
_userVotes.remove(replyId);
} else {
_userVotes[replyId] = newVote;
}
notifyListeners();
try {
await _firebaseService.vote(
userId: userId,
itemId: replyId,
itemCollection: 'replies',
newVoteType: newVote,
doubtIdForReply: doubtId,
);
} catch (e) {
// Rollback on failure
if (currentVote != null) {
_userVotes[replyId] = currentVote;
} else {
_userVotes.remove(replyId);
}
notifyListeners();
debugPrint('Reply vote failed: $e');
}
}
// ─────────────── CREATE & DELETE ───────────────
Future<String> createDoubt({
required String title,
required String body,
required List<String> tags,
}) async {
try {
final avatarColor = AppColors.getAvatarColor(userName);
return await _firebaseService.createDoubt(
title: title,
body: body,
tags: tags,
authorId: userId,
authorName: userName,
authorAvatar:
'#${avatarColor.toARGB32().toRadixString(16).substring(2)}',
);
} catch (e) {
debugPrint('Error creating doubt: $e');
rethrow;
}
}
Future<void> deleteDoubt(String doubtId) async {
try {
await _firebaseService.deleteDoubt(doubtId);
} catch (e) {
debugPrint('Error deleting doubt: $e');
rethrow;
}
}
// ✅ FIX: Sort replies by net score (upvotes - downvotes) descending
// and populate the cache so optimistic vote updates work
Stream<List<Reply>> getRepliesStream(String doubtId) {
return _firebaseService.getRepliesStream(doubtId).map((replies) {
// Sort: highest net score first, tie-break by newest first
replies.sort((a, b) {
final scoreA = a.upvotes - a.downvotes;
final scoreB = b.upvotes - b.downvotes;
if (scoreB != scoreA) return scoreB.compareTo(scoreA);
return b.createdAt.compareTo(a.createdAt); // tie-break: newest first
});
// Populate cache for optimistic updates on vote
_repliesCache[doubtId] = List.from(replies);
return replies;
});
}
Future<String> addReply({
required String doubtId,
required String body,
String? parentReplyId,
}) async {
try {
if (userId.isEmpty) {
throw Exception("User not authenticated");
}
final avatarColor = AppColors.getAvatarColor(userName);
return await _firebaseService.addReply(
doubtId: doubtId,
body: body,
authorId: userId,
authorName: userName,
authorAvatar:
'#${avatarColor.toARGB32().toRadixString(16).substring(2)}',
parentReplyId: parentReplyId,
);
} catch (e, stack) {
debugPrint('Error adding reply: $e');
debugPrint('Stack trace: $stack');
rethrow;
}
}
@override
void dispose() {
_doubtsSubscription?.cancel();
_repliesCache.clear();
super.dispose();
}
}