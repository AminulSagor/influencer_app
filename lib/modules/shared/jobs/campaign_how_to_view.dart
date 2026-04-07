import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

class CampaignHowToView extends StatefulWidget {
  const CampaignHowToView({super.key});

  @override
  State<CampaignHowToView> createState() => _CampaignHowToViewState();
}

class _CampaignHowToViewState extends State<CampaignHowToView> {
  bool _isInfluencerExpanded = true;
  bool _isAgencyExpanded = true;

  static const String _placeholderAssetPath = 'assets/images/how_to.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F3),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(id: 1),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppPalette.black,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8DAA63),
                            width: 3.w,
                          ),
                        ),
                        child: Icon(
                          Icons.question_mark_rounded,
                          color: const Color(0xFF8DAA63),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How To',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.secondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Learn how to create your first campaign',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w300,
                                color: AppPalette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(kBorderRadius.r),
                      border: Border.all(
                        color: AppPalette.border1,
                        width: kBorderWidth0_5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _GuideAccordionCard(
                          title: 'Create Campaign For Influencers',
                          isExpanded: _isInfluencerExpanded,
                          onToggle: () {
                            setState(() {
                              _isInfluencerExpanded = !_isInfluencerExpanded;
                            });
                          },
                          points: const [
                            'Go to campaign menu',
                            'Select ‘ + New ’ button',
                            'Select your campaign type - Influencer promotion',
                            'Fill out the form on step 2 & 3',
                            'On step 4, provide your campaign budget first. Then create your campaign milestones which you would want the influencers to fulfill on their end. Select your platforms (Ex: Facebook, X, Instagram) and set your desired promotion targets on the screen. Create one each for the other platforms. Below a example is provided:',
                            'Upload your assets for the campaign (if any). You can provide it later.',
                            'Review your campaign details and confirm the placement.',
                          ],
                          showImageAfterPointFive: true,
                          imageAssetPath: _placeholderAssetPath,
                        ),
                        SizedBox(height: 22.h),
                        _GuideAccordionCard(
                          title: 'Create Campaign For Ad Agencies',
                          isExpanded: _isAgencyExpanded,
                          onToggle: () {
                            setState(() {
                              _isAgencyExpanded = !_isAgencyExpanded;
                            });
                          },
                          points: const [
                            'Go to campaign menu',
                            'Select ‘ + New ’ button',
                            'Select your campaign type - Influencer promotion',
                            'Fill out the form on step 2 & 3',
                            'On step 4, provide your campaign budget first. Then create your campaign milestones which you would want the influencers to fulfill on their end. Select your platforms (Ex: Facebook, X, Instagram) and set your desired promotion targets on the screen. Create one each for the other platforms.',
                            'Upload your assets for the campaign (if any). You can provide it later.',
                            'Review your campaign details and confirm the placement.',
                          ],
                          showImageAfterPointFive: false,
                          imageAssetPath: _placeholderAssetPath,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideAccordionCard extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<String> points;
  final bool showImageAfterPointFive;
  final String imageAssetPath;

  const _GuideAccordionCard({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.points,
    required this.showImageAfterPointFive,
    required this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFD7D7D7), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Row(
              children: [
                Container(
                  width: 17.w,
                  height: 17.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.secondary, width: 2),
                  ),
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: AppPalette.secondary,
                    size: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppPalette.black,
                  size: 22.sp,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 12.h),
            Divider(color: const Color(0xFFABC489), thickness: 1, height: 1),
            SizedBox(height: 14.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < points.length; i++) ...[
                      _NumberedPoint(number: i + 1, text: points[i]),
                      if (showImageAfterPointFive && i == 4) ...[
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.only(left: 24.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.asset(
                              imageAssetPath,
                              fit: BoxFit.cover,
                              height: 250.h,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  height: 250.h,
                                  alignment: Alignment.center,
                                  color: const Color(0xFFF1F4EA),
                                  child: Text(
                                    'Image asset placeholder',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppPalette.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: i == points.length - 1 ? 0 : 10.h),
                    ],
                    SizedBox(height: 22.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Note: ',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                'You can save this campaign as draft at any steps if you want to continue it later.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppPalette.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberedPoint extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedPoint({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              '$number.',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.black,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
                color: AppPalette.black,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
