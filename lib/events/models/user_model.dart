import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, forumAdmin, superAdmin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String rollNumber;
  final String department;
  final String year;
  final String? photoUrl;
  final UserRole role;
  final List<String> managedForums;
  final List<String> registeredEvents;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.year,
    this.photoUrl,
    this.role = UserRole.student,
    this.managedForums = const [],
    this.registeredEvents = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] ?? 'student'),
        orElse: () => UserRole.student,
      ),
      managedForums: List<String>.from(map['managedForums'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'department': department,
        'year': year,
        'photoUrl': photoUrl,
        'role': role.name,
        'managedForums': managedForums,
        'registeredEvents': registeredEvents,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    UserRole? role,
    List<String>? managedForums,
    List<String>? registeredEvents,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      rollNumber: rollNumber,
      department: department,
      year: year,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      managedForums: managedForums ?? this.managedForums,
      registeredEvents: registeredEvents ?? this.registeredEvents,
      createdAt: createdAt,
    );
  }
}