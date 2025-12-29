import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/constants.dart';

class InputNamesWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final TextEditingController textController;
  final List<String> names;
  final void Function(String) onSubmitted;
  final void Function(String) onDeleted;

  const InputNamesWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.textController,
    required this.names,
    required this.onSubmitted,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppPalette.primary)),

          5.h.verticalSpace,

          TextField(
            controller: textController,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.black,
            ),
            decoration: InputDecoration(
              fillColor: AppPalette.white,
              filled: true,
              hintText: subTitle,
              hintStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, color: AppPalette.greyText,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: onSubmitted,
          ),

          16.h.verticalSpace,

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            width: MediaQuery.sizeOf(context).width,
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: names.map((name) => Chip(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),),
                label: Text(name),
                deleteIcon: const Icon(Icons.close,size: 16),
                onDeleted: () => onDeleted(name),
              ),
              ).toList(),
            ),
          ),
        ],
      );
    });
  }
}