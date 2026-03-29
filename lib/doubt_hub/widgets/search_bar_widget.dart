import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../screens/explore_screen.dart';
class SearchBarWidget extends StatelessWidget {
final String value;
final Function(String) onChanged;
const SearchBarWidget({
super.key,
required this.value,
required this.onChanged,
});
@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: Row(
children: [
/// 🔎 SEARCH BOX
Expanded(
child: Container(
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(14),
border: Border.all(color: AppColors.borderLight),
),
padding: const EdgeInsets.symmetric(horizontal: 14),
child: Row(
children: [
const Icon(Icons.search,
size: 18, color: AppColors.textTertiary),
const SizedBox(width: 10),
Expanded(
child: TextField(
onChanged: onChanged,
style: GoogleFonts.inter(
fontSize: 15,
color: AppColors.text,
),
decoration: InputDecoration(
hintText: 'Search doubts...',
hintStyle: GoogleFonts.inter(
fontSize: 15,
color: AppColors.textTertiary,
),
border: InputBorder.none,
contentPadding:
const EdgeInsets.symmetric(vertical: 12),
),
),
),
if (value.isNotEmpty)
GestureDetector(
onTap: () => onChanged(''),
child: const Icon(
Icons.cancel,
size: 18,
color: AppColors.textTertiary,
),
),
],
),
),
),
const SizedBox(width: 8),
/// 🌍 EXPLORE BUTTON
GestureDetector(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ExploreScreen(),
),
);
},
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: AppColors.primaryLight,
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.explore,
color: AppColors.primary,
size: 20,
),
),
),
],
),
);
}
}