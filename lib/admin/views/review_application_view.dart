import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/verification_controller.dart';

class ReviewApplicationView extends StatefulWidget {
  const ReviewApplicationView({super.key});

  @override
  State<ReviewApplicationView> createState() => _ReviewApplicationViewState();
}

class _ReviewApplicationViewState extends State<ReviewApplicationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VerificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        final m = c.selectedMechanic.value;
        if (m == null || c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        return Row(
          children: [
            // Left back panel
            Container(
              width: 60,
              color: const Color(0xFF1A1D23),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top header
                  _buildHeader(m),
                  // Tab bar
                  _buildTabBar(),
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _personalTab(m),
                        _professionalTab(m),
                        _documentsTab(m),
                        _bankTab(m),
                        _availabilityTab(m),
                        _reviewTab(m, c),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> m) {
    final name = m['fullName'] ?? 'Unknown';
    final phone = m['phone'] ?? '';
    final email = m['email'] ?? '';
    final photo = m['profilePhotoUrl'] ?? '';
    final c = Get.find<VerificationController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
            backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty
                ? Text(
                    name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9800),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      Icon(Iconsax.call, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (email.isNotEmpty) ...[
                      Icon(Iconsax.sms, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Submitted: ${c.formatDate(m['onboardingSubmittedAt'])}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              // Always-visible Approve / Reject buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(
                      c,
                      m['uid'] ?? '',
                      m['fullName'] ?? 'Unknown',
                    ),
                    icon: const Icon(Iconsax.tick_circle, size: 18),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(
                      c,
                      m['uid'] ?? '',
                      m['fullName'] ?? 'Unknown',
                    ),
                    icon: const Icon(Iconsax.close_square, size: 18),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFFFF9800),
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: const Color(0xFFFF9800),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Professional'),
          Tab(text: 'Documents'),
          Tab(text: 'Bank Details'),
          Tab(text: 'Availability'),
          Tab(text: 'Review & Decision'),
        ],
      ),
    );
  }

  // ── TAB 1: Personal ──
  Widget _personalTab(Map<String, dynamic> m) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _card([
        _field('Full Name', m['fullName']),
        _field('Date of Birth', m['dob'] ?? 'N/A'),
        _field('Gender', m['gender']),
        _field('Email', m['email'] ?? 'Not provided'),
        if ((m['profilePhotoUrl'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Profile Photo', style: _labelStyle()),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              m['profilePhotoUrl'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ]),
    );
  }

  // ── TAB 2: Professional ──
  Widget _professionalTab(Map<String, dynamic> m) {
    final specializations =
        (m['specializations'] as List?)?.cast<String>() ?? [];
    final services = (m['servicesOffered'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _card([
        _field('Shop Name', m['shopName']),
        _field('Shop Address', m['shopAddress']),
        _field('Years of Experience', '${m['experience'] ?? 0} years'),
        const SizedBox(height: 12),
        Text('Specializations', style: _labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specializations
              .map(
                (s) => Chip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Text('Services Offered', style: _labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map(
                (s) => Chip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        if ((m['shopPhotoUrl'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Shop Photo', style: _labelStyle()),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              m['shopPhotoUrl'],
              width: 400,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ]),
    );
  }

  // ── TAB 3: Documents ──
  Widget _documentsTab(Map<String, dynamic> m) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aadhaar
          _card([
            Text(
              'Aadhaar Card',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _field('Aadhaar Number', m['aadhaarNumber'] ?? 'N/A'),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((m['aadhaarFrontUrl'] ?? '').isNotEmpty)
                  Expanded(child: _docImage('Front', m['aadhaarFrontUrl'])),
                const SizedBox(width: 16),
                if ((m['aadhaarBackUrl'] ?? '').isNotEmpty)
                  Expanded(child: _docImage('Back', m['aadhaarBackUrl'])),
              ],
            ),
          ]),
          const SizedBox(height: 20),

          // PAN
          if ((m['panCardUrl'] ?? '').isNotEmpty)
            _card([
              Text(
                'PAN Card',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _docImage('PAN Card', m['panCardUrl']),
            ]),

          if ((m['tradeLicenseUrl'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 20),
            _card([
              Text(
                'Trade License',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _docImage('Trade License', m['tradeLicenseUrl']),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _docImage(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showZoomDialog(url, label),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Iconsax.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Click to zoom',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  void _showZoomDialog(String url, String title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_square),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAB 4: Bank ──
  Widget _bankTab(Map<String, dynamic> m) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _card([
        _secureField('Account Holder', m['bankAccountHolder']),
        _secureField('Account Number', m['bankAccountNumber'], mask: true),
        _field('IFSC Code', m['bankIfsc']),
        _field('Bank Name', m['bankName']),
        _field('UPI ID', m['upiId'] ?? 'Not provided'),
      ]),
    );
  }

  // ── TAB 5: Availability ──
  Widget _availabilityTab(Map<String, dynamic> m) {
    final days = (m['availableDays'] as List?)?.cast<String>() ?? [];
    final hours = m['workingHours'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _card([
        _field(
          'Working Hours',
          '${hours['start'] ?? '?'} — ${hours['end'] ?? '?'}',
        ),
        const SizedBox(height: 12),
        Text('Available Days', style: _labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days
              .map(
                (d) => Chip(
                  label: Text(d, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _field('Service Radius', '${m['serviceRadius'] ?? 0} km'),
        _field('Base Charge', '₹${m['baseCharge'] ?? 0}'),
        _field('Per KM Charge', '₹${m['perKmCharge'] ?? 0}'),
        _field('Emergency Surcharge', '${m['emergencySurcharge'] ?? 0}%'),
      ]),
    );
  }

  // ── TAB 6: Review & Decision ──
  Widget _reviewTab(Map<String, dynamic> m, VerificationController c) {
    final uid = m['uid'] ?? '';
    final name = m['fullName'] ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Notes
          _card([
            Text(
              'Admin Notes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.adminNotesController,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add internal notes about this application...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                filled: false,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => c.saveAdminNotes(uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Notes',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Verification Checklist
          _card([
            Text(
              'Verification Checklist',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: VerificationController.verificationChecklist.map((
                  item,
                ) {
                  return CheckboxListTile(
                    value: c.checklist[item] ?? false,
                    onChanged: (v) => c.checklist[item] = v ?? false,
                    title: Text(item, style: GoogleFonts.poppins(fontSize: 13)),
                    activeColor: const Color(0xFFFF9800),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Approve
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _showApproveDialog(c, uid, name),
                  icon: const Icon(Iconsax.tick_circle, size: 22),
                  label: Text(
                    'Approve Application',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Reject
              SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectDialog(c, uid, name),
                  icon: const Icon(Iconsax.close_square, size: 22),
                  label: Text(
                    'Reject Application',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(VerificationController c, String uid, String name) {
    final welcomeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Iconsax.tick_circle, color: Color(0xFF4CAF50), size: 28),
            const SizedBox(width: 12),
            Text(
              'Approve $name?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will activate the mechanic account and they can start receiving jobs.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: welcomeController,
                maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Welcome message (optional)',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              c.approveMechanic(
                uid,
                name,
                welcomeMessage: welcomeController.text,
              );
              Get.back(); // Return to list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Approve',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(VerificationController c, String uid, String name) {
    String selectedReason = VerificationController.rejectionReasons.first;
    final notesController = TextEditingController();
    bool allowResub = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Iconsax.close_square,
                  color: Color(0xFFF44336),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Reject $name?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for rejection',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    items: VerificationController.rejectionReasons.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(
                          r,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => selectedReason = v ?? selectedReason),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Additional notes',
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: allowResub,
                    onChanged: (v) => setState(() => allowResub = v ?? true),
                    title: Text(
                      'Allow re-submission',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    activeColor: const Color(0xFFFF9800),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  c.rejectMechanic(
                    uid,
                    name,
                    reason: selectedReason,
                    notes: notesController.text,
                    allowResubmission: allowResub,
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reject',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ──
  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: _labelStyle())),
          Expanded(
            child: Text(
              '${value ?? 'N/A'}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secureField(String label, dynamic value, {bool mask = false}) {
    String display = '${value ?? 'N/A'}';
    if (mask && display.length > 4) {
      display =
          '${'•' * (display.length - 4)}${display.substring(display.length - 4)}';
    }
    return _field(label, display);
  }

  TextStyle _labelStyle() => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade500,
  );
}
