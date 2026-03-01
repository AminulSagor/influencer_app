import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../brand_campaign_details_controller.dart';

class UploadAnotherBrandAssetDialog extends StatefulWidget {
  const UploadAnotherBrandAssetDialog({super.key, required this.brandAssets});

  final RxList<BrandAssetLink> brandAssets;

  static Future<void> show({required RxList<BrandAssetLink> brandAssets}) {
    return Get.dialog(
      UploadAnotherBrandAssetDialog(brandAssets: brandAssets),
      barrierDismissible: false,
    );
  }

  @override
  State<UploadAnotherBrandAssetDialog> createState() =>
      _UploadAnotherBrandAssetDialogState();
}

class _UploadAnotherBrandAssetDialogState
    extends State<UploadAnotherBrandAssetDialog> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController urlCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  static const primary = Color(0xFF2F4F1F);
  static const bg = Color(0xFFF6F7F7);
  static const softBorder = Color(0xFFBFD7A5);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'brand_campaign_details_upload_another_brand_asset'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999.r),
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: primary.withOpacity(.6),
                    ),
                  ),
                ),
              ],
            ),
            14.h.verticalSpace,
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: 'create_campaign_brand_asset_name_hint'.tr,
                filled: true,
                fillColor: bg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: softBorder, width: 1.4),
                ),
              ),
            ),
            10.h.verticalSpace,
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(
                hintText: 'create_campaign_brand_asset_value_hint'.tr,
                filled: true,
                fillColor: bg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: softBorder, width: 1.4),
                ),
              ),
            ),
            14.h.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('skills_cancel'.tr),
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final t = titleCtrl.text.trim();
                      final u = urlCtrl.text.trim();
                      if (t.isEmpty) return;

                      widget.brandAssets.add(
                        BrandAssetLink(
                          title: t,
                          subtitle: 'Page Link',
                          icon: Icons.link_rounded,
                          url: u.isEmpty ? null : u,
                        ),
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      backgroundColor: primary.withOpacity(.75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text('common_done'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
