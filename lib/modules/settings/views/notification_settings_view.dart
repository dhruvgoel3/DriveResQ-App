import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;

  // Settings Mapping
  Map<String, bool> settings = {
    'all_notifications': true,
    'new_requests': true,
    'job_updates': true,
    'chat_messages': true,
    'payments': true,
    'promotions': true,
    'sound_enabled': true,
    'vibration_enabled': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data() ?? {};
      if (data.containsKey('notificationSettings')) {
        final savedPrefs = data['notificationSettings'] as Map<String, dynamic>;
        savedPrefs.forEach((key, value) {
          if (settings.containsKey(key)) {
            settings[key] = value == true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (uid == null) return;

    // Optimistic update
    setState(() {
      settings[key] = value;
      // If toggling all notifications off, disable others visually?
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationSettings': {key: value},
      }, SetOptions(merge: true));
    } catch (e) {
      // Revert if error
      setState(() => settings[key] = !value);
      AppSnackbar.error('Could not update settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Whether individual keys are disabled due to "All Notifications" switch
    final bool masterSwitch = settings['all_notifications'] ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Notification Preferences',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          _sectionHeader('Master Switch'),
          _switchTile(
            'Enable All Notifications',
            'Turn off to disable all alerts',
            'all_notifications',
          ),

          Divider(height: 32.h),
          _sectionHeader('Alert Types'),
          _switchTile(
            'New Requests',
            'Alerts for nearby breakdown assistance',
            'new_requests',
            enabled: masterSwitch,
          ),
          _switchTile(
            'Job Updates',
            'Status changes like accepted, arrived, completed',
            'job_updates',
            enabled: masterSwitch,
          ),
          _switchTile(
            'Chat Messages',
            'Direct messages from drivers/mechanics',
            'chat_messages',
            enabled: masterSwitch,
          ),
          _switchTile(
            'Payments & Earnings',
            'Alerts for payments received',
            'payments',
            enabled: masterSwitch,
          ),
          _switchTile(
            'Promotions',
            'Special offers and platform news',
            'promotions',
            enabled: masterSwitch,
          ),

          Divider(height: 32.h),
          _sectionHeader('Device Defaults'),
          _switchTile(
            'Sound Enabled',
            'Play notification tone',
            'sound_enabled',
            enabled: masterSwitch,
          ),
          _switchTile(
            'Vibration Enabled',
            'Vibrate heavily on alerts',
            'vibration_enabled',
            enabled: masterSwitch,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6C63FF),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    String key, {
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Switch(
        value: enabled ? (settings[key] ?? true) : false,
        onChanged: enabled ? (val) => _updateSetting(key, val) : null,
        activeThumbColor: const Color(0xFF6C63FF),
      ),
    );
  }
}
