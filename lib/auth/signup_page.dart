import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'profile_setup_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  static const _primary = Color(0xFF1A1A2E);
  static const _bg = Color(0xFFF0F2F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE4E6EB);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = "Password must be at least 6 characters");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _auth.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (result != null) {
        await _auth.saveUserToFirestore(result.user!);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(userId: result.user!.uid),
          ),
        );
      }
    } catch (e) {
       debugPrint("SIGNUP ERROR: $e");
        setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('email-already-in-use')) return "An account already exists with this email";
    if (e.contains('invalid-email')) return "Invalid email address";
    if (e.contains('weak-password')) return "Password is too weak";
    return "Something went wrong. Try again";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // HEADER
              const Text(
                "Create account ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Join and start collaborating",
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),

              const SizedBox(height: 32),

              // ERROR
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: Colors.red.shade600, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _buildField(
                controller: _emailCtrl,
                hint: "Email address",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _passCtrl,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: _obscurePass,
                suffix: IconButton(
                  icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: _textSecondary),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _confirmCtrl,
                hint: "Confirm password",
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: _textSecondary),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
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
                          "Create Account",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: _primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: _textSecondary.withOpacity(0.6), fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: _textSecondary),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}