import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class JobSummaryView extends StatelessWidget {
  const JobSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Info Card
          _jobInfoCard(c),
          SizedBox(height: 20.h),

          // Services Performed
          _sectionTitle('Services Performed', Iconsax.setting_2),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JobCompletionController.serviceOptions.map((s) {
                final selected = c.selectedServices.contains(s);
                return FilterChip(
                  selected: selected,
                  label: Text(
                    s,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  onSelected: (_) => c.toggleService(s),
                  selectedColor: Color(0xFF4CAF50),
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 24.h),

          // Parts Replaced
          _sectionTitle('Parts Replaced (Optional)', Iconsax.setting_2),
          SizedBox(height: 12.h),
          Obx(
            () => Column(
              children: [
                ...List.generate(c.partsReplaced.length, (i) => _partRow(c, i)),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () => c.addPart(),
                  icon: Icon(Iconsax.add, size: 18.w),
                  label: Text(
                    'Add Part',
                    style: GoogleFonts.poppins(fontSize: 13.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF4CAF50),
                    side: BorderSide(color: Color(0xFF4CAF50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Labor Charges
          _sectionTitle('Labor Charges', Iconsax.setting_2),
          SizedBox(height: 12.h),
          _currencyField(
            c.laborChargesController,
            'Enter labor charges',
            onChanged: (v) => c.updateLaborCharges(v),
          ),

          SizedBox(height: 24.h),

          // Notes
          _sectionTitle('Additional Notes', Iconsax.document_text),
          SizedBox(height: 12.h),
          TextField(
            controller: c.notesController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
            decoration: _inputDecor('Describe the work done...'),
          ),

          SizedBox(height: 24.h),

          // Photos
          _sectionTitle('Before Photos', Iconsax.camera),
          SizedBox(height: 8.h),
          _photoGrid(c, true),

          SizedBox(height: 16.h),
          _sectionTitle('After Photos', Iconsax.camera),
          SizedBox(height: 8.h),
          _photoGrid(c, false),

          SizedBox(height: 28.h),

          // Cost Breakdown
          _costBreakdown(c),

          SizedBox(height: 24.h),

          // Cash Collected Confirmation
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Obx(
              () => CheckboxListTile(
                value: c.cashCollected.value,
                onChanged: (v) => c.cashCollected.value = v ?? false,
                title: Text(
                  'Cash collected from driver',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Or settle via UPI/cash directly with the driver',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                activeColor: const Color(0xFF4CAF50),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => c.nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Continue to Rating',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _jobInfoCard(JobCompletionController c) {
    final job = c.jobData.value ?? {};
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Summary',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'ID: ${c.jobId.value.length >= 8 ? c.jobId.value.substring(0, 8).toUpperCase() : c.jobId.value.toUpperCase()}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _infoRow(Iconsax.car, 'Vehicle', job['vehicleType'] ?? '—'),
          _infoRow(Iconsax.warning_2, 'Problem', job['problem'] ?? '—'),
          _infoRow(Iconsax.location, 'Location', job['locationName'] ?? '—'),
          _infoRow(Iconsax.timer, 'Duration', c.formattedDuration),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: Colors.white70),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partRow(JobCompletionController c, int i) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
                  decoration: _inputDecor('Part name'),
                  onChanged: (v) => c.updatePart(i, 'name', v),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 50.w,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
                  decoration: _inputDecor('Qty'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      c.updatePart(i, 'quantity', int.tryParse(v) ?? 1),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 80.w,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
                  decoration: _inputDecor('₹ Cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      c.updatePart(i, 'costPerUnit', double.tryParse(v) ?? 0.0),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.minus, color: Colors.red, size: 22.w),
                onPressed: () => c.removePart(i),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => Text(
                'Total: ₹${(c.partsReplaced[i]['total'] as double? ?? 0).toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoGrid(JobCompletionController c, bool isBefore) {
    return Obx(() {
      final photos = isBefore ? c.beforePhotos : c.afterPhotos;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...List.generate(
            photos.length,
            (i) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    photos[i],
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => c.removePhoto(isBefore, i),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.close_square, color: Colors.white, size: 14.w),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => c.pickPhotos(isBefore),
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Iconsax.camera,
                color: Colors.grey.shade400,
                size: 28.w,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _costBreakdown(JobCompletionController c) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 14.h),
            _costRow('Base Service Charge', c.baseCharge.value),
            _costRow('Labor Charges', c.laborCharges.value),
            _costRow('Parts Cost', c.partsTotal.value),
            _costRow('Travel Cost', c.travelCost.value),
            Divider(color: Colors.grey.shade300, height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${c.totalAmount.value.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _costRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: Color(0xFF4CAF50)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _currencyField(
    TextEditingController controller,
    String hint, {
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        prefixText: '₹ ',
        prefixStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        filled: false,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade400,
        fontSize: 12.sp,
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
