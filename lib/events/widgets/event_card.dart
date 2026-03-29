import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── BANNER ──
            Stack(
              children: [
                // Background gradient with category icon
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.forumColors[
                            event.forumName.length %
                                AppTheme.forumColors.length],
                        AppTheme.forumColors[
                                event.forumName.length %
                                    AppTheme.forumColors.length]
                            .withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _categoryIcon(event.category),
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),

                // FULL / CLOSED badge
                if (!event.isRegistrationOpen)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isFull
                            ? Colors.red
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.isFull
                            ? 'FULL'
                            : event.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Category badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── CONTENT ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Forum name
                  Text(
                    event.forumName,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.startDate),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(event.startDate),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Venue
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Spots left + Fee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${event.availableSpots} spots left',
                            style: TextStyle(
                              color: event.availableSpots < 10
                                  ? Colors.red
                                  : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Fee badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.registrationFee == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.registrationFee == 0
                              ? 'FREE'
                              : '₹${event.registrationFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: event.registrationFee == 0
                                ? Colors.green
                                : AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category icon based on event type
  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Icons.computer;
      case 'cultural':
        return Icons.music_note;
      case 'sports':
        return Icons.sports_soccer;
      case 'workshop':
        return Icons.build;
      case 'hackathon':
        return Icons.code;
      case 'seminar':
        return Icons.mic;
      default:
        return Icons.event;
    }
  }
}