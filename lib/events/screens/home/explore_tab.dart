import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../utils/theme.dart';
import '../../widgets/event_card.dart';
import '../events/event_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../doubt_hub/utils/colors.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final categories = [
    'All', 'Technical', 'Cultural', 'Sports',
    'Workshop', 'Seminar', 'Social', 'Hackathon', 'Competition'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventService = context.read<EventService>();

    return Scaffold(
      backgroundColor: AppColors.background,  // ← matches doubt hub bg
      body: CustomScrollView(
        slivers: [

          // ── APP BAR — matches doubt hub style ──
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface,      // ← white like doubt hub
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Events',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),

          // ── SEARCH BAR ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textTertiary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── CATEGORY CHIPS ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: selected
                                ? AppTheme.primary
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      backgroundColor: AppColors.surface,
                      selectedColor:
                          AppTheme.primary.withValues(alpha: 0.12),
                      checkmarkColor: AppTheme.primary,
                      side: BorderSide(
                        color: selected
                            ? AppTheme.primary
                            : Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── EVENTS LIST ──
          StreamBuilder<List<EventModel>>(
            stream: eventService.getAllEvents(
                category: _selectedCategory == 'All'
                    ? null
                    : _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator()));
              }

              var events = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                events = events
                    .where((e) =>
                        e.title
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        e.forumName
                            .toLowerCase()
                            .contains(_searchQuery))
                    .toList();
              }

              if (events.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64,
                            color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text('No events found',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: events[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                                event: events[i]),
                          ),
                        ),
                      ),
                    ),
                    childCount: events.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}