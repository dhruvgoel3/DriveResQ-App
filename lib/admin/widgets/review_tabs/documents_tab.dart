import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'review_helpers.dart';

class DocumentsTab extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DocumentsTab({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final isDriver = userData['role'] == 'driver';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Aadhaar/Identity ──
          if (isDriver)
            ReviewHelpers.buildCard([
              Text(
                'Identity Documents (${userData['govtIdType'] ?? 'ID'})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ReviewHelpers.buildField(
                'ID Number',
                userData['govtIdNumber'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if ((userData['idFrontUrl'] ?? '').isNotEmpty)
                    Expanded(
                      child: _docImage('Front Side', userData['idFrontUrl']),
                    ),
                  const SizedBox(width: 16),
                  if ((userData['idBackUrl'] ?? '').isNotEmpty)
                    Expanded(
                      child: _docImage('Back Side', userData['idBackUrl']),
                    ),
                ],
              ),
            ])
          else
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
                userData['aadhaarNumber'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if ((userData['aadhaarFrontUrl'] ?? '').isNotEmpty)
                    Expanded(
                      child: _docImage('Front', userData['aadhaarFrontUrl']),
                    ),
                  const SizedBox(width: 16),
                  if ((userData['aadhaarBackUrl'] ?? '').isNotEmpty)
                    Expanded(
                      child: _docImage('Back', userData['aadhaarBackUrl']),
                    ),
                ],
              ),
            ]),
          const SizedBox(height: 20),

          // ── PAN (Mechanic Only) ──
          if (!isDriver && (userData['panCardUrl'] ?? '').isNotEmpty)
            ReviewHelpers.buildCard([
              Text(
                'PAN Card',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _docImage('PAN Card', userData['panCardUrl']),
            ]),

          // ── Trade License (Mechanic Only) ──
          if (!isDriver && (userData['tradeLicenseUrl'] ?? '').isNotEmpty) ...[
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
              _docImage('Trade License', userData['tradeLicenseUrl']),
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
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade50,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.image, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
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
                  child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
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
