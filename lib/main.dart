import 'package:flutter/material.dart';
import 'projects/screens/project_zone_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/login_page.dart';
import 'auth/profile_setup_page.dart';
//chnages 
import 'package:provider/provider.dart';
import 'doubt_hub/providers/doubts_provider.dart';

//
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/pending_approval_page.dart';
import 'events/screens/forum_admin_shell.dart';
import 'events/screens/super_admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SIGN OUT any leftover anonymous session
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.isAnonymous) {
    await FirebaseAuth.instance.signOut();
  }


  //runApp(const MyApp());
 runApp(
  ChangeNotifierProvider(
    create: (_) => DoubtsProvider()..init(),
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Mentorship',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF6F7FB),//const Color(0xFFF8F9FC),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1A1A2E),
          surface: Colors.white,
          background: const Color(0xFFF8F9FC),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F0E17),
          elevation: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
          labelStyle:
              const TextStyle(fontSize: 11, color:  Color(0xFF1A1A2E)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
      ),

      // CHANGED: replaced FutureBuilder+signInAnonymously
      // with StreamBuilder on authStateChanges
   
   home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F2F5),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF5E6AD2))),
      );
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return const LoginPage();
    }

    final user = snapshot.data!;

    // Check role from Firestore
    return FutureBuilder<DocumentSnapshot>(
      key: ValueKey(user.uid),
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F2F5),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF5E6AD2))),
          );
        }

        final data = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final role = data['role'] ?? 'student';
        final profileComplete = data['profileComplete'] ?? false;

        // Pending or rejected forum request
        if (role == 'pending' || role == 'rejected') {
          return PendingApprovalPage(
            name: data['displayName'] ?? '',
            forumName: data['forumName'] ?? '',
          );
        }

        // Forum admin → events shell
        if (role == 'forumAdmin') {
          return const ForumAdminShell();
        }

        // Super admin → super admin shell
        if (role == 'superAdmin') {
          return const SuperAdminShell();
        }

        // Normal student — check profile setup
        if (!profileComplete) {
          return ProfileSetupPage(userId: user.uid);
        }

        // Normal student with complete profile
        return ProjectZonePage(currentUserId: user.uid, initialIndex: 1);
      },
    );
  },
),
   

    );
  }
}