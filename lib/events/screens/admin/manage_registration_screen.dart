import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class ManageRegistrationsScreen extends StatelessWidget {
  final EventModel event;
  const ManageRegistrationsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final eventService = context.read<EventService>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrations'),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<RegistrationModel>>(
        stream: eventService.getEventRegistrations(event.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final regs = snap.data ?? [];

          if (regs.isEmpty) {
            return const Center(
              child: Text(
                'No registrations yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              // Summary bar
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _stat('Total', '${regs.length}', Colors.blue),
                    _stat(
                      'Registered',
                      '${regs.where((r) => r.status == 'approved').length}',
                      Colors.green,
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: regs.length,
                  itemBuilder: (_, i) {
                    final reg = regs[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.15),
                          child: Text(
                            reg.userName.isNotEmpty
                                ? reg.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          reg.userName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          reg.userEmail,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          DateFormat('MMM dd').format(reg.registeredAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}