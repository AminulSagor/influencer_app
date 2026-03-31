import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerUtils {
  static Widget shimmerContainer({
    double? width,
    double? height,
    double borderRadius = 8,
    EdgeInsets? margin,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }

  static Widget profileHeaderShimmer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          shimmerContainer(width: 60.w, height: 60.w, borderRadius: 30),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerContainer(width: 150.w, height: 16.h),
                SizedBox(height: 8.h),
                shimmerContainer(width: 100.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget cardShimmer({double height = 100}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [shimmerContainer(width: double.infinity, height: height.h)],
      ),
    );
  }

  static Widget listShimmer({int itemCount = 5, double height = 80}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => cardShimmer(height: height),
    );
  }

  static Widget campaignDetailsShimmer() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shimmerContainer(
              width: double.infinity,
              height: 240.h,
              borderRadius: 14,
            ),
            12.h.verticalSpace,
            shimmerContainer(
              width: double.infinity,
              height: 330.h,
              borderRadius: 12,
            ),
            12.h.verticalSpace,
            shimmerContainer(
              width: double.infinity,
              height: 260.h,
              borderRadius: 12,
            ),
            12.h.verticalSpace,
            shimmerContainer(
              width: double.infinity,
              height: 220.h,
              borderRadius: 12,
            ),
            12.h.verticalSpace,
            shimmerContainer(
              width: double.infinity,
              height: 180.h,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  static Widget settingsShimmer() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Row(
            children: [
              shimmerContainer(width: 24.w, height: 24.w, borderRadius: 4),
              SizedBox(width: 16.w),
              shimmerContainer(width: 200.w, height: 16.h),
              const Spacer(),
              shimmerContainer(width: 20.w, height: 20.w, borderRadius: 10),
            ],
          ),
        ),
      ),
    );
  }
}
