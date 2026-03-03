import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';

class JobSummaryView extends StatelessWidget {
  const JobSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Info Card
          _jobInfoCard(c),
          const SizedBox(height: 20),

          // Services Performed
          _sectionTitle('Services Performed', Icons.build_circle),
          const SizedBox(height: 12),
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
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  onSelected: (_) => c.toggleService(s),
                  selectedColor: const Color(0xFF4CAF50),
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Parts Replaced
          _sectionTitle('Parts Replaced (Optional)', Icons.settings),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: [
                ...List.generate(c.partsReplaced.length, (i) => _partRow(c, i)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => c.addPart(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add Part',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Labor Charges
          _sectionTitle('Labor Charges', Icons.engineering),
          const SizedBox(height: 12),
          _currencyField(
            c.laborChargesController,
            'Enter labor charges',
            onChanged: (v) => c.updateLaborCharges(v),
          ),

          const SizedBox(height: 24),

          // Notes
          _sectionTitle('Additional Notes', Icons.notes),
          const SizedBox(height: 12),
          TextField(
            controller: c.notesController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _inputDecor('Describe the work done...'),
          ),

          const SizedBox(height: 24),

          // Photos
          _sectionTitle('Before Photos', Icons.camera_alt),
          const SizedBox(height: 8),
          _photoGrid(c, true),

          const SizedBox(height: 16),
          _sectionTitle('After Photos', Icons.camera_alt_outlined),
          const SizedBox(height: 8),
          _photoGrid(c, false),

          const SizedBox(height: 28),

          // Cost Breakdown
          _costBreakdown(c),

          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => c.nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue to Payment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _jobInfoCard(JobCompletionController c) {
    final job = c.jobData.value ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${c.jobId.value.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.directions_car, 'Vehicle', job['vehicleType'] ?? '—'),
          _infoRow(Icons.warning_rounded, 'Problem', job['problem'] ?? '—'),
          _infoRow(Icons.location_on, 'Location', job['locationName'] ?? '—'),
          _infoRow(Icons.timer, 'Duration', c.formattedDuration),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: _inputDecor('Part name'),
                  onChanged: (v) => c.updatePart(i, 'name', v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: _inputDecor('Qty'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      c.updatePart(i, 'quantity', int.tryParse(v) ?? 1),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: _inputDecor('₹ Cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      c.updatePart(i, 'costPerUnit', double.tryParse(v) ?? 0.0),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 22,
                ),
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
                  fontSize: 12,
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
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    photos[i],
                    width: 80,
                    height: 80,
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
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add_a_photo,
                color: Colors.grey.shade400,
                size: 28,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            _costRow('Base Service Charge', c.baseCharge.value),
            _costRow('Labor Charges', c.laborCharges.value),
            _costRow('Parts Cost', c.partsTotal.value),
            _costRow('Travel Cost', c.travelCost.value),
            Divider(color: Colors.grey.shade300, height: 24),
            _costRow('Subtotal', c.subtotal.value),
            _costRow('GST (18%)', c.gstAmount.value),
            Divider(color: Colors.grey.shade300, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${c.totalAmount.value.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
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
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
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
      style: GoogleFonts.poppins(fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        prefixText: '₹ ',
        prefixStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
