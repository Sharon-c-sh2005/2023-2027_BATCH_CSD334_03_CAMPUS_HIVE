import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
class EmptyState extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
const EmptyState({
super.key,
required this.icon,
required this.title,
required this.subtitle,
});
@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 88,
height: 88,
decoration: BoxDecoration(
color: AppColors.chipBg,
shape: BoxShape.circle,
),
child: Icon(icon, size: 48, color: AppColors.textTertiary),
),
const SizedBox(height: 20),
Text(
title,
style: GoogleFonts.inter(
fontSize: 18,
fontWeight: FontWeight.w600,
color: AppColors.text,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
Text(
subtitle,
style: GoogleFonts.inter(
fontSize: 14,
color: AppColors.textSecondary,
height: 1.4,
),
textAlign: TextAlign.center,
),
],
),
),
);
}
}