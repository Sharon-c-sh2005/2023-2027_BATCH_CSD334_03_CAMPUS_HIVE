import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
const _suggestedTags = [
'react-native',
'typescript',
'api',
'testing',
'performance',
'architecture',
'state-management',
'design',
'database',
'security',
'devops',
'career',
'flutter',
'firebase',
'dart',
'ios',
'android',
];
class ComposeScreen extends StatefulWidget {
const ComposeScreen({super.key});
@override
State<ComposeScreen> createState() => _ComposeScreenState();
}
class _ComposeScreenState extends State<ComposeScreen> {
final _titleController = TextEditingController();
final _bodyController = TextEditingController();
final List<String> _selectedTags = [];
bool _posting = false;
@override
void dispose() {
_titleController.dispose();
_bodyController.dispose();
super.dispose();
}
void _toggleTag(String tag) {
HapticFeedback.lightImpact();
setState(() {
if (_selectedTags.contains(tag)) {
_selectedTags.remove(tag);
} else if (_selectedTags.length < 3) {
_selectedTags.add(tag);
}
});
}
Future<void> _handlePost() async {
final title = _titleController.text.trim();
final body = _bodyController.text.trim();
if (title.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Please add a title to your doubt.')),
);
return;
}
if (body.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Please describe your doubt.')),
);
return;
}
setState(() => _posting = true);
HapticFeedback.heavyImpact();
try {
await context.read<DoubtsProvider>().createDoubt(
title: title,
body: body,
tags: _selectedTags,
);
if (mounted) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Doubt posted successfully!')),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Failed to post doubt: ${e.toString()}'),
backgroundColor: AppColors.error,
),
);
}
} finally {
if (mounted) setState(() => _posting = false);
}
}
@override
Widget build(BuildContext context) {
final canPost = _titleController.text.trim().isNotEmpty &&
_bodyController.text.trim().isNotEmpty &&
!_posting;
return Scaffold(
backgroundColor: AppColors.surface,
appBar: AppBar(
backgroundColor: AppColors.surface,
surfaceTintColor: Colors.transparent,
elevation: 0,
leading: IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.close, color: AppColors.text),
),
title: Text(
'Ask a Doubt',
style: GoogleFonts.inter(
fontSize: 17,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
),
actions: [
Padding(
padding: const EdgeInsets.only(right: 16),
child: GestureDetector(
onTap: canPost ? _handlePost : null,
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
padding:
const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius: BorderRadius.circular(20),
),
child: AnimatedOpacity(
duration: const Duration(milliseconds: 200),
opacity: canPost ? 1.0 : 0.4,
child: Text(
_posting ? 'Posting...' : 'Post',
style: GoogleFonts.inter(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.white,
),
),
),
),
),
),
],
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Title input
TextField(
controller: _titleController,
maxLines: null,
maxLength: 200,
autofocus: true,
onChanged: (_) => setState(() {}),
style: GoogleFonts.inter(
fontSize: 22,
fontWeight: FontWeight.w700,
color: AppColors.text,
height: 1.3,
),
decoration: InputDecoration(
hintText: "What's your doubt?",
hintStyle: GoogleFonts.inter(
fontSize: 22,
fontWeight: FontWeight.w700,
color: AppColors.textTertiary,
),
border: InputBorder.none,
counterText: '',
),
),
const SizedBox(height: 16),
// Body input
TextField(
controller: _bodyController,
maxLines: null,
minLines: 6,
maxLength: 2000,
onChanged: (_) => setState(() {}),
style: GoogleFonts.inter(
fontSize: 15,
color: AppColors.text,
height: 1.5,
),
decoration: InputDecoration(
hintText:
'Describe your doubt in detail. Add context, code snippets, or examples to help others understand...',
hintStyle: GoogleFonts.inter(
fontSize: 15,
color: AppColors.textTertiary,
height: 1.5,
),
border: InputBorder.none,
counterText: '',
),
),
// Character count
Align(
alignment: Alignment.centerRight,
child: Padding(
padding: const EdgeInsets.only(top: 8, bottom: 24),
child: Text(
'${_bodyController.text.length}/2000',
style: GoogleFonts.inter(
fontSize: 12,
color: AppColors.textTertiary,
),
),
),
),
// Tags
Text(
'Add Tags (up to 3)',
style: GoogleFonts.inter(
fontSize: 15,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
),
const SizedBox(height: 10),
Wrap(
spacing: 8,
runSpacing: 8,
children: _suggestedTags.map((tag) {
final isSelected = _selectedTags.contains(tag);
return GestureDetector(
onTap: () => _toggleTag(tag),
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 8,
),
decoration: BoxDecoration(
color: isSelected ? AppColors.primary : AppColors.chipBg,
borderRadius: BorderRadius.circular(20),
),
child: Text(
tag,
style: GoogleFonts.inter(
fontSize: 13,
fontWeight: FontWeight.w500,
color:
isSelected ? Colors.white : AppColors.textSecondary,
),
),
),
);
}).toList(),
),
],
),
),
);
}
}