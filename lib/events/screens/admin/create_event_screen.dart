import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String forumId;
  const CreateEventScreen({super.key, required this.forumId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _meetCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '0');
  final _maxCtrl = TextEditingController(text: '100');
  final _tagsCtrl = TextEditingController();
  final _formUrlCtrl = TextEditingController();

  String _category = 'Technical';
  EventMode _mode = EventMode.offline;
  bool _isLoading = false;

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7, hours: 2));
  DateTime _regDeadline = DateTime.now().add(const Duration(days: 6));

  final List<Map<String, dynamic>> _customFields = [];

  final List<String> categories = [
    'Technical', 'Cultural', 'Sports', 'Workshop',
    'Seminar', 'Social', 'Hackathon', 'Competition', 'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _meetCtrl.dispose();
    _feeCtrl.dispose();
    _maxCtrl.dispose();
    _tagsCtrl.dispose();
    _formUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String which) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dt = DateTime(
        picked.year, picked.month, picked.day, time.hour, time.minute);
    setState(() {
      if (which == 'start') _startDate = dt;
      if (which == 'end') _endDate = dt;
      if (which == 'deadline') _regDeadline = dt;
    });
  }

  void _addCustomField() {
    final labelCtrl = TextEditingController();
    String type = 'text';
    bool required = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setS) => AlertDialog(
          title: const Text('Add Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration:
                    const InputDecoration(labelText: 'Field Label'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text')),
                  DropdownMenuItem(
                      value: 'textarea', child: Text('Long Text')),
                  DropdownMenuItem(
                      value: 'number', child: Text('Number')),
                ],
                onChanged: (v) => setS(() => type = v!),
              ),
              CheckboxListTile(
                title: const Text('Required'),
                value: required,
                onChanged: (v) => setS(() => required = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelCtrl.text.isNotEmpty) {
                  setState(() => _customFields.add({
                        'key': labelCtrl.text
                            .toLowerCase()
                            .replaceAll(' ', '_'),
                        'label': labelCtrl.text,
                        'type': type,
                        'required': required,
                      }));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final eventService = context.read<EventService>();
    final forum = await eventService.getForum(widget.forumId);
    if (forum == null || !mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final event = EventModel(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      forumId: widget.forumId,
      forumName: forum.name,
      venue: _venueCtrl.text.trim(),
      mode: _mode,
      meetLink:
          _meetCtrl.text.trim().isEmpty ? null : _meetCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      registrationDeadline: _regDeadline,
      maxParticipants: int.tryParse(_maxCtrl.text) ?? 100,
      category: _category,
      registrationFee: double.tryParse(_feeCtrl.text) ?? 0,
      tags: _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      createdBy: firebaseUser.uid,
      customFields: [
        ..._customFields,
        if (_formUrlCtrl.text.trim().isNotEmpty)
          {
            'key': 'registrationFormUrl',
            'label': 'Registration Form',
            'value': _formUrlCtrl.text.trim(),
            'type': 'url',
            'required': false,
          },
      ],
      requiresApproval: false,
      createdAt: DateTime.now(),
    );

    try {
      await eventService.createEvent(event);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Event Title *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description *',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            const Text('Mode', style: TextStyle(color: Colors.grey)),
            Row(
              children: EventMode.values
                  .map((m) => Expanded(
                        child: RadioListTile<EventMode>(
                          title: Text(m.name,
                              style: const TextStyle(fontSize: 13)),
                          value: m,
                          groupValue: _mode,
                          onChanged: (v) => setState(() => _mode = v!),
                          dense: true,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _venueCtrl,
              decoration: const InputDecoration(
                labelText: 'Venue *',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            if (_mode != EventMode.offline) ...[
              TextFormField(
                controller: _meetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meet Link',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _dateRow('Start', _startDate, () => _pickDate('start')),
            const SizedBox(height: 12),
            _dateRow('End', _endDate, () => _pickDate('end')),
            const SizedBox(height: 12),
            _dateRow('Reg. Deadline', _regDeadline,
                () => _pickDate('deadline')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Participants',
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _feeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fee (₹)',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                prefixIcon: Icon(Icons.label),
                hintText: 'coding, flutter, beginner',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _formUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Google Form URL (for registration)',
                prefixIcon: Icon(Icons.link),
                hintText: 'https://docs.google.com/forms/...',
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Custom Fields',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCustomField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._customFields.asMap().entries.map(
                  (e) => ListTile(
                    leading: const Icon(Icons.input),
                    title: Text(e.value['label']),
                    subtitle: Text(
                      '${e.value['type']} • '
                      '${e.value['required'] ? 'Required' : 'Optional'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          setState(() => _customFields.removeAt(e.key)),
                    ),
                  ),
                ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Event'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _dateRow(String label, DateTime dt, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}