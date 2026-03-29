

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/my_projects_section.dart';
import '../widgets/category_pills.dart';
import '../widgets/live_projects_feed.dart';
import '../widgets/filter_sheet.dart';
import 'create_project_page.dart';

import '../../../doubt_hub/screens/home_screen.dart' as DoubtHub;
import '../../../doubt_hub/providers/doubts_provider.dart';
import '../../../doubt_hub/screens/profile_screen.dart' as DoubtHubProfile;
import '../../../doubt_hub/utils/colors.dart';

import '../../../events/screens/home/explore_tab.dart';
import '../../../events/services/event_service.dart';

class ProjectZonePage extends StatefulWidget {
  final String currentUserId;
  final int? initialIndex;

  const ProjectZonePage({
    super.key,
    required this.currentUserId,
    this.initialIndex,
  });

  @override
  State<ProjectZonePage> createState() => _ProjectZonePageState();
}

class _ProjectZonePageState extends State<ProjectZonePage> {
  late int _currentIndex;
  String searchQuery = '';
  String selectedCategory = '';
  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? _buildProjectsAppBar() : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // TAB 0 — PROJECTS
          _buildProjectsBody(),

          // TAB 1 — DOUBT HUB
          ChangeNotifierProvider(
            create: (_) => DoubtsProvider()..init(),
            child: const DoubtHub.HomeScreen(),
          ),

          // TAB 2 — EVENTS
          ChangeNotifierProvider(
            create: (_) => EventService(),
            child: const ExploreTab(),
          ),

          // TAB 3 — PROFILE
          ChangeNotifierProvider(
            create: (_) => DoubtsProvider()..init(),
            child: const DoubtHubProfile.ProfileScreen(),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1A1A2E),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateProjectPage()),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Doubt Hub',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  AppBar _buildProjectsAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: SizedBox(
        height: 40,
        child: TextField(
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            hintText: 'Search projects...',
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textTertiary),
            prefixIcon:
                Icon(Icons.search, size: 18, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => setState(() => searchQuery = val),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.tune, color: AppColors.text),
          onPressed: _openFilterSheet,
        ),
      ],
    );
  }

  Widget _buildProjectsBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyProjectsSection(currentUserId: widget.currentUserId),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Live Projects',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: AppColors.background),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CategoryPills(
            selected: selectedCategory,
            onSelect: (cat) => setState(() => selectedCategory = cat),
          ),
          const SizedBox(height: 12),
          LiveProjectsFeed(
            searchQuery: searchQuery,
            category: selectedCategory,
            status: selectedStatus,
            currentUserId: widget.currentUserId,
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: FilterSheet(
            currentCategory: selectedCategory,
            currentStatus: selectedStatus,
            onApply: (category, status) {
              setState(() {
                selectedCategory = category;
                selectedStatus = status;
              });
            },
          ),
        ),
      ),
    );
  }
}


