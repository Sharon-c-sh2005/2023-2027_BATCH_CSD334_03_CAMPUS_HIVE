import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStream => _auth.authStateChanges();
//anija
  String get userId => currentUser?.uid ?? 'anonymous';

String get displayName =>
    currentUser?.displayName ??
    currentUser?.email?.split('@').first ??
    'Anonymous';

Future<UserCredential> signInAnonymously() async {
  return await _auth.signInAnonymously();
}
//anija
  // GOOGLE SIGN IN
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  // EMAIL SIGN UP
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // EMAIL SIGN IN
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // FORGOT PASSWORD
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // SAVE USER TO FIRESTORE
  Future<void> saveUserToFirestore(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'isAnonymous': user.isAnonymous,
        'role': 'student',
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
// REPLACE WITH:
Future<bool> isProfileComplete(String uid) async {
  try {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    return doc.data()?['profileComplete'] ?? false;
  } catch (e) {
    return false;
  }
}

  // SAVE PROFILE DETAILS
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String college,
    required String branch,
    required String rollNumber,
    required String collegeId,
    required String dob,
    required List<String> interests,
    required String bio,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': name,
      'college': college,
      'branch': branch,
      'rollNumber': rollNumber,
      'collegeId': collegeId,
      'dob': dob,
      'interests': interests,
      'bio': bio,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayName(String name) async {
  await _auth.currentUser?.updateDisplayName(name);
}

  // SIGN OUT
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
//
  Future<String> getUserRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return 'student';
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'student';
  }
}