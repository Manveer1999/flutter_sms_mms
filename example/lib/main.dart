import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_mms/sms_mms.dart';

void main() {
  runApp(const MaterialApp(home: ExamplePage()));
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _recipients = [];
  List<String> _attachments = [];

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addRecipient() {
    final number = _recipientController.text.trim();
    if (number.isEmpty) return;
    setState(() {
      _recipients.add(number);
      _recipientController.clear();
    });
  }

  Future<void> _pickFiles() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (picked == null) return;
    setState(() {
      _attachments =
          picked.files.map((f) => f.path).whereType<String>().toList();
    });
  }

  Future<void> _send() async {
    if (_recipients.isEmpty) {
      _show('Add at least one recipient');
      return;
    }
    try {
      final result = await SmsMms.send(
        recipients: _recipients,
        message: _messageController.text,
        filePaths: _attachments,
      );
      _show(switch (result) {
        SmsMmsResult.sent => 'Message sent',
        SmsMmsResult.cancelled => 'Message cancelled',
        SmsMmsResult.failed => 'Message failed to send',
        SmsMmsResult.unknown => 'Messaging app opened',
      });
    } on PlatformException catch (e) {
      _show('${e.code}: ${e.message}');
    }
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS/MMS example')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final (i, number) in _recipients.indexed)
                Chip(
                  label: Text(number),
                  onDeleted: () => setState(() => _recipients.removeAt(i)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recipientController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Recipient',
              hintText: '+4915112345678',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _addRecipient,
                icon: const Icon(Icons.add),
              ),
            ),
            onSubmitted: (_) => _addRecipient(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file),
            label: Text(_attachments.isEmpty
                ? 'Attach files'
                : '${_attachments.length} file(s) attached'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _send,
            child: const Text('Open messaging app'),
          ),
        ],
      ),
    );
  }
}
