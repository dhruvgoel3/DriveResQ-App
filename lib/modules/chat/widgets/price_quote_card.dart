import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';

class PriceQuoteCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final ChatController controller;

  const PriceQuoteCard({
    super.key,
    required this.message,
    required this.isMe,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final data = message.priceData ?? {};
    final status = data['status'] ?? 'pending';
    final cost = (data['estimatedCost'] as num?)?.toDouble() ?? 0;
    final service = data['service'] ?? '';
    final time = data['estimatedTime'] ?? '';
    final notes = data['notes'] ?? '';
    final parts = (data['parts'] as List?)?.cast<String>() ?? [];
    final counterOffer = (data['counterOffer'] as num?)?.toDouble();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: EdgeInsets.only(
          left: isMe ? 40 : 12,
          right: isMe ? 12 : 40,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor(status).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 18,
                    color: _statusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Service Estimate',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                  const Spacer(),
                  _statusBadge(status),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service
                  if (service.isNotEmpty) ...[
                    Text(
                      'Service',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Cost
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Cost',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '₹${cost.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (time.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Parts
                  if (parts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Parts Needed',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: parts
                          .map(
                            (p) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p,
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  // Notes
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      notes,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Counter offer
                  if (counterOffer != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Counter: ₹${counterOffer.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action buttons (driver only, pending only)
                  if (!isMe &&
                      status == 'pending' &&
                      controller.myRole == 'driver') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              'Reject',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showNegotiateDialog(cost),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              'Negotiate',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.respondToQuote(
                              message.id,
                              'accepted',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              'Accept',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final reasonCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Decline Estimate',
      content: TextField(
        controller: reasonCtrl,
        decoration: const InputDecoration(
          hintText: 'Reason (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: 'Decline',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.respondToQuote(
          message.id,
          'rejected',
          reason: reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : null,
        );
      },
    );
  }

  void _showNegotiateDialog(double originalCost) {
    final priceCtrl = TextEditingController(
      text: originalCost.toStringAsFixed(0),
    );
    final reasonCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Counter Offer',
      content: Column(
        children: [
          Text(
            'Original: ₹${originalCost.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your price (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: 'Send',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back();
        controller.respondToQuote(
          message.id,
          'negotiated',
          counterOffer: double.tryParse(priceCtrl.text),
          reason: reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : null,
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return Colors.red;
      case 'negotiated':
        return Colors.orange;
      default:
        return const Color(0xFF6C63FF);
    }
  }

  Widget _statusBadge(String status) {
    String label;
    switch (status) {
      case 'accepted':
        label = '✅ Accepted';
        break;
      case 'rejected':
        label = '❌ Declined';
        break;
      case 'negotiated':
        label = '💬 Negotiating';
        break;
      default:
        label = '⏳ Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }
}
