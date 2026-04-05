import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/job_completion_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';

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
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.surface : AppColors.textSecondary,
                    ),
                  ),
                  onSelected: (_) => c.toggleService(s),
                  selectedColor: AppColors.success,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.surface,
                  side: BorderSide(color: selected ? AppColors.success : AppColors.border),
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
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
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
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
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
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Obx(
              () => CheckboxListTile(
                value: c.cashCollected.value,
                onChanged: (v) => c.cashCollected.value = v ?? false,
                title: Text(
                  'Cash collected from driver',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Or settle via UPI/cash directly with the driver',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                activeColor: AppColors.success,
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
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Continue to Rating',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Summary',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.surface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'ID: ${c.jobId.value.length >= 8 ? c.jobId.value.substring(0, 8).toUpperCase() : c.jobId.value.toUpperCase()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surface,
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
          Icon(icon, size: 16.w, color: AppColors.surface.withOpacity(0.7)),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(color: AppColors.surface.withOpacity(0.7)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.surface,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                  decoration: _inputDecor('Part name'),
                  onChanged: (v) => c.updatePart(i, 'name', v),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 50.w,
                child: TextField(
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                  decoration: _inputDecor('₹ Cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      c.updatePart(i, 'costPerUnit', double.tryParse(v) ?? 0.0),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.minus, color: AppColors.error, size: 22.w),
                onPressed: () => c.removePart(i),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => Text(
                'Total: ₹${(c.partsReplaced[i]['total'] as double? ?? 0).toStringAsFixed(0)}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
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
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.close_square,
                        color: AppColors.surface,
                        size: 14.w,
                      ),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Iconsax.camera,
                color: AppColors.textHint,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 14.h),
            _costRow('Base Service Charge', c.baseCharge.value),
            _costRow('Labor Charges', c.laborCharges.value),
            _costRow('Parts Cost', c.partsTotal.value),
            _costRow('Travel Cost', c.travelCost.value),
            Divider(color: AppColors.border, height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '₹${c.totalAmount.value.toStringAsFixed(0)}',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.success,
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
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.body2.copyWith(
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
        Icon(icon, size: 20.w, color: AppColors.success),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
      style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
        prefixText: '₹ ',
        prefixStyle: AppTextStyles.body2.copyWith(
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.success, width: 2),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textHint,
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }
}
