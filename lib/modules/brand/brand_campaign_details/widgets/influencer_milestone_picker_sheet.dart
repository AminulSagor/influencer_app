import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../brand_campaign_details_controller.dart';

class InfluencerMilestonePickerSheet extends StatelessWidget {
  final List<AssignedInfluencerUi> influencers;
  final String? selectedAssignmentId;
  final ValueChanged<AssignedInfluencerUi> onSelect;

  const InfluencerMilestonePickerSheet({
    super.key,
    required this.influencers,
    required this.selectedAssignmentId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              14.h.verticalSpace,
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: influencers.length,
                  separatorBuilder: (_, _) => 8.h.verticalSpace,
                  itemBuilder: (context, index) {
                    final item = influencers[index];
                    final selected = selectedAssignmentId == item.assignmentId;

                    return InkWell(
                      onTap: () => onSelect(item),
                      borderRadius: BorderRadius.circular(999.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: selected
                                ? AppPalette.secondary
                                : AppPalette.border1,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 41.w,
                              height: 41.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7E4C8),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  (item.image != null && item.image!.isNotEmpty)
                                  ? Image.network(
                                      item.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.shrink(),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            12.w.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppPalette.primary,
                                          ),
                                        ),
                                      ),
                                      6.w.horizontalSpace,
                                      // If later needed:
                                      // Icon(
                                      //   Icons.verified_rounded,
                                      //   size: 18.sp,
                                      //   color: const Color(0xFF45B6F0),
                                      // ),
                                    ],
                                  ),
                                  2.h.verticalSpace,
                                  Text(
                                    item.locationText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w300,
                                      color: AppPalette.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
