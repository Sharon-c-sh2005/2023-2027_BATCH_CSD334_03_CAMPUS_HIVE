import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
import '../widgets/doubt_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import 'doubt_detail_screen.dart';
import 'compose_screen.dart';
class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});
@override
State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
final TextEditingController _searchController = TextEditingController();
@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) return;
context.read<DoubtsProvider>().init();
});
}
@override
void dispose() {
_searchController.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
final provider = context.watch<DoubtsProvider>();
return Scaffold(
backgroundColor: AppColors.background,
body: RefreshIndicator(
color: AppColors.primary,
onRefresh: () async {
// Real-time stream handles updates automatically
await Future.delayed(const Duration(milliseconds: 500));
},
child: CustomScrollView(
slivers: [
// App Bar
SliverAppBar(
floating: true,
snap: true,
backgroundColor: AppColors.surface,
surfaceTintColor: Colors.transparent,
elevation: 0,
title: Text(
'AskHub',
style: GoogleFonts.inter(
fontSize: 24,
fontWeight: FontWeight.w700,
color: AppColors.text,
),
),
bottom: PreferredSize(
preferredSize: const Size.fromHeight(110),
child: Column(
children: [
SearchBarWidget(
value: provider.searchQuery,
onChanged: (q) => provider.setSearchQuery(q),
),
FilterChipsWidget(
active: provider.filter,
onChanged: (f) => provider.setFilter(f),
),
],
),
),
),
// Content
if (provider.isLoading)
const SliverToBoxAdapter(child: ShimmerList())
else if (provider.filteredDoubts.isEmpty)
SliverFillRemaining(
hasScrollBody: false,
child: provider.searchQuery.isNotEmpty
? const EmptyState(
icon: Icons.search_off,
title: 'No matches found',
subtitle:
'Try adjusting your search or filters to find what you\'re looking for.',
)
: const EmptyState(
icon: Icons.chat_bubble_outline,
title: 'No doubts yet',
subtitle:
'Be the first to ask a question and start the conversation!',
),
)
else
SliverList(
delegate: SliverChildBuilderDelegate(
(context, index) {
final doubt = provider.filteredDoubts[index];
return DoubtCard(
doubt: doubt,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
DoubtDetailScreen(doubtId: doubt.id),
),
);
},
);
},
childCount: provider.filteredDoubts.length,
),
),
// Bottom padding
const SliverToBoxAdapter(
child: SizedBox(height: 100),
),
],
),
),
floatingActionButton: FloatingActionButton(
onPressed: () {
HapticFeedback.mediumImpact();
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ComposeScreen(),
fullscreenDialog: true,
),
);
},
backgroundColor: AppColors.primary,
elevation: 6,
child: const Icon(Icons.add, color: Colors.white, size: 28),
),
);
}
}