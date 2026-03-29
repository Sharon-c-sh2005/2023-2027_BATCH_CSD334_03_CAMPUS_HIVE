import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/forum_model.dart';

class EventService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── FORUMS ──────────────────────────────────────────

  Stream<List<ForumModel>> getForums() {
    return _db
        .collection('forums')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ForumModel.fromMap(d.data(), d.id)).toList());
  }

  Future<ForumModel?> getForum(String forumId) async {
    final doc = await _db.collection('forums').doc(forumId).get();
    if (doc.exists) return ForumModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  Future<void> createForum(ForumModel forum) async {
    await _db.collection('forums').doc(forum.id).set(forum.toMap());
  }

  // ── EVENTS ──────────────────────────────────────────

  Stream<List<EventModel>> getAllEvents({
    String? forumId,
    String? category,
  }) {
    Query query = _db.collection('events').orderBy('startDate');
    if (forumId != null) {
      query = query.where('forumId', isEqualTo: forumId);
    }
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => EventModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (doc.exists) return EventModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  Future<String> createEvent(EventModel event) async {
    final ref = await _db.collection('events').add(event.toMap());
    return ref.id;
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // ── REGISTRATIONS ───────────────────────────────────

  Future<RegistrationModel?> getRegistration(
      String eventId, String userId) async {
    final snap = await _db
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return RegistrationModel.fromMap(
          snap.docs.first.data(), snap.docs.first.id);
    }
    return null;
  }

  Future<String?> registerForEvent({
    required EventModel event,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    // Check already registered
    final existing = await getRegistration(event.id, userId);
    if (existing != null) return 'Already registered for this event';
    if (event.isFull) return 'Event is full';
    if (!event.isRegistrationOpen) return 'Registration is closed';

    // Save registration + update event count + update user list
    final batch = _db.batch();

    final regRef = _db.collection('registrations').doc();
    batch.set(regRef, {
      'eventId': event.id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': 'approved',
      'registeredAt': FieldValue.serverTimestamp(),
    });

    batch.update(
      _db.collection('events').doc(event.id),
      {'registeredCount': FieldValue.increment(1)},
    );

    batch.update(
      _db.collection('users').doc(userId),
      {'registeredEvents': FieldValue.arrayUnion([event.id])},
    );

    await batch.commit();
    return null;
  }

  Stream<List<RegistrationModel>> getEventRegistrations(String eventId) {
    return _db
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RegistrationModel.fromMap(d.data(), d.id))
            .toList());
  }
}