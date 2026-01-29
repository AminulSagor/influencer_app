import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';
import '../utils/constants.dart';

/// Reusable file upload tile for signup flows.
/// Displays a dotted border container for uploading documents/images.
class FileUploadTile extends StatelessWidget {
  final VoidCallback onTap;
  final String helperText;
  final String? filePath;
  final bool isImage;
  final double? minHeight;
  final VoidCallback? onClear;

  const FileUploadTile({
    super.key,
    required this.onTap,
    required this.helperText,
    this.filePath,
    this.isImage = true,
    this.minHeight,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius.r),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [5, 5],
          strokeWidth: 1,
          padding: EdgeInsets.zero,
          radius: Radius.circular(kBorderRadius.r),
          color: AppPalette.secondary,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight ?? 140.h),
          padding: hasFile
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: 32.h),
          decoration: BoxDecoration(
            color: AppPalette.defaultFill,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
          child: hasFile
              ? Stack(
                  alignment: Alignment.topRight,
                  children: [
                    _buildPreview(),
                    if (onClear != null)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: InkWell(
                          onTap: onClear,
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: AppPalette.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 32.sp,
                      color: AppPalette.primary,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      helperText,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppPalette.primary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        child: Image.file(
          File(filePath!),
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Document file preview
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 40.sp,
              color: AppPalette.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                filePath!.split('/').last,
                style: TextStyle(fontSize: 14.sp, color: AppPalette.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
          ],
        ),
      );
    }
  }
}
