import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final String currentCategory;
  final String currentStatus;
  final Function(String category, String status) onApply;

  const FilterSheet({
    super.key,
    required this.currentCategory,
    required this.currentStatus,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String selectedCategory;
  late String selectedStatus;

  final TextEditingController customTechCtrl = TextEditingController();

static const List<String> statuses = ['All', 'active', 'on hold', 'finished'];
static const List<String> techOptions = [
  'All', 'Flutter', 'React', 'Python', 'ML/AI',
  'Firebase', 'Node.js', 'UI/UX', 'Web', 'AI',
  'Swift', 'Kotlin', 'Vue', 'Django',
];

  // ADD:
@override
void dispose() {
  customTechCtrl.dispose();
  super.dispose();
}
  
  @override
  void initState() {
    super.initState();
    selectedCategory = widget.currentCategory;
    selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HANDLE
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Projects",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = '';
                    selectedStatus = '';
                  });
                },
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // STATUS FILTER
          const Text(
            "STATUS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statuses.map((s) {
              final isSelected =
                  s == 'All' ? selectedStatus.isEmpty : selectedStatus == s;
              return GestureDetector(
                onTap: () => setState(
                    () => selectedStatus = s == 'All' ? '' : s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    s == 'active'
                        ? '🟢  Active'
                        : s == 'on hold'
                            ? '🟡  On Hold'
                            : s == 'finished'
                                ? '⚫  Finished'
                                : 'All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // TECH FILTER
          const Text(
            "TECH STACK",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(

  spacing: 8,
  runSpacing: 8,
  children: techOptions.map((t) {
    final isSelected =
        t == 'All' ? selectedCategory.isEmpty : selectedCategory == t;
    return GestureDetector(
      onTap: () => setState(
          () => selectedCategory = t == 'All' ? '' : t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A1A2E)    : Colors.grey.shade300,
          ),
        ),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }).toList(),
          ),

          const SizedBox(height: 12),

          Row(
  children: [
    Expanded(
      child: TextField(
        controller: customTechCtrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: "Filter by custom tech...",
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color:  Color(0xFF1A1A2E), width: 1.5),
          ),
          suffixIcon: customTechCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() {
                    customTechCtrl.clear();
                    if (!techOptions.contains(selectedCategory)) {
                      selectedCategory = '';
                    }
                  }),
                )
              : null,
        ),
        onChanged: (val) => setState(() {
          selectedCategory = val.trim();
        }),
      ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        final custom = customTechCtrl.text.trim();
        if (custom.isNotEmpty) {
          setState(() => selectedCategory = custom);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.search, color: Colors.white, size: 20),
      ),
    ),
  ],
),

// SHOW ACTIVE CUSTOM FILTER BADGE
if (selectedCategory.isNotEmpty &&
    !techOptions.contains(selectedCategory)) ...[
  const SizedBox(height: 10),
  Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCategory,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:  Color(0xFF1A1A2E)
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() {
                selectedCategory = '';
                customTechCtrl.clear();
              }),
              child: const Icon(Icons.close,
                  size: 13, color:  Color(0xFF1A1A2E)),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        "Custom filter active",
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      ),
    ],
  ),
],

const SizedBox(height: 28),



          // APPLY BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(selectedCategory, selectedStatus);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}