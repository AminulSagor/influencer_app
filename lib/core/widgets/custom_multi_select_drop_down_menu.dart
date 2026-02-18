import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CustomMultiSelectDropDownMenu extends StatelessWidget {
  final String? title;
  final TextStyle? titleTextStyle;
  final String hintText;
  final List<String> options;
  final List<String> selectedValues;
  final Color? fillColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Function(List<String>)? onChanged;
  final FormFieldValidator<List<String>>? validator;
  final AutovalidateMode? autovalidateMode;

  const CustomMultiSelectDropDownMenu({
    super.key,
    required this.hintText,
    required this.options,
    required this.selectedValues,
    this.onChanged,
    this.title,
    this.titleTextStyle,
    this.fillColor,
    this.textColor,
    this.textStyle,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildField(
      List<String> currentValues,
      bool hasError, {
      Function(List<String>)? onChangedOverride,
    }) {
      return GestureDetector(
        onTap: () async {
          List<String> tempSelected = List.from(currentValues);

          final results = await Get.bottomSheet<List<String>>(
            StatefulBuilder(
              builder: (context, setState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.6),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Drag Indicator
                          Container(
                            width: 40.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),

                          /// Title
                          Text(
                            title ?? hintText,
                            style: AppTheme.textStyle.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          /// Options
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: options.map((option) {
                                  final isSelected = tempSelected.contains(
                                    option,
                                  );

                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(
                                      option.tr,
                                      style:
                                          textStyle ??
                                          TextStyle(
                                            fontSize: 12.sp,
                                            color:
                                                textColor ?? AppPalette.black,
                                          ),
                                    ),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          tempSelected.add(option);
                                        } else {
                                          tempSelected.remove(option);
                                        }
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          /// Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Cancel"),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Get.back(result: tempSelected),
                                  child: const Text("Done"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            isScrollControlled: true,
          );

          if (results != null) {
            if (onChangedOverride != null) {
              onChangedOverride(results);
            } else if (onChanged != null) {
              onChanged!(results);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: fillColor ?? AppPalette.defaultFill,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentValues.isEmpty ? hintText : currentValues.join(', '),
                  style:
                      textStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.sp,
                        color: currentValues.isEmpty
                            ? Colors.grey
                            : textColor ?? AppPalette.black,
                      ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
            ],
          ),
        ),
      );
    }

    Widget withTitle(Widget field, {String? errorText}) {
      if (title == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field,
            if (errorText != null) ...[
              SizedBox(height: 6.h),
              Text(
                errorText,
                style:
                    textStyle ?? TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            ],
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style:
                titleTextStyle ??
                AppTheme.textStyle.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.secondary,
                ),
          ),
          SizedBox(height: 5.h),
          field,
          if (errorText != null) ...[
            SizedBox(height: 6.h),
            Text(
              errorText,
              style: textStyle ?? TextStyle(fontSize: 12.sp, color: Colors.red),
            ),
          ],
        ],
      );
    }

    if (validator == null) {
      final field = buildField(selectedValues, false);
      return withTitle(field);
    }

    return FormField<List<String>>(
      initialValue: selectedValues,
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (state) {
        final field = buildField(
          state.value ?? [],
          state.hasError,
          onChangedOverride: (val) {
            state.didChange(val);
            if (onChanged != null) {
              onChanged!(val);
            }
          },
        );

        return withTitle(field, errorText: state.errorText);
      },
    );
  }
}
