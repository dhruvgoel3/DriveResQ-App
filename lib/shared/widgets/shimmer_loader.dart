import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Shimmer loading skeleton that shows placeholder cards while data loads.
/// Use instead of CircularProgressIndicator for better UX.
class ShimmerLoader extends StatelessWidget {
  final int itemCount;
  final ShimmerCardType cardType;

  ShimmerLoader({
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
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(48, 48, isCircle: true),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 14),
                    SizedBox(height: 8.h),
                    _box(80, 10),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _box(double.infinity, 12),
          SizedBox(height: 8.h),
          _box(200, 12),
        ],
      ),
    );
  }

  Widget _requestCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _box(40, 40, isCircle: true),
              SizedBox(width: 12.w),
              Expanded(child: _box(140, 16)),
              _box(60, 24, radius: 12.r),
            ],
          ),
          SizedBox(height: 16.h),
          _box(double.infinity, 1), // divider
          SizedBox(height: 16.h),
          // Info rows
          _box(double.infinity, 14),
          SizedBox(height: 10.h),
          _box(200, 14),
          SizedBox(height: 10.h),
          _box(160, 14),
          SizedBox(height: 16.h),
          // Button
          _box(double.infinity, 48, radius: 14.r),
        ],
      ),
    );
  }

  Widget _chatCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _box(52, 52, isCircle: true),
          SizedBox(width: 14.w),
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
                SizedBox(height: 8.h),
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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _box(80, 80, isCircle: true),
          SizedBox(height: 16.h),
          _box(150, 18),
          SizedBox(height: 8.h),
          _box(100, 12),
          SizedBox(height: 20.h),
          _box(double.infinity, 14),
          SizedBox(height: 10.h),
          _box(double.infinity, 14),
          SizedBox(height: 10.h),
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
