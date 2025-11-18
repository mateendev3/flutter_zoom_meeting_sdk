import 'package:flutter/material.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterZoomMeetingSdk _zoomMeetingSdk = FlutterZoomMeetingSdk();

  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController(text: 'Flutter User');

  String _log = 'Not initialized';
  bool _initializing = false;
  bool _joining = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _meetingIdController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _log = 'Please provide a valid SDK JWT.');
      return;
    }
    setState(() {
      _initializing = true;
      _log = 'Initializing...';
    });
    try {
      final result = await _zoomMeetingSdk.initialize(jwtToken: token);
      setState(() {
        _log = 'Init response: $result';
      });
    } catch (error) {
      setState(() {
        _log = 'Init failed: $error';
      });
    } finally {
      setState(() {
        _initializing = false;
      });
    }
  }

  Future<void> _joinMeeting() async {
    final meetingId = _meetingIdController.text.trim();
    if (meetingId.isEmpty) {
      setState(() => _log = 'Meeting ID is required.');
      return;
    }
    setState(() {
      _joining = true;
      _log = 'Joining meeting...';
    });
    try {
      final result = await _zoomMeetingSdk.joinMeeting(
        meetingNumber: meetingId,
        password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? 'Flutter User'
            : _displayNameController.text.trim(),
      );
      setState(() {
        _log = 'Join response: $result';
      });
    } catch (error) {
      setState(() {
        _log = 'Join failed: $error';
      });
    } finally {
      setState(() {
        _joining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zoom SDK sample'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Step 1. Paste a valid SDK JWT token generated from your Zoom credentials.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'SDK JWT token',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _initializing ? null : _initialize,
                    child: Text(_initializing ? 'Initializing...' : 'Initialize SDK'),
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Step 2. Provide meeting details (must already exist) and join.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _meetingIdController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting password (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _joining ? null : _joinMeeting,
                    child: Text(_joining ? 'Joining...' : 'Join meeting'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _log,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
