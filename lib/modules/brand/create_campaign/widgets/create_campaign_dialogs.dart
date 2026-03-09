// lib/modules/brand/create_campaign/widgets/create_campaign_dialogs.dart
part of '../create_campaign_controller.dart';

typedef AddAssetCallback = void Function(JobAsset asset);
typedef GuessKindFn = JobAssetKind Function(String filename);
typedef IconForKindFn = IconData Function(JobAssetKind kind);
typedef ExtUpperFn = String Function(String filename);
typedef FilenameNoExtFn = String Function(String filename);
typedef FormatBytesFn = String Function(int bytes);

class CreateCampaignDialogs {
  static void openAddContentAsset({
    required CreateCampaignController controller,
    required AddAssetCallback onAdd,
    required GuessKindFn guessKind,
    required IconForKindFn iconForKind,
    required ExtUpperFn extUpper,
    required FilenameNoExtFn filenameNoExt,
    required FormatBytesFn formatBytes,
  }) {
    final pickedName = RxnString();
    final pickedBytes = RxnInt();
    final pickedPath = RxnString();
    final pickedKind = JobAssetKind.other.obs;
    final isPicking = false.obs;

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
        pickedKind.value = guessKind(f.name);
      } finally {
        isPicking.value = false;
      }
    }

    Get.dialog(
      Dialog(
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
                      'create_campaign_upload_another_asset'.tr,
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
                hintText: 'create_campaign_asset_name_hint'.tr,
                controller: controller.assetTitleCtrl,
              ),
              12.h.verticalSpace,
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isPicking.value ? null : pickFile,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 46.h),
                      side: BorderSide(color: AppPalette.border1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.upload_outlined,
                      color: AppPalette.primary,
                    ),
                    label: Text(
                      isPicking.value
                          ? 'create_campaign_picking_file'.tr
                          : 'create_campaign_pick_file'.tr,
                      style: TextStyle(
                        color: AppPalette.primary,
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
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'create_campaign_no_file_selected'.tr,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final ext = extUpper(name);
                final sizeText = formatBytes(bytes);

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kBorderRadius.r),
                    border: Border.all(
                      color: AppPalette.secondary,
                      width: kBorderWidth0_5.w,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
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
                        iconForKind(pickedKind.value),
                        color: AppPalette.primary,
                        size: 24.sp,
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
                                fontWeight: FontWeight.w400,
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
                          pickedName.value != null && pickedBytes.value != null;
                      return CustomButton(
                        onTap: canSave
                            ? () {
                                final name = pickedName.value!;
                                final bytes = pickedBytes.value!;
                                final p = pickedPath.value;

                                final ext = extUpper(name);
                                final meta = '$ext – ${formatBytes(bytes)}';

                                final customTitle = controller
                                    .assetTitleCtrl
                                    .text
                                    .trim();
                                final fallbackTitle = filenameNoExt(name);
                                final title = customTitle.isNotEmpty
                                    ? customTitle
                                    : fallbackTitle;

                                onAdd(
                                  JobAsset(
                                    title: title,
                                    meta: meta,
                                    kind: pickedKind.value,
                                    pathOrUrl: p,
                                  ),
                                );

                                Get.back();
                              }
                            : null,
                        isDisabled: !canSave,
                        btnText: 'common_done'.tr,
                        btnColor: canSave
                            ? AppPalette.secondary
                            : AppPalette.defaultFill,
                        textColor: canSave
                            ? AppPalette.white
                            : AppPalette.black,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void openBrandAssetEditor({
    required String title,
    required TextEditingController titleCtrl,
    required TextEditingController valueCtrl,
    required VoidCallback onDone,
  }) {
    Get.defaultDialog(
      title: title,
      content: Column(
        children: [
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_name_hint'.tr,
            ),
          ),
          10.h.verticalSpace,
          TextField(
            controller: valueCtrl,
            decoration: InputDecoration(
              hintText: 'create_campaign_brand_asset_value_hint'.tr,
            ),
          ),
        ],
      ),
      textConfirm: 'common_done'.tr,
      textCancel: 'common_cancel'.tr,
      onConfirm: () {
        onDone();
        Get.back();
      },
    );
  }

  static void openPlacementConfirmed({
    required CreateCampaignController controller,
  }) {
    Get.dialog(
      CampaignPlacementConfirmedDialog(controller: controller),
      barrierDismissible: false,
    );
  }
}

class CampaignPlacementConfirmedDialog extends StatelessWidget {
  final CreateCampaignController controller;
  const CampaignPlacementConfirmedDialog({super.key, required this.controller});

  static const _primary = AppPalette.primary;
  static const _bg = AppPalette.white;

  String _safeTitle() {
    final t = controller.campaignName.value.trim();
    if (t.isNotEmpty) return t;
    final t2 = controller.campaignNameCtrl.text.trim();
    if (t2.isNotEmpty) return t2;
    return 'create_campaign_step6_campaign_title_fallback'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final title = _safeTitle();

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
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
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(999.r),
                    onTap: controller.finishFlowAndReset,
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        Icons.close,
                        size: 22.sp,
                        color: _primary.withOpacity(.65),
                      ),
                    ),
                  ),
                ],
              ),
              6.h.verticalSpace,
              Container(
                width: 68.w,
                height: 68.w,
                decoration: const BoxDecoration(
                  color: AppPalette.secondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.check, size: 40.sp, color: Colors.white),
              ),
              14.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'create_campaign_step6_popup_title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
              8.h.verticalSpace,
              Text(
                'create_campaign_step6_popup_message'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.35,
                  color: _primary.withOpacity(.85),
                  fontWeight: FontWeight.w300,
                ),
              ),
              16.h.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.black12),
                  gradient: const LinearGradient(
                    colors: [AppPalette.gradient1, AppPalette.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/online_ads.png',
                          width: 28.w,
                          height: 28.w,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                controller.totalBudgetText,
                                style: TextStyle(
                                  color: AppPalette.thirdColor,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    10.h.verticalSpace,
                    Divider(color: Colors.white.withOpacity(.35), height: 1),
                    10.h.verticalSpace,
                    Row(
                      children: [
                        Text(
                          'common_platforms'.tr,
                          style: TextStyle(
                            color: AppPalette.thirdColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        12.w.horizontalSpace,
                        Image.asset(
                          'assets/icons/instagram.png',
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8.w),
                        Image.asset(
                          'assets/icons/youTube.png',
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8.w),
                        Image.asset(
                          'assets/icons/tikTok.png',
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              10.h.verticalSpace,
              Container(width: double.infinity, height: 1, color: _bg),
            ],
          ),
        ),
      ),
    );
  }
}
