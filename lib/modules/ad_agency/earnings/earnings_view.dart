import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/utils/currency_formatter.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';

import '../../../core/widgets/earnings_overview_card.dart';
import '../../../core/widgets/search_field.dart';
import 'earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              15.h.verticalSpace,
              Obx(
                () => EarningsOverviewCard(
                  lifetimeEarnings: controller.lifetimeEarnings.value,
                  pendingEarnings: controller.pendingEarnings.value,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => _PillTabBar(
                  labels: const ['Earnings', 'Transactions'],
                  currentIndex: controller.mainTabIndex.value,
                  onChanged: controller.changeMainTab,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => controller.mainTabIndex.value == 0
                    ? _EarningsBody(controller: controller)
                    : _TransactionsBody(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCurrency(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    final positionFromEnd = text.length - i;
    buffer.write(text[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return '৳${buffer.toString()}';
}

// ---------------------------------------------------------------------------
// COMMON WIDGETS
// ---------------------------------------------------------------------------

class _PillTabBar extends StatelessWidget {
  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final bool showBorder;

  const _PillTabBar({
    required this.labels,
    required this.currentIndex,
    required this.onChanged,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        border: showBorder
            ? Border.all(color: AppPalette.border1, width: kBorderWidth0_5)
            : null,
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isActive ? AppPalette.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(32.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
                    color: isActive ? AppPalette.white : AppPalette.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppPalette.thirdColor,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.secondary, width: kBorderWeight1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            size: 10.sp,
            color: AppPalette.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            'Low To High',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String headline;
  final String subtitle;

  const _SummaryCard({required this.headline, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          4.h.horizontalSpace,
          FittedBox(
            fit: .scaleDown,
            child: Text(
              headline,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppPalette.secondary,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          FittedBox(
            fit: .scaleDown,
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Future<void> Function()? onNext;

  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final hasNext = onNext != null && currentPage < totalPages;

    return Row(
      children: [
        Text('Page', style: TextStyle(fontSize: 12.sp)),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppPalette.thirdColor,
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            border: Border.all(
              color: AppPalette.secondary,
              width: kBorderWidth0_5,
            ),
          ),
          child: Text(
            currentPage.toString(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.secondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Of $totalPages',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppPalette.black.withAlpha(230),
          ),
        ),
        const Spacer(),
        CustomButton(
          onTap: hasNext ? onNext : null,
          btnText: 'Next',
          textColor: AppPalette.white,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EARNINGS TAB (main)
// ---------------------------------------------------------------------------

class _EarningsBody extends StatelessWidget {
  final EarningsController controller;

  const _EarningsBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChartCard(controller: controller),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppPalette.white,
            border: Border.all(
              color: AppPalette.border1,
              width: kBorderWidth0_5,
            ),
            borderRadius: BorderRadius.circular(kBorderRadius.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => _SummaryCard(
                    headline: _formatCurrency(controller.totalEarnings.value),
                    subtitle: 'Total Earnings',
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(
                  () => _SummaryCard(
                    headline: controller.mostUsedPlatform.value,
                    subtitle: 'Most Used Platform',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _ClientPlatformSection(controller: controller),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final EarningsController controller;

  const _ChartCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.fill2,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.selectedRangeLabel.value,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w300,
                          color: AppPalette.black,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 10.sp,
                        color: AppPalette.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // --- BAR CHART + VERTICAL LABELS ---
          Obx(() {
            final points = controller.chartPoints;

            if (points.isEmpty) {
              return SizedBox(
                height: 210.h,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            // raw max value (e.g. 45000)
            final maxValue = points.fold<int>(
              0,
              (prev, e) => e.value > prev ? e.value : prev,
            );

            // max Y in thousands (10k, 20k, 30k ...), min 10k
            final maxYk = (((maxValue / 1000).ceil() / 10).ceil() * 10)
                .toDouble()
                .clamp(10, double.infinity);

            final barGroups = points.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              final y = p.value / 1000.0; // thousands

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: y,
                    width: 24.w,
                    borderRadius: BorderRadius.circular(999.r),
                    color: AppPalette.secondary,
                  ),
                ],
              );
            }).toList();

            return SizedBox(
              height: 205.h,
              child: Stack(
                children: [
                  // base chart (axes + grid + bars)
                  BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: maxYk.toDouble(),
                      barGroups: barGroups,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: false),

                      // grid
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 10,
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppPalette.border1.withAlpha(80),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppPalette.border1.withAlpha(80),
                            strokeWidth: 1,
                          );
                        },
                      ),

                      // titles
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34.w,
                            interval: 10,
                            getTitlesWidget: (value, meta) {
                              if (value % 10 != 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Text(
                                  '${value.toInt()}k',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  points[index].label, // e.g. "7/11"
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(
                            color: AppPalette.border1.withAlpha(80),
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: AppPalette.border1.withAlpha(80),
                            width: 1,
                          ),
                          right: BorderSide.none,
                          top: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // vertical value labels inside each bar
                  // Padding(
                  //   // align with chart drawing area
                  //   padding: EdgeInsets.only(
                  //     left: 90.w, // same as leftTitles reservedSize
                  //     right: 8.w,
                  //     bottom: 24.h, // space for bottom titles
                  //   ),
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.end,
                  //     children: points.asMap().entries.map((entry) {
                  //       final p = entry.value;
                  //       final valueK = (p.value / 1000).round();
                  //       final fraction = maxYk == 0
                  //           ? 0.0
                  //           : (valueK.toDouble() / maxYk);

                  //       return Expanded(
                  //         child: Align(
                  //           alignment: Alignment.bottomCenter,
                  //           child: FractionallySizedBox(
                  //             heightFactor: fraction,
                  //             alignment: Alignment.bottomCenter,
                  //             child: Transform.rotate(
                  //               angle: -math.pi / 2,
                  //               child: Text(
                  //                 '${valueK}k',
                  //                 style: TextStyle(
                  //                   fontSize: 10.sp,
                  //                   color: Colors.white,
                  //                   fontWeight: FontWeight.w500,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 4.h, width: 4.h, color: AppPalette.secondary),
              4.w.horizontalSpace,
              Text(
                'Earnings in Thousands',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: AppPalette.black.withAlpha(200),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientPlatformSection extends StatelessWidget {
  final EarningsController controller;

  const _ClientPlatformSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kBorderRadius.r),
        border: Border.all(color: AppPalette.border1, width: kBorderWidth0_5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _PillTabBar(
                    labels: const ['Client List', 'Platform'],
                    currentIndex: controller.earningsInnerTabIndex.value,
                    onChanged: controller.changeEarningsInnerTab,
                    showBorder: false,
                  ),
                ),
                SizedBox(width: 12.w),
                const _FilterChip(),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(
            () => controller.earningsInnerTabIndex.value == 0
                ? _ClientListSection(controller: controller)
                : _PlatformSection(controller: controller),
          ),
        ],
      ),
    );
  }
}

class _ClientListSection extends StatelessWidget {
  final EarningsController controller;

  const _ClientListSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hintText: 'Search Client',
          onChanged: (value) => controller.clientSearchQuery.value = value,
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius.r),
            border: Border.all(
              color: AppPalette.border1,
              width: kBorderWidth0_5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppPalette.secondary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(kBorderRadius.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Image.asset('assets/icons/suitcase.png', width: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'Jobs Completed',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.clientIsLoading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.clientItems.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No clients found',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.clientItems.map((item) {
                    return _ClientRow(item: item);
                  }).toList(),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => _PaginationFooter(
            currentPage: controller.clientCurrentPage.value,
            totalPages: controller.clientTotalPages.value,
            onNext: controller.hasNextClientPage
                ? controller.goToNextClientPage
                : null,
          ),
        ),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  final ClientItem item;

  const _ClientRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppPalette.border1, width: kBorderWidth0_5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: AppPalette.thirdColor,
            child: Icon(
              Icons.person_rounded,
              size: 18.sp,
              color: AppPalette.secondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppPalette.primary,
              ),
            ),
          ),
          Text(
            item.jobsCompleted.toString(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformSection extends StatelessWidget {
  final EarningsController controller;

  const _PlatformSection({required this.controller});

  IconData _iconFor(String key) {
    switch (key.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'youtube':
        return Icons.ondemand_video;
      case 'tiktok':
        return Icons.play_arrow_rounded;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.platformIsLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final items = controller.platformItems;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.40,
        ),
        itemCount: items.length + 1, // +1 for "Add Social Link"
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _AddSocialLinkCard();
          }

          final item = items[index];
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius.r),
              border: Border.all(
                color: AppPalette.border1,
                width: kBorderWidth0_5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: .min,
              children: [
                Text(
                  item.jobsCompleted.toString(),
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.secondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Text(
                    'Jobs Completed',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.defaultStroke,
                    ),
                  ),
                ),
                // const Spacer(),
                FittedBox(
                  fit: .scaleDown,
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(item.iconKey),
                        size: 20.sp,
                        color: AppPalette.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w300,
                          color: AppPalette.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _AddSocialLinkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomButton.dotted(
      onTap: () {},
      btnText: '+ ADD SOCIAL LINK',
      height: double.infinity,
      width: double.infinity,
      btnColor: AppPalette.defaultFill,
      textColor: AppPalette.defaultStroke,
    );
  }
}

// ---------------------------------------------------------------------------
// TRANSACTIONS TAB
// ---------------------------------------------------------------------------

class _TransactionsBody extends StatelessWidget {
  final EarningsController controller;

  const _TransactionsBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(18.h),
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(kBorderRadius),
            border: Border.all(
              color: AppPalette.border1,
              width: kBorderWidth0_5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => _SummaryCard(
                    headline: formatCurrencyByLocale(
                      controller.totalEarnings.value,
                    ),
                    subtitle: 'Total Earnings',
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(
                  () => _SummaryCard(
                    headline: formatCurrencyByLocale(
                      controller.recentEarnings.value,
                    ),
                    subtitle: 'Recent Earnings',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SearchField(
          hintText: 'Search By Campaign Name, Client Name',
          onChanged: (value) => controller.transactionSearchQuery.value = value,
        ),
        SizedBox(height: 16.h),
        _TransactionsSection(controller: controller),
      ],
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  final EarningsController controller;

  const _TransactionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: .scaleDown,
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      FittedBox(
                        fit: .scaleDown,
                        child: Text(
                          'Showing ${controller.transactionItems.length} '
                          'Of ${controller.transactionTotalItems.value} Results',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppPalette.greyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FittedBox(fit: .scaleDown, child: const _FilterChip()),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.transactionIsLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.transactionItems.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return Column(
              children: controller.transactionItems.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _TransactionCard(item: item),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16.h),
          Obx(
            () => _PaginationFooter(
              currentPage: controller.transactionCurrentPage.value,
              totalPages: controller.transactionTotalPages.value,
              onNext: controller.hasNextTransactionPage
                  ? controller.goToNextTransactionPage
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionItem item;

  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isInbound = item.type == TransactionType.inbound;
    final bgColor = isInbound ? AppPalette.thirdColor : AppPalette.gradient2;
    final txtColor = isInbound ? AppPalette.primary : AppPalette.complemetary;
    final accentColor = isInbound
        ? AppPalette.secondary
        : AppPalette.complemetary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.white, bgColor],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor, width: kBorderWidth0_5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.4)),
              gradient: LinearGradient(
                colors: [bgColor, AppPalette.white],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Icon(
              isInbound
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: accentColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: txtColor,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.greyText,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  mainAxisSize: .max,
                  children: [
                    FittedBox(
                      fit: .scaleDown,
                      child: Text(
                        formatCurrencyByLocale(item.amount),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: txtColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: .scaleDown,
                          child: Text(
                            '${item.detailsLabel} >',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: txtColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}
