import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*String getCoverImage(List<String> techStack) {
  if (techStack.contains('Flutter')) return 'assets/stacks/flutter.png';
  if (techStack.contains('React')) return 'assets/stacks/react.png';
  if (techStack.contains('AI')) return 'assets/stacks/ai.png';
  if (techStack.contains('Web')) return 'assets/stacks/web.png';
  return 'assets/stacks/default.png';
}*/

const List<String> coverImages = [
  'assets/covers/cover1.jpg',
  'assets/covers/cover2.jpg',
  'assets/covers/cover3.jpg',
  'assets/covers/cover4.png',
  'assets/covers/cover5.jpeg',
  'assets/covers/cover6.avif',
  'assets/covers/cover7.png',
  'assets/covers/cover8.jpeg',
  'assets/covers/cover9.png',
];

const _primary = Color(0xFF1A1A2E);
const _bg = Color(0xFFF0F2F5);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF111827);
const _textSecondary = Color(0xFF6B7280);
const _border = Color(0xFFE4E6EB);

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final titleCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final membersCtrl = TextEditingController();
  String selectedCover = 'assets/covers/cover1.jpg'; // default
  // ADD with your other controllers:
final customTechCtrl = TextEditingController();

  // TECH STACK — selected from chips
  final List<String> allTechOptions = [
    'Flutter', 'React', 'Python', 'ML/AI',
    'Firebase', 'Node.js', 'UI/UX', 'Web', 'AI',
    'Swift', 'Kotlin', 'Vue', 'Django',
  ];
  final List<String> selectedTech = [];

  bool requiresApproval = true;
  bool isLoading = false;

  // VALIDATION ERRORS
  String? titleError;
  String? bioError;
  String? techError;
  String? membersError;

  @override
  void dispose() {
    titleCtrl.dispose();
    bioCtrl.dispose();
    membersCtrl.dispose();
    super.dispose();
    // ADD in dispose():
customTechCtrl.dispose();
  }

  bool get isFormValid {
    final bioWords = bioCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final members = int.tryParse(membersCtrl.text.trim()) ?? 0;
    return titleCtrl.text.trim().isNotEmpty &&
        bioWords >= 10 &&
        selectedTech.isNotEmpty &&
        members >= 2;
  }

  void validate() {
    final bioWords = bioCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final members = int.tryParse(membersCtrl.text.trim()) ?? 0;

    setState(() {
      titleError = titleCtrl.text.trim().isEmpty ? "Project name is required" : null;
      bioError = bioWords < 10 ? "Bio must be at least 10 words (${bioWords}/10)" : null;
      techError = selectedTech.isEmpty ? "Select at least one technology" : null;
      membersError = members < 2 ? "Must allow at least 2 members" : null;
    });
  }

  Future<void> submit() async {
    validate();
    if (!isFormValid) return;

    setState(() => isLoading = true);

    //final coverImage = getCoverImage(selectedTech);
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      user = cred.user;
    }

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('projects').add({
        'title': titleCtrl.text.trim(),
        'description': bioCtrl.text.trim(),
        'ownerId': user.uid,
        'techStack': selectedTech,
        'coverImage': selectedCover,
        'status': 'active',
        'maxMembers': int.parse(membersCtrl.text.trim()),
        'isOpenJoin': !requiresApproval,
        'members': [user.uid],
        'pendingRequests': [],
        'activities': [],
        'categories': selectedTech,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // REUSABLE CARD WRAPPER
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
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

  // REUSABLE LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // REUSABLE TEXT FIELD
  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? error,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (_) {
            if (onChanged != null) onChanged();
            setState(() {});
          },
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 13),
            filled: true,
            fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null ? Colors.red : _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null ? Colors.red : _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: error != null ? Colors.red : _primary, width: 1.5),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error,
              style: const TextStyle(fontSize: 11, color: Colors.red)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bioWords = bioCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // HEADER
          Container(
            height: MediaQuery.of(context).size.height * 0.26,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ Color(0xFF1A1A2E), Color(0xFF7C71F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // BACK BUTTON
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.rocket_launch_outlined,
                            size: 48, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "New Project",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Build something great with others",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FORM
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 4),

                // CARD 1 — PROJECT INFO
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("PROJECT NAME"),
                      _field(
                        controller: titleCtrl,
                        hint: "e.g. DevConnect App",
                        error: titleError,
                      ),
                      const SizedBox(height: 16),
                      _label("PROJECT BIO"),
                      _field(
                        controller: bioCtrl,
                        hint: "Describe your project in at least 10 words...",
                        maxLines: 3,
                        error: bioError,
                      ),
                      const SizedBox(height: 4),
                      // WORD COUNT
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$bioWords / 10 words minimum",
                          style: TextStyle(
                            fontSize: 11,
                            color: bioWords >= 10
                                ? const Color(0xFF22C55E)
                                : _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // CARD 2 — TECH STACK + STATUS
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("TECH STACK"),
                      if (techError != null) ...[
                        Text(techError!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.red)),
                        const SizedBox(height: 6),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allTechOptions.map((tech) {
                          final isSelected = selectedTech.contains(tech);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedTech.remove(tech);
                                } else {
                                  selectedTech.add(tech);
                                }
                                techError = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
                                tech,
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
                        const SizedBox(height: 12),


                            Row(
  children: [
    Expanded(
      child: TextField(
        controller: customTechCtrl,
        style: const TextStyle(fontSize: 13, color: _textPrimary),
        decoration: InputDecoration(
          hintText: "Add custom tech...",
          hintStyle: TextStyle(
              fontSize: 12, color: _textSecondary.withOpacity(0.6)),
          filled: true,
          fillColor: _bg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        final custom = customTechCtrl.text.trim();
        if (custom.isNotEmpty && !selectedTech.contains(custom)) {
          setState(() {
            selectedTech.add(custom);
            customTechCtrl.clear();
            techError = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    ),
  ],
),

// SHOW SELECTED CUSTOM TECHS (ones not in the default list)
if (selectedTech.any((t) => !allTechOptions.contains(t))) ...[
  const SizedBox(height: 10),
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: selectedTech
        .where((t) => !allTechOptions.contains(t))
        .map((t) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => selectedTech.remove(t)),
                    child: const Icon(Icons.close,
                        size: 13, color: Color(0xFF22C55E)),
                  ),
                ],
              ),
            ))
        .toList(),
  ),
],


                      const SizedBox(height: 16),
                      const Divider(color: _border),
                      const SizedBox(height: 12),

                      _label("MAX MEMBERS"),
                      _field(
                        controller: membersCtrl,
                        hint: "Minimum 2",
                        keyboardType: TextInputType.number,
                        error: membersError,
                      ),

                      const SizedBox(height: 16),

                    // ADD THIS BLOCK HERE — before the Divider:
const Divider(color: _border),
const SizedBox(height: 12),
_label("PROJECT COVER"),
const SizedBox(height: 10),
SizedBox(
  height: 90,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: coverImages.length,
    separatorBuilder: (_, __) => const SizedBox(width: 10),
    itemBuilder: (context, i) {
      final img = coverImages[i];
      final isSelected = selectedCover == img;
      return GestureDetector(
        onTap: () => setState(() => selectedCover = img),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primary : _border,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(img, fit: BoxFit.cover),
                if (isSelected)
                  Container(
                    color: _primary.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.check_circle,
                          color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  ),
),

const SizedBox(height: 12),

// THEN THE EXISTING DIVIDER AND APPROVAL TOGGLE CONTINUES:


// APPROVAL TOGGLE


                      const Divider(color: _border),

                      // APPROVAL TOGGLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Require Approval",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Members need your approval to join",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _textSecondary.withOpacity(0.8)),
                              ),
                            ],
                          ),
                          Switch(
                            value: requiresApproval,
                            onChanged: (v) =>
                                setState(() => requiresApproval = v),
                            activeColor: _primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CREATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFormValid ? _primary : _border,
                      foregroundColor: Colors.white,
                      elevation: isFormValid ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            isFormValid
                                ? "Create Project"
                                : "Fill all fields to continue",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
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
}