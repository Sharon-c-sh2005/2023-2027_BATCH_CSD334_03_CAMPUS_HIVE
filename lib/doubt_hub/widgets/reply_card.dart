import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reply.dart';
import '../models/vote.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import 'avatar_widget.dart';
import 'vote_buttons.dart';
class ReplyCard extends StatelessWidget {
final Reply reply;
final VoteType? currentVote;
final Function(VoteType) onVote;
final bool isNested;
const ReplyCard({
super.key,
required this.reply,
required this.currentVote,
required this.onVote,
this.isNested = false,
});
@override
Widget build(BuildContext context) {
return Container(
margin: EdgeInsets.only(left: isNested ? 24 : 0),
padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
decoration: BoxDecoration(
border: Border(
bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
left: isNested
? BorderSide(color: AppColors.border, width: 2)
: BorderSide.none,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header
Row(
children: [
AvatarWidget.fromHex(
name: reply.authorName,
hexColor: reply.authorAvatar,
size: 30,
),
const SizedBox(width: 8),
Text(
reply.authorName,
style: GoogleFonts.inter(
fontSize: 13,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
),
const SizedBox(width: 8),
Text(
formatTimeAgo(reply.createdAt),
style: GoogleFonts.inter(
fontSize: 12,
color: AppColors.textTertiary,
),
),
],
),
const SizedBox(height: 8),
// Body
Text(
reply.body,
style: GoogleFonts.inter(
fontSize: 14,
color: AppColors.text,
height: 1.4,
),
),
const SizedBox(height: 10),
// Vote buttons
VoteButtons(
upvotes: reply.upvotes,
downvotes: reply.downvotes,
currentVote: currentVote,
onVote: onVote,
compact: true,
),
],
),
);
}
}
