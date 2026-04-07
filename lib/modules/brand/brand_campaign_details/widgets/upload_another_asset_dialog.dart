import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/models/job_item.dart';
import '../../../../core/utils/app_snackbar.dart';

typedef GuessAssetKind = JobAssetKind Function(String filename);
typedef IconForAsset = IconData Function(JobAssetKind kind);
typedef FormatBytes = String Function(int bytes);
typedef ExtUpper = String Function(String filename);
typedef FilenameNoExt = String Function(String filename);
typedef SubmitContentAsset =
    Future<void> Function({
      required String title,
      required String fileName,
      required int fileBytes,
      required String filePath,
      required JobAssetKind kind,
    });

class UploadAnotherAssetDialog extends StatefulWidget {
  const UploadAnotherAssetDialog({
    super.key,
    required this.contentAssets,
    required this.guessAssetKind,
    required this.iconForAsset,
    required this.formatBytes,
    required this.extUpper,
    required this.filenameNoExt,
    required this.onSubmit,
  });

  final RxList<JobAsset> contentAssets;
  final GuessAssetKind guessAssetKind;
  final IconForAsset iconForAsset;
  final FormatBytes formatBytes;
  final ExtUpper extUpper;
  final FilenameNoExt filenameNoExt;
  final SubmitContentAsset onSubmit;

  static Future<void> show({
    required RxList<JobAsset> contentAssets,
    required GuessAssetKind guessAssetKind,
    required IconForAsset iconForAsset,
    required FormatBytes formatBytes,
    required ExtUpper extUpper,
    required FilenameNoExt filenameNoExt,
    required SubmitContentAsset onSubmit,
  }) {
    return Get.dialog(
      UploadAnotherAssetDialog(
        contentAssets: contentAssets,
        guessAssetKind: guessAssetKind,
        iconForAsset: iconForAsset,
        formatBytes: formatBytes,
        extUpper: extUpper,
        filenameNoExt: filenameNoExt,
        onSubmit: onSubmit,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<UploadAnotherAssetDialog> createState() =>
      _UploadAnotherAssetDialogState();
}

class _UploadAnotherAssetDialogState extends State<UploadAnotherAssetDialog> {
  final TextEditingController _assetTitleCtrl = TextEditingController();

  final RxnString pickedName = RxnString();
  final RxnInt pickedBytes = RxnInt();
  final RxnString pickedPath = RxnString();
  final pickedKind = JobAssetKind.other.obs;
  final isPicking = false.obs;
  final isSubmitting = false.obs;

  @override
  void dispose() {
    _assetTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    try {
      isPicking.value = true;

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final f = result.files.single;
      pickedName.value = f.name;
      pickedBytes.value = f.size;
      pickedPath.value = f.path;
      pickedKind.value = widget.guessAssetKind(f.name);
    } finally {
      isPicking.value = false;
    }
  }

  Future<void> _submit() async {
    final name = pickedName.value;
    final bytes = pickedBytes.value;
    final filePath = pickedPath.value;

    if (name == null || bytes == null || filePath == null || filePath.isEmpty) {
      AppSnackbar.showErrorSnackbar(
        title: 'Error',
        message: 'Please select a file.',
      );
      return;
    }

    final customTitle = _assetTitleCtrl.text.trim();
    final fallbackTitle = widget.filenameNoExt(name);
    final title = customTitle.isNotEmpty ? customTitle : fallbackTitle;

    try {
      isSubmitting.value = true;

      await widget.onSubmit(
        title: title,
        fileName: name,
        fileBytes: bytes,
        filePath: filePath,
        kind: pickedKind.value,
      );

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
                    'brand_campaign_details_upload_another_asset'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
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
            CustomTextFormField(
              controller: _assetTitleCtrl,
              hintText: 'create_campaign_asset_name_hint'.tr,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
            12.h.verticalSpace,
            Obx(() {
              return CustomButton(
                onTap: isPicking.value || isSubmitting.value ? null : pickFile,
                btnText: isPicking.value
                    ? 'create_campaign_picking_file'.tr
                    : 'create_campaign_pick_file'.tr,
                width: double.infinity,
                height: 46.h,
                btnColor: AppPalette.defaultFill,
                textColor: AppPalette.primary,
                isLoading: isPicking.value,
                leading: Transform.flip(
                  flipY: true,
                  child: Image.asset(
                    'assets/icons/download.png',
                    color: AppPalette.primary,
                    width: 22.w,
                  ),
                ),
              );
            }),
            10.h.verticalSpace,
            Obx(() {
              final name = pickedName.value;
              final bytes = pickedBytes.value;

              if (name == null || bytes == null) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    'create_campaign_no_file_selected'.tr,
                    style: TextStyle(fontSize: 12.5.sp, color: Colors.black54),
                  ),
                );
              }

              final ext = widget.extUpper(name);
              final sizeText = widget.formatBytes(bytes);

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: softBorder),
                  gradient: LinearGradient(
                    colors: [
                      AppPalette.white,
                      AppPalette.white,
                      AppPalette.thirdColor,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.iconForAsset(pickedKind.value),
                      color: primary.withOpacity(.7),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
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
                            '$ext • $sizeText',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w300,
                              color: AppPalette.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
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
                    final canSave =
                        pickedName.value != null &&
                        pickedBytes.value != null &&
                        pickedPath.value != null &&
                        !isSubmitting.value;

                    return CustomButton(
                      onTap: canSave ? _submit : null,
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
