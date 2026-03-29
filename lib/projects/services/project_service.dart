import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectService {
  final _db = FirebaseFirestore.instance;

  // CREATE
  Future<void> createProject(Project project) async {
    await _db.collection('projects').add(project.toMap());
  }

  // READ (STREAM)
  Stream<QuerySnapshot> getProjectsStream() {
    return _db
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // JOIN
  Future<void> joinProject({
    required String projectId,
    required String userId,
  }) async {
    await _db.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayUnion([userId])
    });
    final name = await _getUserName(userId);
     await _addActivity(
  projectId: projectId,
  message: "$name joined the project",
);
  }

  // LEAVE
  Future<void> leaveProject({
    required String projectId,
    required String userId,
  }) async {
    await _db.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayRemove([userId])
    });
    final name = await _getUserName(userId);
    await _addActivity(
  projectId: projectId,
  message: "$name left the project",
);
  }

  // DELETE
  Future<void> deleteProject({
    required String projectId,
  }) async {
    await _db.collection('projects').doc(projectId).delete();
  }





// OWNER LEAVE (TRANSFER + REMOVE)
Future<void> ownerLeaveAndTransfer({
  required String projectId,
  required String currentOwnerId,
  required String newOwnerId,
}) async {
  final doc = _db.collection('projects').doc(projectId);

  await doc.update({
    'ownerId': newOwnerId,
    'members': FieldValue.arrayRemove([currentOwnerId]),
  });
  final ownerName = await _getUserName(currentOwnerId);
final newOwnerName = await _getUserName(newOwnerId);
  await _addActivity(
  projectId: projectId,
  message:
      "$ownerName transferred ownership to $newOwnerName and left the project",
);
}


Future<void> acceptJoinRequest({
  required String projectId,
  required String userId,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId);

  await ref.update({
    'pendingRequests': FieldValue.arrayRemove([userId]),
    'members': FieldValue.arrayUnion([userId]),
  });
  final name = await _getUserName(userId);
  await _addActivity(
  projectId: projectId,
  message: "$name joined the project",
);
}

Future<void> declineJoinRequest({
  required String projectId,
  required String userId,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId);

  await ref.update({
    'pendingRequests': FieldValue.arrayRemove([userId]),
  });
  final name = await _getUserName(userId);
  await _addActivity(
  projectId: projectId,
  message: "$name's request was declined",
);
}

Future<void> requestToJoinProject({
  required String projectId,
  required String userId,
}) async {
  await FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId)
      .update({
    'pendingRequests': FieldValue.arrayUnion([userId]),
  });
  final name = await _getUserName(userId);
  await _addActivity(
    projectId: projectId,
    message: "$name requested to join the project",
  );
}

// FETCH DISPLAY NAME
Future<String> _getUserName(String userId) async {
  try {
    final doc = await _db.collection('users').doc(userId).get();
    final raw = doc.data()?['displayName'] ?? '';
    if (raw.isEmpty) return userId;
    return raw.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  } catch (_) {
    return userId;
  }
}




Future<void> _addActivity({
  required String projectId,
  required String message,
}) async {
  await FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId)
      .update({
    'activities': FieldValue.arrayUnion([
      {
        'message': message,
        'timestamp': Timestamp.now(),
      }
    ]),
  });
}

Stream<Project> streamProject(String projectId) {
  return FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId)
      .snapshots()
      .map((doc) => Project.fromFirestore(doc));
}

Future<void> updateProjectStatus({
  required String projectId,
  required String status,
}) async {
  await _db.collection('projects').doc(projectId).update({
    'status': status,
  });

  await _addActivity(
    projectId: projectId,
    message: "Project status changed to $status",
  );
}

}