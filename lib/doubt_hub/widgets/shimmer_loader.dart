import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/colors.dart';
class DoubtCardShimmer extends StatelessWidget {
const DoubtCardShimmer({super.key});
@override
Widget build(BuildContext context) {
return Container(
margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(16),
),
child: Shimmer.fromColors(
baseColor: AppColors.border,
highlightColor: AppColors.borderLight,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Header
Row(
children: [
const CircleAvatar(radius: 18, backgroundColor: Colors.white),
const SizedBox(width: 10),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 100,
height: 14,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 4),
Container(
width: 60,
height: 12,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
],
),
],
),
const SizedBox(height: 12),
// Title
Container(
width: double.infinity,
height: 18,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 6),
Container(
width: MediaQuery.of(context).size.width * 0.6,
height: 18,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 12),
// Body
Container(
width: double.infinity,
height: 14,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 4),
Container(
width: MediaQuery.of(context).size.width * 0.5,
height: 14,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
const SizedBox(height: 16),
// Footer
Row(
children: [
Container(
width: 70,
height: 28,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
),
),
const SizedBox(width: 12),
Container(
width: 70,
height: 28,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
),
),
],
),
],
),
),
);
}
}
class ShimmerList extends StatelessWidget {
const ShimmerList({super.key});
@override
Widget build(BuildContext context) {
return ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: 4,
itemBuilder: (context, index) => const DoubtCardShimmer(),
);
}
}