import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

class TagSelectionDialog extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<String> options;
  final List<String> initialSelected;

  const TagSelectionDialog({
    super.key,
    required this.title,
    required this.searchHint,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<TagSelectionDialog> {
  late final Set<String> _selected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _filteredOptions() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((item) => item.toLowerCase().contains(query))
        .toList(growable: false);
  }

  void _toggleSelection(String value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      backgroundColor: AppPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 16.h),
            CustomTextFormField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              hintText: widget.searchHint,
              prefixIcon: Icon(Icons.search, size: 20.sp),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 96.h, maxHeight: 170.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5.w,
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _filteredOptions()
                      .map((option) {
                        final isSelected = _selected.contains(option);
                        return GestureDetector(
                          onTap: () => _toggleSelection(option),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8EBCF)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppPalette.primary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.close,
                                    size: 14.sp,
                                    color: AppPalette.primary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            CustomButton(
              onTap: () => Get.back<List<String>>(
                result: _selected.toList(growable: false),
              ),
              btnText: 'Save Changes',
              width: double.infinity,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }
}
