
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_page.dart';
import 'profile_setup_page.dart';
import 'forum_request_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  static const _primary = Color(0xFF5E6AD2);
  static const _bg = Color(0xFFF0F2F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE4E6EB);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _auth.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (result != null) {
        await _auth.saveUserToFirestore(result.user!);
        final isComplete = await _auth.isProfileComplete(result.user!.uid);
        if (!mounted) return;
        if (!isComplete) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => ProfileSetupPage(userId: result.user!.uid),
          ));
        }
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _auth.signInWithGoogle();
      if (result != null) {
        await _auth.saveUserToFirestore(result.user!);
        final isComplete = await _auth.isProfileComplete(result.user!.uid);
        if (!mounted) return;
        if (!isComplete) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => ProfileSetupPage(userId: result.user!.uid),
          ));
        }
      }
    } catch (e) {
      debugPrint("GOOGLE LOGIN ERROR: $e");
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = "Enter your email first to reset password");
      return;
    }
    try {
      await _auth.sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Password reset email sent"),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    }
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return "No account found with this email";
    if (error.contains('wrong-password')) return "Incorrect password";
    if (error.contains('invalid-email')) return "Invalid email address";
    if (error.contains('network-request-failed')) return "Check your internet connection";
    if (error.contains('too-many-requests')) return "Too many attempts. Try again later";
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
              const SizedBox(height: 40),

              // ── LOGO ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Campus Hive",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your college. Your community.",
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),


              const SizedBox(height: 24),

              // ── ERROR ──
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
                      Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── EMAIL ──
              _buildField(
                controller: _emailCtrl,
                hint: "Email address",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // ── PASSWORD ──
              _buildField(
                controller: _passCtrl,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              // ── FORGOT PASSWORD ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text("Forgot password?",
                      style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 8),

              // ── SIGN IN BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Sign In",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // ── FORUM REQUEST BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ForumRequestPage())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, color: _primary, size: 18),
                      SizedBox(width: 8),
                      Text("Request Forum Account",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: _primary)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── DIVIDER ──
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("or continue with",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 16),

              // ── GOOGLE BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4285F4),
                        ),
                        child: const Center(
                          child: Text("G",
                              style: TextStyle(color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Continue with Google",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: _textPrimary)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── SIGN UP LINK ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignupPage())),
                    child: const Text("Sign Up",
                        style: TextStyle(color: _primary, fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              const SizedBox(height: 32),
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
          hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.6), fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: _textSecondary),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_page.dart';
import 'profile_setup_page.dart';
import 'forum_request_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  static const _primary = Color(0xFF5E6AD2);
  static const _bg = Color(0xFFF0F2F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE4E6EB);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _auth.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (result != null) {
        await _auth.saveUserToFirestore(result.user!);
        final isComplete =
            await _auth.isProfileComplete(result.user!.uid);

        if (!mounted) return;
        if (!isComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProfileSetupPage(userId: result.user!.uid),
            ),
          );
        }
        // if complete, main.dart stream handles navigation
      }
    } catch (e) {
       debugPrint("LOGIN ERROR: $e");  // shows real error in console
  setState(() => _error = e.toString()); // shows real error on screen temporarily
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _auth.signInWithGoogle();
      if (result != null) {
        await _auth.saveUserToFirestore(result.user!);
        final isComplete =
            await _auth.isProfileComplete(result.user!.uid);

        if (!mounted) return;
        if (!isComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProfileSetupPage(userId: result.user!.uid),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("GOOGLE LOGIN ERROR: $e");
  setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = "Enter your email first to reset password");
      return;
    }

    try {
      await _auth.sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password reset email sent"),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    }
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return "No account found with this email";
    if (error.contains('wrong-password')) return "Incorrect password";
    if (error.contains('invalid-email')) return "Invalid email address";
    if (error.contains('network-request-failed')) return "Check your internet connection";
    if (error.contains('too-many-requests')) return "Too many attempts. Try again later";
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
              const SizedBox(height: 40),
            Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Campus Hive",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your college. Your community.",
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              // HEADER


              /*const Text(
                "Welcome back 👋",
      
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),*/
              const SizedBox(height: 6),
              const Text(
                "Sign in to continue building",
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),

              const SizedBox(height: 40),


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
                        child: Text(
                          _error!,
                          style: TextStyle(
                              color: Colors.red.shade600, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // EMAIL FIELD
              _buildField(
                controller: _emailCtrl,
                hint: "Email address",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // PASSWORD FIELD
              _buildField(
                controller: _passCtrl,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: _textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
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
                          "Sign In",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // DIVIDER
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "or continue with",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 20),

              // GOOGLE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
               SizedBox(height: 16),

              // FORUM ACCOUNT REQUEST
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForumRequestPage()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined,
                          color: _primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Request Forum Account",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google G icon using text as placeholder
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4285F4),
                        ),
                        child: const Center(
                          child: Text(
                            "G",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // SIGN UP LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignupPage()),
                    ),
                    child: const Text(
                      "Sign Up",
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
          hintStyle:
              TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: _textSecondary),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}*/