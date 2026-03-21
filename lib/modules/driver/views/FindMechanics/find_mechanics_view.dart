import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/favorites_controller.dart';
import '../../controllers/find_mechanics_controller.dart';
import 'widgets/mechanic_card_widget.dart';
import 'widgets/mechanic_filter_bottom_sheet.dart';
import 'mechanics_map_view.dart';

class FindMechanicsView extends StatelessWidget {
  FindMechanicsView({super.key}) {
    // Ensure controllers are registered
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }
    if (!Get.isRegistered<FindMechanicsController>()) {
      Get.put(FindMechanicsController());
    }
  }

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FindMechanicsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Find Mechanics",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
            onPressed: () {
              // Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.black87),
            onPressed: () {
              Get.bottomSheet(
                MechanicFilterBottomSheet(controller: controller),
                isScrollControlled: true,
              );
            },
          ),
          Obx(() => IconButton(
                icon: Icon(
                  controller.isListView.value ? Icons.map_rounded : Icons.list_rounded,
                  color: _accent,
                ),
                onPressed: controller.toggleView,
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header (Location, Search, Chips)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: _accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => Text(
                              "Your Location: ${controller.locationName.value}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      TextButton(
                        onPressed: () {
                          // Change location functionality
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Change",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search mechanics, services, areas...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  controller.searchQuery.value = '';
                                  // Hack to clear the textfield UI without losing cursor:
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : const SizedBox.shrink()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Service Filters
                  SizedBox(
                    height: 36,
                    child: Obx(() {
                      final currentSelected = controller.selectedService.value;
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: controller.availableServices.map((service) {
                          final isSelected = currentSelected == service;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(service),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) controller.selectedService.value = service;
                              },
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                              selectedColor: _accent,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? _accent : Colors.grey.shade300,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Content Wrapper
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                // Return a loading spinner (Replace with shimmer later)
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: CircularProgressIndicator(color: _accent)),
                );
              }

              if (!controller.isListView.value) {
                // Show Map View
                return Container(
                  height: 500,
                  margin: const EdgeInsets.only(top: 16),
                  child: const MechanicsMapView(),
                );
              }

              final mechanics = controller.filteredMechanics;

              if (mechanics.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      "All Mechanics Nearby (${mechanics.length} found)",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mechanics.length,
                    itemBuilder: (context, index) {
                      return MechanicCardWidget(mechanic: mechanics[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No Mechanics Found",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters, searching for a different service, or increasing distance criteria.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
