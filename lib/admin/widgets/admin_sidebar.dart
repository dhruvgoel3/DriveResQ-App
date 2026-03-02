import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_auth_controller.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  const AdminSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AdminAuthController>();
    final dashC = Get.find<AdminDashboardController>();

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D23),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Logo / Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DriveResQ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2D3039), height: 1),
          const SizedBox(height: 8),

          // Menu Items
          _menuItem(Icons.dashboard_rounded, 'Dashboard', '/admin/dashboard'),
          Obx(
            () => _menuItem(
              Icons.pending_actions,
              'Pending Verifications',
              '/admin/pending',
              badge: dashC.pendingCount.value,
            ),
          ),
          _menuItem(
            Icons.check_circle_outline,
            'Approved Mechanics',
            '/admin/approved',
          ),
          _menuItem(
            Icons.cancel_outlined,
            'Rejected Applications',
            '/admin/rejected',
          ),

          const Spacer(),

          // Admin info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3039),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFF9800),
                  child: Text(
                    authC.adminName.value.isNotEmpty
                        ? authC.adminName.value[0].toUpperCase()
                        : 'A',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authC.adminName.value.isNotEmpty
                            ? authC.adminName.value
                            : 'Admin',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        authC.adminEmail.value,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logout
          _menuItem(Icons.logout, 'Logout', 'logout'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, String route, {int badge = 0}) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (route == 'logout') {
              Get.find<AdminAuthController>().logout();
            } else if (route != currentRoute) {
              Get.offAllNamed(route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF9800).withOpacity(0.15)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? const Color(0xFFFF9800)
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? const Color(0xFFFF9800)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badge',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
