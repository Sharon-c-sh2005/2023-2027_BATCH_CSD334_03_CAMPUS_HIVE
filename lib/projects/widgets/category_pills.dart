import 'package:flutter/material.dart';

class CategoryPills extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;

  const CategoryPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<Map<String, dynamic>> categories = [
    {'label': 'All', 'icon': Icons.apps},
    {'label': 'Flutter', 'icon': Icons.phone_android},
    {'label': 'React', 'icon': Icons.web},
    {'label': 'Python', 'icon': Icons.code},
    {'label': 'ML/AI', 'icon': Icons.auto_awesome},
    {'label': 'Firebase', 'icon': Icons.cloud},
    {'label': 'Node.js', 'icon': Icons.storage},
    {'label': 'UI/UX', 'icon': Icons.brush},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected =
              label == 'All' ? selected.isEmpty : selected == label;

          return GestureDetector(
            onTap: () => onSelect(label == 'All' ? '' : label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A1A2E)
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}