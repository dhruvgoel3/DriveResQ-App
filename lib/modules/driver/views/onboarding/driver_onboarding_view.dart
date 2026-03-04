import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/driver_onboarding_controller.dart';

class DriverOnboardingView extends StatelessWidget {
  const DriverOnboardingView({super.key});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverOnboardingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Setup Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: Obx(
          () => c.currentStep.value > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: c.previousStep,
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Progress bar
            _progressBar(c),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: c.currentStep.value == 0
                    ? _step1PersonalDetails(c, context)
                    : _step2GovtId(c),
              ),
            ),

            // Bottom button
            _bottomButton(c),
          ],
        );
      }),
    );
  }

  Widget _progressBar(DriverOnboardingController c) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${c.currentStep.value + 1} of 2',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Text(
                c.currentStep.value == 0
                    ? 'Personal Details'
                    : 'ID Verification',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (c.currentStep.value + 1) / 2,
            backgroundColor: Colors.grey.shade200,
            color: _accent,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Personal Details ───
  Widget _step1PersonalDetails(
    DriverOnboardingController c,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('👋 Tell us about yourself'),
        const SizedBox(height: 6),
        Text(
          'This helps us personalize your experience',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),

        _inputField(
          'Full Name *',
          c.nameController,
          Icons.person,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 16),

        _inputField(
          'Email (optional)',
          c.emailController,
          Icons.email,
          hint: 'yourname@email.com',
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _inputField(
          'Address *',
          c.addressController,
          Icons.home,
          hint: 'Your home/contact address',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Gender
        Text(
          'Gender *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 10,
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = c.gender.value == g;
              return ChoiceChip(
                label: Text(
                  g,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: selected,
                selectedColor: _accent,
                backgroundColor: Colors.grey.shade100,
                onSelected: (_) => c.gender.value = g,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // DOB
        Text(
          'Date of Birth (optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: () => c.pickDob(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake, size: 20, color: _accent),
                  const SizedBox(width: 12),
                  Text(
                    c.dob.value != null
                        ? '${c.dob.value!.day}/${c.dob.value!.month}/${c.dob.value!.year}'
                        : 'Select date of birth',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: c.dob.value != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Government ID ───
  Widget _step2GovtId(DriverOnboardingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('🪪 Identity Verification'),
        const SizedBox(height: 6),
        Text(
          'Upload any one government ID to verify your identity',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),

        // ID Type selector
        Text(
          'ID Type *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: c.selectedIdType.value,
                isExpanded: true,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                items: c.idTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    c.selectedIdType.value = v ?? c.selectedIdType.value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _inputField(
          'ID Number *',
          c.idNumberController,
          Icons.credit_card,
          hint: 'Enter your ID number',
        ),
        const SizedBox(height: 20),

        // Front photo
        Text(
          'ID Front Photo *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => _photoUploader(
            path: c.idFrontPath.value,
            label: 'Upload front of your ID',
            onTap: () => c.pickIdPhoto(isFront: true),
          ),
        ),
        const SizedBox(height: 16),

        // Back photo (optional)
        Text(
          'ID Back Photo (optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => _photoUploader(
            path: c.idBackPath.value,
            label: 'Upload back of your ID',
            onTap: () => c.pickIdPhoto(isFront: false),
          ),
        ),
      ],
    );
  }

  // ─── Bottom button ───
  Widget _bottomButton(DriverOnboardingController c) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: c.isLoading.value ? null : c.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: c.isLoading.value
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    c.currentStep.value == 1 ? 'Complete Setup' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable Widgets ───
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(icon, size: 20, color: _accent),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
      ),
    );
  }

  Widget _photoUploader({
    required String path,
    required String label,
    required VoidCallback onTap,
  }) {
    final hasPhoto = path.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasPhoto ? _accent.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPhoto ? _accent.withOpacity(0.3) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: hasPhoto
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Photo selected',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(tap to change)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
