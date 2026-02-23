import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/models/job_item.dart';

typedef GuessAssetKind = JobAssetKind Function(String filename);
typedef IconForAsset = IconData Function(JobAssetKind kind);
typedef FormatBytes = String Function(int bytes);
typedef ExtUpper = String Function(String filename);
typedef FilenameNoExt = String Function(String filename);

class UploadAnotherAssetDialog extends StatefulWidget {
  const UploadAnotherAssetDialog({
    super.key,
    required this.contentAssets,
    required this.guessAssetKind,
    required this.iconForAsset,
    required this.formatBytes,
    required this.extUpper,
    required this.filenameNoExt,
  });

  final RxList<JobAsset> contentAssets;

  final GuessAssetKind guessAssetKind;
  final IconForAsset iconForAsset;

  final FormatBytes formatBytes;
  final ExtUpper extUpper;
  final FilenameNoExt filenameNoExt;

  static Future<void> show({
    required RxList<JobAsset> contentAssets,
    required GuessAssetKind guessAssetKind,
    required IconForAsset iconForAsset,
    required FormatBytes formatBytes,
    required ExtUpper extUpper,
    required FilenameNoExt filenameNoExt,
  }) {
    return Get.dialog(
      UploadAnotherAssetDialog(
        contentAssets: contentAssets,
        guessAssetKind: guessAssetKind,
        iconForAsset: iconForAsset,
        formatBytes: formatBytes,
        extUpper: extUpper,
        filenameNoExt: filenameNoExt,
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
                    'brand_campaign_details_upload_another_asset'.tr,
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
              controller: _assetTitleCtrl,
              decoration: InputDecoration(
                hintText: 'create_campaign_asset_name_hint'.tr,
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
            12.h.verticalSpace,
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isPicking.value ? null : pickFile,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 46.h),
                    side: const BorderSide(color: softBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.upload_outlined,
                    color: primary.withOpacity(.7),
                  ),
                  label: Text(
                    isPicking.value
                        ? 'create_campaign_picking_file'.tr
                        : 'create_campaign_pick_file'.tr,
                    style: TextStyle(
                      color: primary.withOpacity(.75),
                      fontWeight: FontWeight.w700,
                    ),
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
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: primary.withOpacity(.8),
                            ),
                          ),
                          2.h.verticalSpace,
                          Text(
                            '$ext • $sizeText',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: primary.withOpacity(.55),
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
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('common_cancel'.tr),
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: Obx(() {
                    final canSave =
                        pickedName.value != null && pickedBytes.value != null;

                    return ElevatedButton(
                      onPressed: canSave
                          ? () {
                              final name = pickedName.value!;
                              final bytes = pickedBytes.value!;
                              final path = pickedPath.value;

                              final ext = widget.extUpper(name);
                              final meta =
                                  '$ext – ${widget.formatBytes(bytes)}';

                              final customTitle = _assetTitleCtrl.text.trim();
                              final fallbackTitle = widget.filenameNoExt(name);
                              final title = customTitle.isNotEmpty
                                  ? customTitle
                                  : fallbackTitle;

                              widget.contentAssets.add(
                                JobAsset(
                                  title: title,
                                  meta: meta,
                                  kind: pickedKind.value,
                                  pathOrUrl: path,
                                ),
                              );

                              Get.back();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 46.h),
                        backgroundColor: primary.withOpacity(
                          canSave ? .75 : .35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text('common_done'.tr),
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
