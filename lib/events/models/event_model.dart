import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { upcoming, ongoing, completed, cancelled }
enum EventMode { offline, online, hybrid }

class EventModel {
  final String id;
  final String title;
  final String description;
  final String forumId;
  final String forumName;
  final String venue;
  final EventMode mode;
  final String? meetLink;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final int registeredCount;
  final List<String> tags;
  final String category;
  final double registrationFee;
  final EventStatus status;
  final String createdBy;
  final List<Map<String, dynamic>> customFields;
  final bool requiresApproval;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.forumId,
    required this.forumName,
    required this.venue,
    this.mode = EventMode.offline,
    this.meetLink,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.registeredCount = 0,
    this.tags = const [],
    required this.category,
    this.registrationFee = 0,
    this.status = EventStatus.upcoming,
    required this.createdBy,
    this.customFields = const [],
    this.requiresApproval = false,
    required this.createdAt,
  });

  bool get isFull => registeredCount >= maxParticipants;
  bool get isRegistrationOpen =>
      status == EventStatus.upcoming &&
      DateTime.now().isBefore(registrationDeadline) &&
      !isFull;
  int get availableSpots => maxParticipants - registeredCount;

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      forumId: map['forumId'] ?? '',
      forumName: map['forumName'] ?? '',
      venue: map['venue'] ?? '',
      mode: EventMode.values.firstWhere(
        (m) => m.name == (map['mode'] ?? 'offline'),
        orElse: () => EventMode.offline,
      ),
      meetLink: map['meetLink'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      registrationDeadline:
          (map['registrationDeadline'] as Timestamp).toDate(),
      maxParticipants: map['maxParticipants'] ?? 100,
      registeredCount: map['registeredCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? 'General',
      registrationFee: (map['registrationFee'] ?? 0).toDouble(),
      status: EventStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'upcoming'),
        orElse: () => EventStatus.upcoming,
      ),
      createdBy: map['createdBy'] ?? '',
      customFields:
          List<Map<String, dynamic>>.from(map['customFields'] ?? []),
      requiresApproval: map['requiresApproval'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'forumId': forumId,
        'forumName': forumName,
        'venue': venue,
        'mode': mode.name,
        'meetLink': meetLink,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'maxParticipants': maxParticipants,
        'registeredCount': registeredCount,
        'tags': tags,
        'category': category,
        'registrationFee': registrationFee,
        'status': status.name,
        'createdBy': createdBy,
        'customFields': customFields,
        'requiresApproval': requiresApproval,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// Simple registration model — only what we actually store
class RegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;
  final DateTime registeredAt;

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.status = 'approved',
    required this.registeredAt,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String id) {
    return RegistrationModel(
      id: id,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'approved',
      registeredAt: (map['registeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'status': status,
        'registeredAt': Timestamp.fromDate(registeredAt),
      };
}