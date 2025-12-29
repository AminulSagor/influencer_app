import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../create_campaign_controller.dart';
import '../../create_campaign_step4_view/widgets/select_field.dart';
import 'agency_square_card.dart';
import 'agency_wide_card.dart';

class PaidAdStep2 extends StatelessWidget {
  final CreateCampaignController controller;

  const PaidAdStep2({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Paid Ad Niche (single)

        Text(
          'create_campaign_niche_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),

        5.h.verticalSpace,

        Obx(() {
          final value = controller.selectedPaidAdNiche.value; // ✅ reads Rx
          return SelectField(
            text: value ?? 'create_campaign_niche_hint'.tr,
            isPlaceholder: value == null,
            onTap: controller.openPaidAdNichePicker,
          );
        }),

        20.h.verticalSpace,

        // Recommended agencies
        Text(
          'create_campaign_recommended_agencies_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),

        15.h.verticalSpace,

        SizedBox(
          height: 145.h,
          child: Obx(() {
            final items = controller.recommendedAgencies
                .toList(); // ✅ IMPORTANT
            final selectedName =
                controller.selectedAgencyName.value; // ✅ reads Rx
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => 12.w.horizontalSpace,
              itemBuilder: (_, i) {
                final a = items[i];
                final selected = selectedName == a.name;
                return AgencySquareCard(
                  name: a.name,
                  subtitle: a.subtitle,
                  selected: selected,
                  onTap: () => controller.selectAgency(a.name),
                );
              },
            );
          }),
        ),

        28.h.verticalSpace,

        /// Other agencies (vertical)
        Text(
          'create_campaign_other_agencies_label'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.primary,
          ),
        ),

        12.h.verticalSpace,

        Obx(() {
          final items = controller.otherAgencies.toList(); // ✅ IMPORTANT
          final selectedName =
              controller.selectedAgencyName.value; // ✅ reads Rx
          return Column(
            children: items.map((a) {
              final selected = selectedName == a.name;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AgencyWideCard(
                  name: a.name,
                  subtitle: a.subtitle,
                  selected: selected,
                  onTap: () => controller.selectAgency(a.name),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}