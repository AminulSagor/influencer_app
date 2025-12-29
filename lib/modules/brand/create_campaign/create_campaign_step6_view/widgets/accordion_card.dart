import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccordionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool initiallyExpanded;
  final Widget child;

  const AccordionCard({super.key,
    required this.icon,
    required this.title,
    required this.initiallyExpanded,
    required this.child,
  });

  static const _primary = Color(0xFF2F4F1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
          iconColor: _primary,
          collapsedIconColor: _primary,
          title: Row(
            children: [
              Icon(icon, color: _primary, size: 20.sp),
              10.w.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}