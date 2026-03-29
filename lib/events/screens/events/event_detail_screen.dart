import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/theme.dart';
import '../../../../doubt_hub/utils/colors.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final eventService = EventService();
    final isCreator = user?.uid == event.createdBy;
    final userId = user?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          // ── HEADER ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              title: Text(
                event.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.forumColors[
                          event.forumName.length %
                              AppTheme.forumColors.length],
                      AppTheme.primary,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── BODY ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Forum badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.forumName,
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info row 1
                  Row(
                    children: [
                      Expanded(child: _infoCard(Icons.calendar_today,
                          'Date',
                          DateFormat('MMM dd').format(event.startDate))),
                      const SizedBox(width: 8),
                      Expanded(child: _infoCard(Icons.access_time,
                          'Time',
                          DateFormat('HH:mm').format(event.startDate))),
                      const SizedBox(width: 8),
                      Expanded(child: _infoCard(Icons.people, 'Spots',
                          '${event.availableSpots}/${event.maxParticipants}')),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Info row 2
                  Row(
                    children: [
                      Expanded(child: _infoCard(
                          Icons.currency_rupee,
                          'Fee',
                          event.registrationFee == 0
                              ? 'Free'
                              : '₹${event.registrationFee.toStringAsFixed(0)}')),
                      const SizedBox(width: 8),
                      Expanded(child: _infoCard(Icons.location_on,
                          'Mode', event.mode.name.toUpperCase())),
                      const SizedBox(width: 8),
                      Expanded(child: _infoCard(
                          Icons.category, 'Category', event.category)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Venue
                  Text('Venue',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // About
                  Text('About',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text)),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Registration deadline
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DateTime.now()
                              .isAfter(event.registrationDeadline)
                          ? Colors.red.withValues(alpha: 0.08)
                          : Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: DateTime.now()
                                  .isAfter(event.registrationDeadline)
                              ? Colors.red
                              : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Register by ${DateFormat('MMM dd, HH:mm').format(event.registrationDeadline)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DateTime.now()
                                    .isAfter(event.registrationDeadline)
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── REGISTER BUTTON ──
      bottomSheet: user == null || isCreator
          ? null
          : FutureBuilder<RegistrationModel?>(
              future: eventService.getRegistration(event.id, userId!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surface,
                    child: const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final isRegistered = snap.data != null;

                return Container(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isRegistered
                        ? null
                        : !event.isRegistrationOpen
                            ? null
                            : () => _registerViaForm(
                                context, event, userId!),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: isRegistered
                          ? Colors.green
                          : AppTheme.primary,
                      disabledBackgroundColor: isRegistered
                          ? Colors.green
                          : Colors.grey[300],
                      disabledForegroundColor: isRegistered
                          ? Colors.white
                          : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRegistered) ...[
                          const Icon(Icons.check_circle,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          isRegistered
                              ? 'Registered'
                              : event.isFull
                                  ? 'Event Full'
                                  : !event.isRegistrationOpen
                                      ? 'Registration Closed'
                                      : 'Register Now',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  Future<void> _registerViaForm(
      BuildContext context, EventModel event, String userId) async {
    final eventService = EventService();

    await eventService.registerForEvent(
      event: event,
      userId: userId,
      userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
      userEmail: FirebaseAuth.instance.currentUser?.email ?? '',
    );

    // Find Google Form URL and open it
    String formUrl = '';
    for (final field in event.customFields) {
      if (field['key'] == 'registrationFormUrl') {
        formUrl = field['value']?.toString() ?? '';
        break;
      }
    }

    if (formUrl.isNotEmpty) {
      final uri = Uri.parse(formUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
                color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}