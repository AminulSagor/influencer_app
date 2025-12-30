import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/app_assets.dart';

import '../../create_campaign_controller/create_campaign_controller.dart';

class BrandAssetsBlock extends StatelessWidget {
  final CreateCampaignController controller;
  const BrandAssetsBlock({super.key, required this.controller});

  static const _primary = Color(0xFF2F4F1F);
  static const _softBorder = Color(0xFFBFD7A5);
  static const _softBg = Color(0xFFF7FAF3);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final list = c.brandAssets.toList(growable: false);

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
        children: List.generate(list.length, (i) {
          final b = list[i];
          final subtitle = (b.value ?? '').trim().isNotEmpty
              ? b.value!.trim()
              : 'create_campaign_brand_asset_value_hint'.tr;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => c.openEditBrandAssetDialog(i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _softBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _softBorder),
                ),
                child: Row(
                  children: [

                    Image.asset(AppAssets.facebook,height: 30, width: 30 ),

                    12.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
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
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _primary.withOpacity(.55),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    10.w.horizontalSpace,
                    
                    InkWell(
                      onTap: () {
                        if (i >= 0 && i < c.brandAssets.length) {
                          c.brandAssets.removeAt(i);
                        }
                      },
                      child: Image.asset(AppAssets.close, height: 18, width: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}