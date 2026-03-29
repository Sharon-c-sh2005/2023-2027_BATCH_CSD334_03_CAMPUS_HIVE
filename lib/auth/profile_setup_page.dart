import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../projects/screens/project_zone_page.dart'; // adjust path based on your structure

class ProfileSetupPage extends StatefulWidget {
  final String userId;

  const ProfileSetupPage({super.key, required this.userId});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  final _collegeIdCtrl = TextEditingController();
  final _auth = AuthService();

  String? _selectedDob;
  bool _isLoading = false;
  String? _error;

  static const _primary = Color(0xFF5E6AD2);
  static const _bg = Color(0xFFF0F2F5);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE4E6EB);

  final List<String> allInterests = [
    'Flutter', 'React', 'Python', 'ML/AI', 'Firebase',
    'Node.js', 'UI/UX', 'Web', 'iOS', 'Android',
    'Data Science', 'Blockchain', 'DevOps', 'Cybersecurity',
  ];

  final List<String> selectedInterests = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _collegeCtrl.dispose();
    _branchCtrl.dispose();
     _rollNoCtrl.dispose();
    _collegeIdCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameCtrl.text.trim().isNotEmpty &&
        _collegeCtrl.text.trim().isNotEmpty &&
        _branchCtrl.text.trim().isNotEmpty &&
         _rollNoCtrl.text.trim().isNotEmpty &&
        selectedInterests.isNotEmpty &&
        _selectedDob != null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isFormValid) {
      setState(() => _error = "Please fill all required fields");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _auth.saveProfile(
        uid: widget.userId,
        name: _nameCtrl.text.trim(),
        college: _collegeCtrl.text.trim(),
        branch: _branchCtrl.text.trim(),
        rollNumber: _rollNoCtrl.text.trim(),
        collegeId: _collegeIdCtrl.text.trim(),
        dob: _selectedDob!,
        interests: selectedInterests,
        bio: _bioCtrl.text.trim(),
      );
      // auth stream in main.dart handles navigation automatically
       if (!mounted) return;

  // NAVIGATE manually since FutureBuilder won't re-check
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => ProjectZonePage(
        currentUserId: widget.userId,
      ),
    ),
    (route) => false, // removes all previous routes
  );

    } catch (e) {
      setState(() => _error = "Failed to save profile. Try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // GRADIENT HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C71F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Set up your profile ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Tell your teammates about yourself",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // FORM
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                  const SizedBox(height: 12),
                ],

                // CARD 1 — BASIC INFO
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("BASIC INFO"),
                      const SizedBox(height: 12),
                      _field(
                          controller: _nameCtrl,
                          hint: "Full name",
                          icon: Icons.person_outline),
                      const SizedBox(height: 10),
                      _field(
                          controller: _collegeCtrl,
                          hint: "College / University",
                          icon: Icons.school_outlined),
                      const SizedBox(height: 10),
                      _field(
                          controller: _branchCtrl,
                          hint: "Branch / Department",
                          icon: Icons.category_outlined),
                      const SizedBox(height: 10),
                       _field(
                          controller: _rollNoCtrl,
                          hint: "Roll Number *",
                          icon: Icons.badge_outlined),
                      const SizedBox(height: 10),
                      _field(
                          controller: _collegeIdCtrl,
                          hint: "College ID (optional)",
                          icon: Icons.credit_card_outlined),
                      const SizedBox(height: 10),

                      // DOB PICKER
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cake_outlined,
                                  size: 18, color: _textSecondary),
                              const SizedBox(width: 10),
                              Text(
                                _selectedDob ?? "Date of birth",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedDob != null
                                      ? _textPrimary
                                      : _textSecondary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // CARD 2 — INTERESTS
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("FIELDS OF INTEREST"),
                      const SizedBox(height: 4),
                      Text(
                        "Select areas you want to work on",
                        style: TextStyle(
                            fontSize: 11,
                            color: _textSecondary.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allInterests.map((interest) {
                          final isSelected =
                              selectedInterests.contains(interest);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedInterests.remove(interest);
                                } else {
                                  selectedInterests.add(interest);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _primary.withOpacity(0.1)
                                    : _bg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _primary : _border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? _primary
                                      : _textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // CARD 3 — BIO
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("BIO"),
                      const SizedBox(height: 4),
                      Text(
                        "Tell others about yourself (optional)",
                        style: TextStyle(
                            fontSize: 11,
                            color: _textSecondary.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _bioCtrl,
                        maxLines: 3,
                        maxLength: 200,
                        style: const TextStyle(
                            fontSize: 13, color: _textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              "e.g. I love building apps and solving real-world problems...",
                          hintStyle: TextStyle(
                              color: _textSecondary.withOpacity(0.5),
                              fontSize: 12),
                          filled: true,
                          fillColor: _bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: _primary, width: 1.5),
                          ),
                          counterStyle: TextStyle(
                              fontSize: 10, color: _textSecondary),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CREATE PROFILE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? _primary : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: _isFormValid ? 2 : 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Create Profile",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String text) {
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
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: _textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: _textSecondary.withOpacity(0.6), fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: _textSecondary),
        filled: true,
        fillColor: _bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}