import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stat_card.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/admin/dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back! Here\'s an overview of mechanic and driver verifications.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stat cards
                  Obx(
                    () => Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.people,
                            label: 'Total Mechanics',
                            value: '${c.totalMechanics.value}',
                            color: Colors.blue.shade700,
                            bgColor: Colors.blue.shade50,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.driver,
                            label: 'Total Drivers',
                            value: '${c.totalDrivers.value}',
                            color: Colors.indigo.shade700,
                            bgColor: Colors.indigo.shade50,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.user_tick,
                            label: 'Mechanic Pendings',
                            value: '${c.pendingMechanicsCount.value}',
                            color: Colors.orange.shade700,
                            bgColor: Colors.orange.shade50,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.driver,
                            label: 'Driver Pendings',
                            value: '${c.pendingDriversCount.value}',
                            color: Colors.amber.shade700,
                            bgColor: Colors.amber.shade50,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.tick_circle,
                            label: 'Approved Today',
                            value: '${c.approvedToday.value}',
                            color: Colors.green.shade700,
                            bgColor: Colors.green.shade50,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: StatCard(
                            icon: Iconsax.close_square,
                            label: 'Rejected Today',
                            value: '${c.rejectedToday.value}',
                            color: Colors.red.shade700,
                            bgColor: Colors.red.shade50,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Get.offAllNamed('/admin/pending'),
                        icon: const Icon(Iconsax.user_tick, size: 18),
                        label: Text(
                          'Mechanic Applications',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Get.offAllNamed('/admin/drivers-pending'),
                        icon: const Icon(Iconsax.driver, size: 18),
                        label: Text(
                          'Driver Applications',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => c.fetchStats(),
                        icon: const Icon(Iconsax.refresh, size: 18),
                        label: Text(
                          'Refresh Stats',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    if (c.recentActions.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No activity yet',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: c.recentActions.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade100, height: 1),
                        itemBuilder: (_, i) {
                          final action = c.recentActions[i];
                          final isApproval = action['action'] == 'approved';
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: isApproval
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              child: Icon(
                                isApproval
                                    ? Iconsax.tick_circle
                                    : Iconsax.close_square,
                                size: 18,
                                color: isApproval ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              '${isApproval ? "Approved" : "Rejected"} ${action['mechanicName'] ?? action['driverName'] ?? 'Unknown'}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'by ${action['adminEmail'] ?? 'admin'}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            trailing: Text(
                              _formatTime(action['timestamp']),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final date = (ts as dynamic).toDate();
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
