import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'review_helpers.dart';

class DocumentsTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;

  const DocumentsTab({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aadhaar
          ReviewHelpers.buildCard([
            Text(
              'Aadhaar Card',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ReviewHelpers.buildField(
              'Aadhaar Number',
              mechanicData['aadhaarNumber'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((mechanicData['aadhaarFrontUrl'] ?? '').isNotEmpty)
                  Expanded(
                    child: _docImage('Front', mechanicData['aadhaarFrontUrl']),
                  ),
                const SizedBox(width: 16),
                if ((mechanicData['aadhaarBackUrl'] ?? '').isNotEmpty)
                  Expanded(
                    child: _docImage('Back', mechanicData['aadhaarBackUrl']),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 20),

          // PAN
          if ((mechanicData['panCardUrl'] ?? '').isNotEmpty)
            ReviewHelpers.buildCard([
              Text(
                'PAN Card',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _docImage('PAN Card', mechanicData['panCardUrl']),
            ]),

          if ((mechanicData['tradeLicenseUrl'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 20),
            ReviewHelpers.buildCard([
              Text(
                'Trade License',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _docImage('Trade License', mechanicData['tradeLicenseUrl']),
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
}
