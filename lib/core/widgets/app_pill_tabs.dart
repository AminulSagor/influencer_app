import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_palette.dart';
import '../utils/constants.dart';

class AppPillTabItem<T> {
  final T value;
  final String label;
  const AppPillTabItem({required this.value, required this.label});
}

class AppPillTabs<T> extends StatelessWidget {
  final T selected;
  final List<AppPillTabItem<T>> items;
  final ValueChanged<T> onChanged;

  const AppPillTabs({
    super.key,
    required this.selected,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWeight1),
      ),
      child: Row(
        children: items.map((e) {
          final active = selected == e.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 7.h),
                decoration: BoxDecoration(
                  color: active ? AppPalette.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    e.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: active ? FontWeight.w500 : FontWeight.w300,
                      color: active ? AppPalette.white : AppPalette.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
