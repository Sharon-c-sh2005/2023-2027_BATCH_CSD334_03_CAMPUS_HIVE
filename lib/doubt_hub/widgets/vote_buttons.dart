import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vote.dart';
import '../utils/colors.dart';
class VoteButtons extends StatelessWidget {
final int upvotes;
final int downvotes;
final VoteType? currentVote;
final Function(VoteType) onVote;
final bool compact;
const VoteButtons({
super.key,
required this.upvotes,
required this.downvotes,
required this.currentVote,
required this.onVote,
this.compact = false,
});
@override
Widget build(BuildContext context) {
return Row(
mainAxisSize: MainAxisSize.min,
children: [
_VoteButton(
direction: VoteType.up,
count: upvotes,
isActive: currentVote == VoteType.up,
onTap: () => onVote(VoteType.up),
compact: compact,
),
const SizedBox(width: 6),
_VoteButton(
direction: VoteType.down,
count: downvotes,
isActive: currentVote == VoteType.down,
onTap: () => onVote(VoteType.down),
compact: compact,
),
],
);
}
}
class _VoteButton extends StatefulWidget {
final VoteType direction;
final int count;
final bool isActive;
final VoidCallback onTap;
final bool compact;
const _VoteButton({
required this.direction,
required this.count,
required this.isActive,
required this.onTap,
this.compact = false,
});
@override
State<_VoteButton> createState() => _VoteButtonState();
}
class _VoteButtonState extends State<_VoteButton>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
@override
void initState() {
super.initState();
_controller = AnimationController(
duration: const Duration(milliseconds: 200),
vsync: this,
);
_scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
);
}
@override
void dispose() {
_controller.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
final isUp = widget.direction == VoteType.up;
final color = widget.isActive
? (isUp ? AppColors.upvote : AppColors.downvote)
: AppColors.textTertiary;
final bgColor = widget.isActive
? (isUp ? AppColors.upvoteLight : AppColors.downvoteLight)
: Colors.transparent;
return GestureDetector(
onTap: () {
HapticFeedback.lightImpact();
_controller.forward().then((_) => _controller.reverse());
widget.onTap();
},
child: Container(
padding: EdgeInsets.symmetric(
horizontal: widget.compact ? 8 : 10,
vertical: widget.compact ? 4 : 6,
),
decoration: BoxDecoration(
color: bgColor,
borderRadius: BorderRadius.circular(20),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
ScaleTransition(
scale: _scaleAnimation,
child: Icon(
isUp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
size: widget.compact ? 16 : 18,
color: color,
),
),
const SizedBox(width: 4),
Text(
'${widget.count}',
style: GoogleFonts.inter(
fontSize: widget.compact ? 12 : 13,
fontWeight: FontWeight.w600,
color: color,
),
),
],
),
),
);
}
}