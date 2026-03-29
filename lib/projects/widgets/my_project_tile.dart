import 'package:flutter/material.dart';
import '../models/project_model.dart';
//import '../project_detail_page.dart';
import '../../../chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../chat/chat_page.dart';


class MyProjectTile extends StatelessWidget {
  final Project project;
  final bool hasNotification;

  MyProjectTile({
    super.key,
    required this.project,
    this.hasNotification = false,
  });

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>ChatPage(
             // projectId: project.id!,
             project: project,
              currentUserId: userId,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            // CIRCULAR IMAGE + RING + UNREAD BADGE
            StreamBuilder<int>(
              stream: ChatService().streamUnreadCount(
                projectId: project.id!,
                userId: userId,
              ),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return Stack(
                  children: [
                    // RING
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: project.status == 'active'
                              ? const Color(0xFF1A1A2E)
                              : project.status == 'on hold'
                                  ? const Color(0xFFF59E0B)
                                  : Colors.grey.shade400,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage(
                          project.coverImage.isNotEmpty
                              ? project.coverImage
                              : 'assets/covers/cover1.png',
                        ),
                        onBackgroundImageError: (_, __) {},
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),

                    // NEW BADGE
                    if (hasNotification)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // UNREAD MESSAGE COUNT BADGE
                    if (unreadCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A2E),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),

            // PROJECT NAME
            Text(
              project.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}