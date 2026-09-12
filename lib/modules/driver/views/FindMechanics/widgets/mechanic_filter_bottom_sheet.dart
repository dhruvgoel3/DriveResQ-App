import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/find_mechanics_controller.dart';

class MechanicFilterBottomSheet extends StatefulWidget {
  final FindMechanicsController controller;

  const MechanicFilterBottomSheet({super.key, required this.controller});

  @override
  State<MechanicFilterBottomSheet> createState() =>
      _MechanicFilterBottomSheetState();
}

class _MechanicFilterBottomSheetState extends State<MechanicFilterBottomSheet> {
  static const _accent = Color(0xFF6C63FF);

  late double _distance;
  late double _rating;
  late bool _availableNow;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    // Copy current state
    _distance = widget.controller.maxDistanceKm.value;
    _rating = widget.controller.minimumRating.value;
    _availableNow = widget.controller.hideOffline.value;
    _sortBy = widget.controller.sortBy.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filters",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _distance = 50.0;
                    _rating = 0.0;
                    _availableNow = false;
                    _sortBy = 'Distance';
                  });
                },
                child: Text(
                  "Reset",
                  style: GoogleFonts.poppins(
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),

          // Distance Slider
          const SizedBox(height: 12),
          _buildFilterTitle("DISTANCE"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "0 km",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              Text(
                "${_distance.toInt()} km",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _accent,
                ),
              ),
              Text(
                "100 km",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Slider(
            value: _distance,
            min: 1,
            max: 100,
            activeColor: _accent,
            inactiveColor: _accent.withValues(alpha: 0.2),
            onChanged: (val) => setState(() => _distance = val),
          ),

          // Rating
          const SizedBox(height: 16),
          _buildFilterTitle("MINIMUM RATING"),
          Wrap(
            spacing: 8,
            children: [0.0, 3.0, 4.0, 4.5].map((val) {
              final isSel = _rating == val;
              return ChoiceChip(
                label: Text(val == 0.0 ? "All" : "$val+ ⭐"),
                selected: isSel,
                onSelected: (sel) {
                  if (sel) setState(() => _rating = val);
                },
                selectedColor: _accent,
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                  color: isSel ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
                side: BorderSide(color: isSel ? _accent : Colors.grey.shade300),
              );
            }).toList(),
          ),

          // Availability
          const SizedBox(height: 24),
          _buildFilterTitle("AVAILABILITY"),
          CheckboxListTile(
            title: Text(
              "Available Now (Online)",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            value: _availableNow,
            activeColor: _accent,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _availableNow = val!),
          ),

          // Sort By
          const SizedBox(height: 12),
          _buildFilterTitle("SORT BY"),
          Wrap(
            spacing: 8,
            children: ['Distance', 'Rating', 'Jobs Done'].map((val) {
              final isSel = _sortBy == val;
              return ChoiceChip(
                label: Text(val),
                selected: isSel,
                onSelected: (sel) {
                  if (sel) setState(() => _sortBy = val);
                },
                selectedColor: _accent,
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                  color: isSel ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
                side: BorderSide(color: isSel ? _accent : Colors.grey.shade300),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.controller.applyFilters(
                  maxDist: _distance,
                  minRating: _rating,
                  offline: _availableNow,
                  sort: _sortBy,
                );
                Get.back(); // Close bottom sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Apply Filters",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
