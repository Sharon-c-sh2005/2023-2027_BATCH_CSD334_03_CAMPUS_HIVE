import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pending_approval_page.dart';

class ForumRequestPage extends StatefulWidget {
  const ForumRequestPage({super.key});

  @override
  State<ForumRequestPage> createState() => _ForumRequestPageState();
}

class _ForumRequestPageState extends State<ForumRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _forumNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  static const _primary = Color(0xFF5E6AD2);
  static const _bg = Color(0xFFF0F2F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE4E6EB);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _forumNameCtrl.dispose();
    _reasonCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create Firebase Auth account
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final uid = result.user!.uid;
      await result.user!.updateDisplayName(_nameCtrl.text.trim());

      // Save user to Firestore with pending role
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': _emailCtrl.text.trim(),
        'displayName': _nameCtrl.text.trim(),
        'photoUrl': '',
        'role': 'pending',
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save forum request
      await FirebaseFirestore.instance
          .collection('forum_requests')
          .add({
        'userId': uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'forumName': _forumNameCtrl.text.trim(),
        'reason': _reasonCtrl.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Sign out — they can't use the app until approved
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PendingApprovalPage(
            name: _nameCtrl.text.trim(),
            forumName: _forumNameCtrl.text.trim(),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().contains('email-already-in-use')
            ? 'This email is already registered. Try logging in.'
            : 'Something went wrong. Try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _textPrimary,
        title: const Text(
          'Request Forum Account',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFO BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: _primary, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your request will be reviewed by the admin. '
                        'You will be notified once approved.',
                        style: TextStyle(
                            fontSize: 12, color: _textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Colors.red.shade600, fontSize: 12)),
                ),
                const SizedBox(height: 16),
              ],

              _sectionLabel('PERSONAL DETAILS'),
              const SizedBox(height: 10),
              _field(
                controller: _nameCtrl,
                hint: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _emailCtrl,
                hint: 'Email Address',
                icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? 'Enter valid email'
                    : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _phoneCtrl,
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              // Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(
                      fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Create Password',
                    hintStyle: TextStyle(
                        color: _textSecondary.withValues(alpha: 0.6),
                        fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 18, color: _textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                        color: _textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v!.length < 6
                      ? 'Minimum 6 characters'
                      : null,
                ),
              ),

              const SizedBox(height: 20),
              _sectionLabel('FORUM DETAILS'),
              const SizedBox(height: 10),
              _field(
                controller: _forumNameCtrl,
                hint: 'Forum / Club Name',
                icon: Icons.groups_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 4,
                  maxLength: 300,
                  style: const TextStyle(
                      fontSize: 13, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText:
                        'Why do you need a forum account? What events will you manage?',
                    hintStyle: TextStyle(
                        color: _textSecondary.withValues(alpha: 0.5),
                        fontSize: 12),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 64),
                      child: Icon(Icons.notes_outlined,
                          size: 18, color: _textSecondary),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterStyle: TextStyle(
                        fontSize: 10, color: _textSecondary),
                  ),
                  validator: (v) => v!.trim().length < 20
                      ? 'Please explain in at least 20 characters'
                      : null,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style:
            const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: _textSecondary.withValues(alpha: 0.6),
              fontSize: 13),
          prefixIcon:
              Icon(icon, size: 18, color: _textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }
}