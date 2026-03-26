import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../brand_campaign_details_controller.dart';

typedef SubmitBrandAsset =
    Future<void> Function({required String title, required String url});

class UploadAnotherBrandAssetDialog extends StatefulWidget {
  const UploadAnotherBrandAssetDialog({
    super.key,
    required this.brandAssets,
    required this.onSubmit,
  });

  final RxList<BrandAssetLink> brandAssets;
  final SubmitBrandAsset onSubmit;

  static Future<void> show({
    required RxList<BrandAssetLink> brandAssets,
    required SubmitBrandAsset onSubmit,
  }) {
    return Get.dialog(
      UploadAnotherBrandAssetDialog(
        brandAssets: brandAssets,
        onSubmit: onSubmit,
      ),
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
  final isSubmitting = false.obs;

  @override
  void dispose() {
    titleCtrl.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = titleCtrl.text.trim();
    final u = urlCtrl.text.trim();

    if (t.isEmpty) {
      Get.snackbar('Error', 'Please enter asset title.');
      return;
    }

    if (u.isEmpty) {
      Get.snackbar('Error', 'Please enter asset url.');
      return;
    }

    try {
      isSubmitting.value = true;
      await widget.onSubmit(title: t, url: u);
      if (mounted) {
        Get.back();
      }
    } finally {
      isSubmitting.value = false;
    }
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
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: isSubmitting.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: primary.withOpacity(.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting.value
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('common_done'.tr),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
