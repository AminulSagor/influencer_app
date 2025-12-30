import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../create_campaign_controller/create_campaign_controller.dart';

class ContentAssetsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const ContentAssetsBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final list = c.contentAssets.toList(growable: false);

      if (list.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '-',
            style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
          ),
        );
      }

      return Column(
        children: list.map((a) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _softBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _softBorder),
              ),
              child: Row(
                children: [

                  Image.asset(c.iconForAsset(a.kind), height: 25, width: 25),
                  // Icon(
                  //   c.iconForAsset(a.kind),
                  //   color: _primary.withOpacity(.75),
                  //   size: 24.sp,
                  // ),

                  12.w.horizontalSpace,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.secondary,
                          ),
                        ),

                        2.h.verticalSpace,

                        Text(
                          a.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppPalette.primary.withOpacity(.55),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  10.w.horizontalSpace,

                  Image.asset(AppAssets.download, color: AppPalette.secondary, height: 23, width: 23),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}