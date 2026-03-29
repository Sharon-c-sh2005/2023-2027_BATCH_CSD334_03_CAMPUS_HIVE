import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
class FilterChipsWidget extends StatelessWidget {
final FilterType active;
final Function(FilterType) onChanged;
const FilterChipsWidget({
super.key,
required this.active,
required this.onChanged,
});
@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
child: Row(
children: [
_FilterChip(
label: 'Hot',
icon: Icons.local_fire_department,
isActive: active == FilterType.hot,
onTap: () => onChanged(FilterType.hot),
),
const SizedBox(width: 8),
_FilterChip(
label: 'New',
icon: Icons.access_time,
isActive: active == FilterType.recent,
onTap: () => onChanged(FilterType.recent),
),
const SizedBox(width: 8),
_FilterChip(
label: 'Unsolved',
icon: Icons.help_outline,
isActive: active == FilterType.unsolved,
onTap: () => onChanged(FilterType.unsolved),
),
],
),
);
}
}
class _FilterChip extends StatelessWidget {
final String label;
final IconData icon;
final bool isActive;
final VoidCallback onTap;
const _FilterChip({
required this.label,
required this.icon,
required this.isActive,
required this.onTap,
});
@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: () {
HapticFeedback.lightImpact();
onTap();
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
decoration: BoxDecoration(
color: isActive ? AppColors.chipActive : AppColors.chipBg,
borderRadius: BorderRadius.circular(20),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
size: 14,
color: isActive ? Colors.white : AppColors.textSecondary,
),
const SizedBox(width: 5),
Text(
label,
style: GoogleFonts.inter(
fontSize: 13,
fontWeight: FontWeight.w500,
color: isActive ? Colors.white : AppColors.textSecondary,
),
),
],
),
),
);
}
}