import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _userIdController = TextEditingController();
  final _expiryHoursController = TextEditingController(text: '24');
  String _target = 'all'; // all | riders | drivers | user

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _userIdController.dispose();
    _expiryHoursController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final hours = int.tryParse(_expiryHoursController.text.trim()) ?? 24;
    final expiresAt = now.add(Duration(hours: hours));

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isRead': false,
      'target': _target,
    };

    if (_target == 'user') {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter userId'.tr)),
        );
        return;
      }
      data['userId'] = userId;
    }

    await FirebaseFirestore.instance.collection('notifications').add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent'.tr)),
    );

    _titleController.clear();
    _messageController.clear();
    _userIdController.clear();
    _expiryHoursController.text = '24';
    setState(() {
      _target = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required'.tr : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required'.tr : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _target,
                      decoration: InputDecoration(
                        labelText: 'Target'.tr,
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('All users')),
                        DropdownMenuItem(
                            value: 'riders', child: Text('Riders')),
                        DropdownMenuItem(
                            value: 'drivers', child: Text('Drivers')),
                        DropdownMenuItem(
                            value: 'user', child: Text('Specific user')),
                      ],
                      onChanged: (v) => setState(() => _target = v ?? 'all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_target == 'user')
                    Expanded(
                      child: TextFormField(
                        controller: _userIdController,
                        decoration: InputDecoration(
                          labelText: 'User ID'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (_target == 'user' &&
                              (v == null || v.trim().isEmpty)) {
                            return 'Required'.tr;
                          }
                          return null;
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiryHoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Expiry (hours)'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _send,
                  child: Text('Send'.tr),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
