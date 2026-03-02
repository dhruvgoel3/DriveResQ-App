import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step2_professional_details.dart';

class Step1PersonalDetails extends StatelessWidget {
  const Step1PersonalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MechanicOnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(c),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildProfilePhoto(c),
                    const SizedBox(height: 28),
                    _buildFullName(c),
                    const SizedBox(height: 20),
                    _buildDobPicker(c, context),
                    const SizedBox(height: 20),
                    _buildGenderPicker(c),
                    const SizedBox(height: 20),
                    _buildEmail(c),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildContinueButton(c),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Mechanic Registration',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressBar(MechanicOnboardingController c) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${c.currentStep.value} of 6',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Personal Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: c.currentStep.value / 6,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF9800),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tell us about yourself to set up your profile',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(MechanicOnboardingController c) {
    return Center(
      child: Obx(() {
        return GestureDetector(
          onTap: () => c.pickImage(c.profilePhoto),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    width: 3,
                  ),
                  image: c.profilePhoto.value != null
                      ? DecorationImage(
                          image: FileImage(c.profilePhoto.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: c.profilePhoto.value == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFFFF9800),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9800),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFullName(MechanicOnboardingController c) {
    return _inputField(
      controller: c.nameController,
      label: 'Full Name *',
      hint: 'Enter your full name',
      icon: Icons.person_outline,
    );
  }

  Widget _buildDobPicker(MechanicOnboardingController c, BuildContext context) {
    return Obx(() {
      final hasDate = c.dob.value != null;
      return GestureDetector(
        onTap: () => c.pickDob(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(0xFFFF9800),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  hasDate
                      ? '${c.dob.value!.day}/${c.dob.value!.month}/${c.dob.value!.year}'
                      : 'Date of Birth *',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: hasDate ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGenderPicker(MechanicOnboardingController c) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.wc, color: Color(0xFFFF9800), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: c.gender.value.isEmpty ? null : c.gender.value,
                  hint: Text(
                    'Gender *',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => c.gender.value = v ?? '',
                  isExpanded: true,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmail(MechanicOnboardingController c) {
    return _inputField(
      controller: c.emailController,
      label: 'Email (Optional)',
      hint: 'Enter your email address',
      icon: Icons.email_outlined,
      type: TextInputType.emailAddress,
    );
  }

  Widget _buildContinueButton(MechanicOnboardingController c) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            c.nextStep();
            if (c.currentStep.value == 2) {
              Get.to(() => const Step2ProfessionalDetails());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
