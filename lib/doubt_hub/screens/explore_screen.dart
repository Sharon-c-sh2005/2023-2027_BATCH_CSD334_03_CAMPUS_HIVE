
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
import 'doubt_detail_screen.dart';
const _tagColors = [
Color(0xFFE8553A), Color(0xFF1A8D7C), Color(0xFF6366F1),
Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFFEC4899),
Color(0xFF8B5CF6), Color(0xFF06B6D4), Color(0xFFEF4444),
Color(0xFF14B8A6),
];
class ExploreScreen extends StatelessWidget {
const ExploreScreen({super.key});
@override
Widget build(BuildContext context) {
final provider = context.watch<DoubtsProvider>();
final activeDoubts =
provider.doubts.where((d) => !d.isDeleted).toList();
// Build tag stats
final tagCounts = <String, int>{};
for (final d in activeDoubts) {
for (final t in d.tags) {
tagCounts[t] = (tagCounts[t] ?? 0) + 1;
}
}
final sortedTags = tagCounts.entries.toList()
..sort((a, b) => b.value.compareTo(a.value));
// Top doubts by score
final topDoubts = [...activeDoubts]
..sort((a, b) => b.score.compareTo(a.score));
final top5 = topDoubts.take(5).toList();
return Scaffold(
backgroundColor: AppColors.background,
body: CustomScrollView(
slivers: [
SliverAppBar(
floating: true,
backgroundColor: AppColors.surface,
surfaceTintColor: Colors.transparent,
title: Text(
'Explore',
style: GoogleFonts.inter(
fontSize: 24,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
),
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Trending topics
Text(
'Trending Topics',
style: GoogleFonts.inter(
fontSize: 20,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(height: 14),
if (sortedTags.isEmpty)
_EmptySection(
icon: Icons.local_offer_outlined,
text: 'No topics yet',
)
else
...sortedTags.asMap().entries.map((entry) {
final i = entry.key;
final tag = entry.value;
return Container(
margin: const EdgeInsets.only(bottom: 8),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(12),
border: Border(
left: BorderSide(
color: _tagColors[i % _tagColors.length],
width: 4,
),
),
),
padding: const EdgeInsets.all(14),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
'#${tag.key}',
style: GoogleFonts.inter(
fontSize: 15,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
),
Text(
'${tag.value} ${tag.value == 1 ? "doubt" : 
"doubts"}',
style: GoogleFonts.inter(
fontSize: 13,
color: AppColors.textSecondary,
),
),
],
),
);
}),
// Top questions
const SizedBox(height: 28),
Text(
'Top Questions',
style: GoogleFonts.inter(
fontSize: 20,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
const SizedBox(height: 14),
if (top5.isEmpty)
_EmptySection(
icon: Icons.emoji_events_outlined,
text: 'No questions yet',
)
else
...top5.asMap().entries.map((entry) {
final i = entry.key;
final doubt = entry.value;
return GestureDetector(
onTap: () {
HapticFeedback.lightImpact();
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
DoubtDetailScreen(doubtId: doubt.id),
),
);
},
child: Container(
margin: const EdgeInsets.only(bottom: 8),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
Container(
width: 28,
height: 28,
decoration: BoxDecoration(
color: AppColors.primaryLight,
shape: BoxShape.circle,
),
alignment: Alignment.center,
child: Text(
'${i + 1}',
style: GoogleFonts.inter(
fontSize: 13,
fontWeight: FontWeight.w700,
color: AppColors.primary,
),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
doubt.title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: GoogleFonts.inter(
fontSize: 14,
fontWeight: FontWeight.w500,
color: AppColors.text,
height: 1.3,
),
),
const SizedBox(height: 4),
Row(
children: [
Icon(
Icons.keyboard_arrow_up,
size: 13,
color: AppColors.upvote,
),
Text(
'${doubt.score}',
style: GoogleFonts.inter(
fontSize: 12,
fontWeight: FontWeight.w500,
color: AppColors.textSecondary,
),
),
const SizedBox(width: 12),
Icon(
Icons.chat_bubble_outline,
size: 12,
color: AppColors.textTertiary,
),
const SizedBox(width: 3),
Text(
'${doubt.replyCount}',
style: GoogleFonts.inter(
fontSize: 12,
fontWeight: FontWeight.w500,
color: AppColors.textSecondary,
),
),
],
),
],
),
),
const Icon(
Icons.chevron_right,
size: 16,
color: AppColors.textTertiary,
),
],
),
),
);
}),
const SizedBox(height: 80),
],
),
),
),
],
),
);
}
}
class _EmptySection extends StatelessWidget {
final IconData icon;
final String text;
const _EmptySection({required this.icon, required this.text});
@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 32),
child: Column(
children: [
Icon(icon, size: 32, color: AppColors.textTertiary),
const SizedBox(height: 8),
Text(
text,
style: GoogleFonts.inter(
fontSize: 14,
color: AppColors.textTertiary,
),
),
],
),
),
);
}
}