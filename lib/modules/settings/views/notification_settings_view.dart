import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bool masterSwitch =
            controller.settings['all_notifications'] ?? true;

        return ListView(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          children: [
            _sectionHeader('Master Switch'),
            _switchTile(
              controller,
              'Enable All Notifications',
              'Turn off to disable all alerts',
              'all_notifications',
            ),
            Divider(height: 32.h),
            _sectionHeader('Alert Types'),
            _switchTile(
              controller,
              'New Requests',
              'Alerts for nearby breakdown assistance',
              'new_requests',
              enabled: masterSwitch,
            ),
            _switchTile(
              controller,
              'Job Updates',
              'Status changes like accepted, arrived, completed',
              'job_updates',
              enabled: masterSwitch,
            ),
            _switchTile(
              controller,
              'Chat Messages',
              'Direct messages from drivers/mechanics',
              'chat_messages',
              enabled: masterSwitch,
            ),
            _switchTile(
              controller,
              'Payments & Earnings',
              'Alerts for payments received',
              'payments',
              enabled: masterSwitch,
            ),
            _switchTile(
              controller,
              'Promotions',
              'Special offers and platform news',
              'promotions',
              enabled: masterSwitch,
            ),
            Divider(height: 32.h),
            _sectionHeader('Device Defaults'),
            _switchTile(
              controller,
              'Sound Enabled',
              'Play notification tone',
              'sound_enabled',
              enabled: masterSwitch,
            ),
            _switchTile(
              controller,
              'Vibration Enabled',
              'Vibrate heavily on alerts',
              'vibration_enabled',
              enabled: masterSwitch,
            ),
          ],
        );
      }),
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
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _switchTile(
    SettingsController controller,
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
        value: enabled ? (controller.settings[key] ?? true) : false,
        onChanged: enabled ? (val) => controller.updateSetting(key, val) : null,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
