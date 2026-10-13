import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/helpers/app_snackbar.dart';
import '../../../utils/helpers/responsive_helper.dart';
import '../controllers/safety_sos_controller.dart';
import '../models/emergency_contact_model.dart';
import 'sos_countdown_overlay.dart';
import 'sos_incident_status_screen.dart';

/// The main Safety SOS management screen.
///
/// Accessible from the Driver Home view when an active request exists.
/// Shows:
///   - Feature status (active / waiting for mechanic acceptance).
///   - Emergency contacts list with CRUD.
///   - Shake detection toggle.
///   - Manual SOS button.
///   - Incident status shortcut.
class SafetySosScreen extends StatelessWidget {
  const SafetySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SafetySosController>();

    // Watch countdown state and show overlay when it becomes active
    ever(controller.isCountdownActive, (bool active) {
      if (active) {
        // Only open if not already open
        if (Get.currentRoute != '/sos-countdown') {
          Get.dialog(
            const SosCountdownOverlay(),
            barrierDismissible: false,
            routeSettings: const RouteSettings(name: '/sos-countdown'),
          ).then((_) {
            // When overlay closes (due to cancel or completion), navigate to status
            if (!controller.isCountdownActive.value &&
                controller.currentIncident.value != null) {
              Get.to(
                () => const SosIncidentStatusScreen(),
                transition: Transition.upToDown,
              );
            }
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Safety SOS',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          // View last incident status
          Obx(() {
            if (controller.currentIncident.value != null) {
              return IconButton(
                icon: Icon(Icons.info_outline, size: 22.w, color: AppColors.primary),
                tooltip: 'View SOS Status',
                onPressed: () => Get.to(() => const SosIncidentStatusScreen()),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Feature Status Card ──────────────────────────────────────
            _FeatureStatusCard(controller: controller),
            SizedBox(height: 20.h),

            // ── Emergency Contacts ───────────────────────────────────────
            const _SectionHeader(title: 'Emergency Contacts', icon: Iconsax.people),
            SizedBox(height: 10.h),
            _EmergencyContactsList(controller: controller),
            SizedBox(height: 8.h),
            _AddContactButton(controller: controller),
            SizedBox(height: 24.h),

            // ── Shake Detection Settings ─────────────────────────────────
            const _SectionHeader(title: 'Shake Detection', icon: Iconsax.mobile),
            SizedBox(height: 10.h),
            _ShakeSettingsCard(controller: controller),
            SizedBox(height: 24.h),

            // ── Manual SOS Button ────────────────────────────────────────
            _ManualSosButton(controller: controller),
            SizedBox(height: 24.h),

            // ── Limitation notice ────────────────────────────────────────
            _LimitationCard(),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Status Card ─────────────────────────────────────────────────────

class _FeatureStatusCard extends StatelessWidget {
  final SafetySosController controller;
  const _FeatureStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.isFeatureActive.value;
      final reqId = controller.activeRequestId.value;

      final bgColor = active ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9);
      final borderColor = active ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0);
      final iconColor = active ? const Color(0xFF059669) : AppColors.textHint;
      final icon = active ? Icons.shield : Icons.shield_outlined;
      final label = active ? 'Safety Active' : 'Waiting for Mechanic';
      final subtitle = active
          ? 'Shake detection available. Request: ${reqId?.substring(0, 8) ?? ''}'
          : 'Safety SOS will activate once a mechanic accepts your request.';

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26.w, color: iconColor,
                  semanticLabel: active ? 'Safety active' : 'Safety inactive'),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Emergency Contacts List ─────────────────────────────────────────────────

class _EmergencyContactsList extends StatelessWidget {
  final SafetySosController controller;
  const _EmergencyContactsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingContacts.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      final contacts = controller.contacts;

      if (contacts.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.user_add, size: 36.w, color: AppColors.textHint),
                SizedBox(height: 10.h),
                Text(
                  'No emergency contacts yet.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add at least one contact to enable SOS alerts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: contacts
            .map((c) => _ContactTile(contact: c, controller: controller))
            .toList(),
      );
    });
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final SafetySosController controller;
  const _ContactTile({required this.contact, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  contact.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Enable toggle
          Switch(
            value: contact.isEnabled,
            onChanged: (v) => controller.toggleContact(contact.id, v),
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          // Edit
          IconButton(
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
            icon: Icon(Iconsax.edit, size: 18.w, color: AppColors.textSecondary),
            onPressed: () => _showEditDialog(context, contact, controller),
            tooltip: 'Edit contact',
          ),
          SizedBox(width: 4.w),
          // Delete
          IconButton(
            padding: EdgeInsets.all(4.w),
            constraints: const BoxConstraints(),
            icon: Icon(Iconsax.trash, size: 18.w, color: AppColors.error),
            onPressed: () => _confirmDelete(context, contact, controller),
            tooltip: 'Delete contact',
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    EmergencyContact contact,
    SafetySosController controller,
  ) {
    _ContactFormDialog.show(
      context,
      initialName: contact.name,
      initialPhone: contact.phone,
      title: 'Edit Contact',
      onSave: (name, phone) async {
        await controller.updateContact(contact.copyWith(name: name, phone: phone));
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    EmergencyContact contact,
    SafetySosController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Delete Contact?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        content: Text(
          'Remove ${contact.name} from your emergency contacts?',
          style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteContact(contact.id);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Add Contact Button ───────────────────────────────────────────────────────

class _AddContactButton extends StatelessWidget {
  final SafetySosController controller;
  const _AddContactButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () => _ContactFormDialog.show(
          context,
          title: 'Add Emergency Contact',
          onSave: (name, phone) async {
            await controller.addContact(name: name, phone: phone);
          },
        ),
        icon: Icon(Iconsax.add, size: 18.w, color: AppColors.primary),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Add Emergency Contact',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }
}

// ─── Shake Settings Card ──────────────────────────────────────────────────────

class _ShakeSettingsCard extends StatelessWidget {
  final SafetySosController controller;
  const _ShakeSettingsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Shake Detection',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Shake your phone 3 times quickly to trigger SOS',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isShakeEnabled.value,
                  onChanged: (v) {
                    if (v && !controller.isFeatureActive.value) {
                      AppSnackbar.warning(
                        'Shake detection activates once a mechanic accepts your request.',
                        title: 'Not Yet Active',
                      );
                    }
                    controller.setShakeEnabled(v);
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
          Obx(() {
            final listening = controller.isShakeEnabled.value && controller.isFeatureActive.value;
            final mag = controller.currentMagnitude.value;
            return Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: listening ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: listening ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: listening ? const Color(0xFF10B981) : AppColors.textHint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          listening
                              ? 'Shake sensor active (foreground motion detection)'
                              : 'Sensor idle — armed once roadside mechanic accepts',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: listening ? const Color(0xFF065F46) : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (listening) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'Live Motion: ',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF047857),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: (mag / 20.0).clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFFD1FAE5),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                              minHeight: 6.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${mag.toStringAsFixed(1)} m/s²',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.triggerManualSos(),
              icon: const Icon(Iconsax.radar_2, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Test 5-Second Countdown & Cancel Flow',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Manual SOS Button ────────────────────────────────────────────────────────

class _ManualSosButton extends StatelessWidget {
  final SafetySosController controller;
  const _ManualSosButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manual SOS',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Can\'t shake the phone? Tap the button below to trigger SOS manually.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final active = controller.isFeatureActive.value;
          final dispatching = controller.isDispatching.value;
          return SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: (active && !dispatching)
                  ? () => _confirmManualSos(context, controller)
                  : null,
              icon: Icon(Icons.sos, size: 22.w),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  dispatching ? 'Sending SOS…' : 'Trigger Manual SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFFCA5A5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _confirmManualSos(BuildContext context, SafetySosController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          '⚠️ Trigger Emergency SOS?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        content: Text(
          'This will start a 5-second countdown before sending emergency alerts to your contacts. You can cancel within 5 seconds.',
          style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.triggerManualSos();
            },
            child: Text('Trigger SOS', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Limitation Notice ────────────────────────────────────────────────────────

class _LimitationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16.w, color: AppColors.textHint),
              SizedBox(width: 8.w),
              Text(
                'Important Limitations',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _bullet('Shake detection works in foreground only. Locking the screen or backgrounding the app may stop detection.'),
          _bullet('Messages are opened in WhatsApp or SMS. You must press Send — DriveResQ cannot send automatically without a server-side SMS provider.'),
          _bullet('An accepted mechanic request does NOT automatically notify emergency contacts.'),
          _bullet('Add at least one enabled contact before triggering SOS.'),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textHint)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Form Dialog ──────────────────────────────────────────────────────

class _ContactFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String title;
  final Future<void> Function(String name, String phone) onSave;

  const _ContactFormDialog({
    this.initialName,
    this.initialPhone,
    required this.title,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    String? initialName,
    String? initialPhone,
    required String title,
    required Future<void> Function(String name, String phone) onSave,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _ContactFormDialog(
        initialName: initialName,
        initialPhone: initialPhone,
        title: title,
        onSave: onSave,
      ),
    );
  }

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Please fill in both name and phone number.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(name, phone);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Iconsax.user, size: 18.w),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: 'Phone (e.g. +919876543210)',
                prefixIcon: Icon(Iconsax.call, size: 18.w),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 8.h),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.error),
              ),
            ],
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
