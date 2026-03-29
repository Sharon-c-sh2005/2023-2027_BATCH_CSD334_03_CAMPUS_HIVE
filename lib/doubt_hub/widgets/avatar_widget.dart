import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/helpers.dart';
class AvatarWidget extends StatelessWidget {
final String name;
final Color color;
final double size;
const AvatarWidget({
super.key,
required this.name,
required this.color,
this.size = 36,
});
factory AvatarWidget.fromHex({
required String name,
required String hexColor,
double size = 36,
}) {
Color color;
try {
final hex = hexColor.replaceAll('#', '');
color = Color(int.parse('FF$hex', radix: 16));
} catch (_) {
color = Colors.grey;
}
final safeName = name.trim().isEmpty ? 'Anonymous' : name;
return AvatarWidget(name: name, color: color, size: size);
}

/*
@override
Widget build(BuildContext context) {
return Container(
width: size,
height: size,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
),
alignment: Alignment.center,
child: Text(
getInitials(name),
style: GoogleFonts.inter(
fontSize: size * 0.38,
fontWeight: FontWeight.w600,
color: Colors.white,
letterSpacing: 0.5,
),
),
);
}*/

@override
Widget build(BuildContext context) {
  final safeName = name.trim().isEmpty ? '?' : name;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      getInitials(safeName),
      style: GoogleFonts.inter(
fontSize: size * 0.38,
fontWeight: FontWeight.w600,
color: Colors.white,
letterSpacing: 0.5,
),
),
);
}

}
