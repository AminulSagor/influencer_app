import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/custom_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius.r),
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
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
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
                      color: AppPalette.secondary,
                    ),
                  ),
                ),
              ],
            ),
            14.h.verticalSpace,
            CustomTextFormField(
              controller: titleCtrl,
              hintText: 'create_campaign_brand_asset_name_hint'.tr,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
            10.h.verticalSpace,
            CustomTextFormField(
              controller: urlCtrl,
              hintText: 'create_campaign_brand_asset_value_hint'.tr,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
            14.h.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: Get.back,
                    btnText: 'skills_cancel'.tr,
                    btnColor: AppPalette.defaultFill,
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: Obx(() {
                    return CustomButton(
                      onTap: isSubmitting.value ? null : _submit,
                      btnText: 'common_done'.tr,
                      btnColor: AppPalette.secondary,
                      textColor: AppPalette.white,
                      isLoading: isSubmitting.value,
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
