import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_text_form_field.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/custom_button.dart';

class ExperiencedNicheDialog extends StatefulWidget {
  final List<String> initialSelected;
  final List<String> allNiches;

  const ExperiencedNicheDialog({
    super.key,
    required this.initialSelected,
    required this.allNiches,
  });

  @override
  State<ExperiencedNicheDialog> createState() => _ExperiencedNicheDialogState();
}

class _ExperiencedNicheDialogState extends State<ExperiencedNicheDialog> {
  late Set<String> _selected;
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
              'Experienced Niche',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
            SizedBox(height: 16.h),

            // Search field
            CustomTextFormField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              hintText: 'Search Niche',
              prefixIcon: const Icon(Icons.search),
            ),

            SizedBox(height: 20.h),

            // Selected / available chips
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius.r),
                border: Border.all(
                  color: AppPalette.border1,
                  width: kBorderWidth0_5.w,
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: _filteredNiches().map((niche) {
                    final bool isSelected = _selected.contains(niche);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(niche);
                          } else {
                            _selected.add(niche);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF6F8D9)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: isSelected
                                ? AppPalette.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              niche,
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
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Save button
            CustomButton(
              onTap: () => Get.back<List<String>>(result: _selected.toList()),
              btnText: 'Save Changes',
              height: 48.h,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _filteredNiches() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.allNiches;
    return widget.allNiches
        .where((n) => n.toLowerCase().contains(query))
        .toList();
  }
}
