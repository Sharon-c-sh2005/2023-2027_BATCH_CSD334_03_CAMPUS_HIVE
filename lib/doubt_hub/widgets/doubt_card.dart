import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/doubt.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import 'avatar_widget.dart';
import 'vote_buttons.dart';
class DoubtCard extends StatelessWidget {
final Doubt doubt;
final VoidCallback onTap;
const DoubtCard({
super.key,
required this.doubt,
required this.onTap,
});
@override
Widget build(BuildContext context) {
final provider = context.watch<DoubtsProvider>();
final currentVote = provider.getVote(doubt.id);
return GestureDetector(
onTap: () {
HapticFeedback.lightImpact();
onTap();
},
child: Container(
margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: AppColors.text.withValues(alpha: 0.04),
blurRadius: 8,
offset: const Offset(0, 1),
),
],
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header
Row(
children: [
AvatarWidget.fromHex(
name: doubt.authorName,
hexColor: doubt.authorAvatar,
size: 36,
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
doubt.authorName,
style: GoogleFonts.inter(
fontSize: 14,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
),
const SizedBox(height: 1),
Text(
formatTimeAgo(doubt.createdAt),
style: GoogleFonts.inter(
fontSize: 12,
color: AppColors.textTertiary,
),
),
],
),
),
if (doubt.replyCount == 0)
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration: BoxDecoration(
color: AppColors.warningLight,
borderRadius: BorderRadius.circular(12),
),
child: Text(
'Unsolved',
style: GoogleFonts.inter(
fontSize: 11,
fontWeight: FontWeight.w600,
color: AppColors.warning,
),
),
),
],
),
const SizedBox(height: 10),
// Title
Text(
doubt.title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: GoogleFonts.inter(
fontSize: 16,
fontWeight: FontWeight.w600,
color: AppColors.text,
height: 1.4,
),
),
const SizedBox(height: 6),
// Body
Text(
doubt.body,
maxLines: 3,
overflow: TextOverflow.ellipsis,
style: GoogleFonts.inter(
fontSize: 14,
color: AppColors.textSecondary,
height: 1.4,
),
),
// Tags
if (doubt.tags.isNotEmpty) ...[
const SizedBox(height: 10),
Wrap(
spacing: 6,
runSpacing: 6,
children: doubt.tags.take(3).map((tag) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius: BorderRadius.circular(10),
),
child: Text(
tag,
style: GoogleFonts.inter(
fontSize: 12,
fontWeight: FontWeight.w500,
color: AppColors.accent,
),
),
);
}).toList(),
),
],
// Footer
const SizedBox(height: 14),
Container(
padding: const EdgeInsets.only(top: 12),
decoration: BoxDecoration(
border: Border(
top: BorderSide(
color: AppColors.borderLight,
width: 0.5,
),
),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
VoteButtons(
upvotes: doubt.upvotes,
downvotes: doubt.downvotes,
currentVote: currentVote,
onVote: (type) => provider.voteOnDoubt(doubt.id, type),
),
Row(
children: [
const Icon(
Icons.chat_bubble_outline,
size: 15,
color: AppColors.textTertiary,
),
const SizedBox(width: 5),
Text(
'${doubt.replyCount}',
style: GoogleFonts.inter(
fontSize: 13,
fontWeight: FontWeight.w500,
color: AppColors.textTertiary,
),
),
],
),
],
),
),
],
),
),
),
);
}
}