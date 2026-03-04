import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading skeleton that shows placeholder cards while data loads.
/// Use instead of CircularProgressIndicator for better UX.
class ShimmerLoader extends StatelessWidget {
  final int itemCount;
  final ShimmerCardType cardType;

  const ShimmerLoader({
    super.key,
    this.itemCount = 3,
    this.cardType = ShimmerCardType.standard,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          switch (cardType) {
            case ShimmerCardType.request:
              return _requestCard();
            case ShimmerCardType.chat:
              return _chatCard();
            case ShimmerCardType.profile:
              return _profileCard();
            default:
              return _standardCard();
          }
        },
      ),
    );
  }

  Widget _standardCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(48, 48, isCircle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 14),
                    const SizedBox(height: 8),
                    _box(80, 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _box(double.infinity, 12),
          const SizedBox(height: 8),
          _box(200, 12),
        ],
      ),
    );
  }

  Widget _requestCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _box(40, 40, isCircle: true),
              const SizedBox(width: 12),
              Expanded(child: _box(140, 16)),
              _box(60, 24, radius: 12),
            ],
          ),
          const SizedBox(height: 16),
          _box(double.infinity, 1), // divider
          const SizedBox(height: 16),
          // Info rows
          _box(double.infinity, 14),
          const SizedBox(height: 10),
          _box(200, 14),
          const SizedBox(height: 10),
          _box(160, 14),
          const SizedBox(height: 16),
          // Button
          _box(double.infinity, 48, radius: 14),
        ],
      ),
    );
  }

  Widget _chatCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _box(52, 52, isCircle: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _box(100, 14)),
                    _box(40, 10),
                  ],
                ),
                const SizedBox(height: 8),
                _box(180, 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _box(80, 80, isCircle: true),
          const SizedBox(height: 16),
          _box(150, 18),
          const SizedBox(height: 8),
          _box(100, 12),
          const SizedBox(height: 20),
          _box(double.infinity, 14),
          const SizedBox(height: 10),
          _box(double.infinity, 14),
          const SizedBox(height: 10),
          _box(double.infinity, 14),
        ],
      ),
    );
  }

  Widget _box(double w, double h, {bool isCircle = false, double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

enum ShimmerCardType { standard, request, chat, profile }
