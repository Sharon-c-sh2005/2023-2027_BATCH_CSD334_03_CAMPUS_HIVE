import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // adjust path if needed

class PendingApprovalPage extends StatelessWidget {
  final String name;
  final String forumName;

  const PendingApprovalPage({
    super.key,
    required this.name,
    required this.forumName,
  });

  static const _primary = Color(0xFF5E6AD2);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: _primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Request Submitted!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Hi $name, your request for a forum account for '
                '"$forumName" has been submitted successfully.',
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFE4E6EB)),
                ),
                child: Column(
                  children: [
                    _statusRow(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      label: 'Request received',
                      done: true,
                    ),
                    const SizedBox(height: 14),
                    _statusRow(
                      icon: Icons.pending_outlined,
                      color: _primary,
                      label: 'Under admin review',
                      done: false,
                    ),
                    const SizedBox(height: 14),
                    _statusRow(
                      icon: Icons.lock_open_outlined,
                      color: Colors.grey,
                      label: 'Account activated',
                      done: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'You will receive an email once your account is approved. '
                'Then you can log in using your registered email and password.',
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
},
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required Color color,
    required String label,
    required bool done,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            color: done ? _textPrimary : _textSecondary,
          ),
        ),
      ],
    );
  }
}