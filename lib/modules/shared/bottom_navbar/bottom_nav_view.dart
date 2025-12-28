import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'bottom_nav_controller.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

import 'utils/bottom_nav_route_generator.dart';

class BottomNavView extends GetView<BottomNavController> {
  const BottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        key: const ValueKey('bottom-nav-scaffold'),
        backgroundColor: AppPalette.primary,

        // ---------- RIGHT SIDE DRAWER ----------
        endDrawer: const _ProfileDrawer(),

        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                // ---------- NESTED NAVIGATOR ----------
                child: Navigator(
                  key: Get.nestedKey(1),
                  initialRoute: controller.isAccountVerified
                      ? AppRoutes.home
                      : AppRoutes.agencyHomeLocked,
                  onGenerateRoute: BottomNavRouteGenerator.generateRoute,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildCustomBottomNav(),
      ),
    );
  }

  // ---------------- TOP BAR (shared) ----------------
  Widget _buildTopBar() {
    // Builder gives us a context that is *below* the Scaffold,
    // so Scaffold.of(context).openEndDrawer() works.
    return Builder(
      builder: (context) {
        return Container(
          height: 71.h,
          padding: EdgeInsets.only(left: 25.w, right: 20.w),
          decoration: const BoxDecoration(color: AppPalette.primary),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'topbar_welcome_user'.tr,
                      style: TextStyle(
                        color: AppPalette.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.04,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'topbar_ready_to_earn'.tr,
                      style: TextStyle(
                        color: AppPalette.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              // notifications -> push inside nested navigator (id: 1)
              GestureDetector(
                onTap: () => controller.openNotifications(),
                child: Image.asset(
                  'assets/icons/notification.png',
                  width: 28.w,
                  height: 28.h,
                ),
              ),

              SizedBox(width: 14.w),

              // Avatar -> open drawer
              GestureDetector(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: CircleAvatar(
                  radius: 23.r,
                  backgroundColor: AppPalette.background,
                  child: CircleAvatar(
                    radius: 21.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _buildCustomBottomNav() {
    const Color navBg = AppPalette.primary;
    const Color activeBg = AppPalette.secondary;
    const Color iconColor = AppPalette.white;

    final accountTypeService = Get.find<AccountTypeService>();
    final bool isBrand = accountTypeService.isBrand;

    final List<_NavItemData> items = isBrand
        ? [
            _NavItemData(iconPath: 'assets/icons/home.png', label: 'nav_home'),
            _NavItemData(
              iconPath: 'assets/icons/online_ads.png',
              label: 'nav_campaign',
            ),
            _NavItemData(
              iconPath: 'assets/icons/analytics.png',
              label: 'nav_analytics',
            ),
            _NavItemData(
              iconPath: 'assets/icons/compass.png',
              label: 'nav_explore',
            ),
            _NavItemData(
              iconPath: 'assets/icons/account_male.png',
              label: 'nav_profile',
            ),
          ]
        : [
            _NavItemData(iconPath: 'assets/icons/home.png', label: 'nav_home'),
            _NavItemData(
              iconPath: 'assets/icons/suitcase.png',
              label: 'nav_jobs',
            ),
            _NavItemData(
              iconPath: 'assets/icons/dollar_coin.png',
              label: 'nav_earnings',
            ),
            _NavItemData(
              iconPath: 'assets/icons/account_male.png',
              label: 'nav_profile',
            ),
          ];

    final current = controller.currentIndex.value;

    return Container(
      decoration: const BoxDecoration(color: navBg),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool isActive = index == current;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 65.h,
                width: 65.w,
                decoration: BoxDecoration(
                  color: isActive ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item.iconPath,
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 4.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: iconColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String iconPath;
  final String label;

  _NavItemData({required this.iconPath, required this.label});
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    final _accountTypeService = Get.find<AccountTypeService>();

    return SizedBox(
      width: width,
      child: Drawer(
        elevation: 12,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35.r),
            bottomLeft: Radius.circular(35.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DrawerProfileHeader(),
              SizedBox(height: 40.h),

              _DrawerActionItem(
                icon: Icons.flag_rounded,
                color: AppPalette.complemetary,
                label: 'Report',
                onTap: () {
                  Get.toNamed(AppRoutes.reportLog, id: 1);
                },
              ),
              SizedBox(height: 8.h),

              _DrawerActionItem(
                icon: Icons.headset_mic_rounded,
                color: AppPalette.secondary,
                label: 'Support',
                onTap: () => Get.toNamed(AppRoutes.support, id: 1),
              ),
              SizedBox(height: 8.h),

              if (_accountTypeService.isInfluencer ||
                  _accountTypeService.isBrand)
                _DrawerActionItem(
                  iconPath: 'assets/icons/language.png',
                  color: AppPalette.complemetary,
                  label: 'Language',
                  onTap: () => Get.toNamed(AppRoutes.language, id: 1),
                ),

              _DrawerActionItem(
                icon: Icons.person_rounded,
                color: AppPalette.complemetary,
                label: 'Profile',
                onTap: () {
                  // Example: go to profile tab
                  Get.find<BottomNavController>().onTabChanged(3);
                },
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                child: Divider(height: 1, color: Colors.grey[300]),
              ),

              _DrawerActionItem(
                icon: Icons.logout_rounded,
                color: AppPalette.complemetary,
                label: 'Logout',
                onTap: () {
                  // TODO: handle logout
                },
              ),
              40.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader();

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: topPadding + 40.h, bottom: 32.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.gradient1, AppPalette.secondary],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.r),
          bottomLeft: Radius.circular(35.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 58.r,
            backgroundColor: AppPalette.defaultStroke,
            child: CircleAvatar(
              radius: 56.r,
              backgroundColor: AppPalette.white,
              child: Icon(Icons.person, size: 40.sp, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                (_) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Icon(
                    Icons.star_rounded,
                    size: 20.sp,
                    color: AppPalette.starDark,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Icon(
                  Icons.star_half_rounded,
                  size: 20.sp,
                  color: AppPalette.starDark,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '4.5',
                style: TextStyle(
                  color: AppPalette.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Grow Big',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.verified_rounded,
                size: 18.sp,
                color: Colors.lightBlue[300],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Dhaka, Bangladesh',
            style: TextStyle(color: AppPalette.secondary, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

class _DrawerActionItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _DrawerActionItem({
    this.icon,
    required this.color,
    required this.label,
    this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () {
        Navigator.of(context).pop();
        onTap?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
        child: Row(
          children: [
            if (iconPath != null)
              Image.asset(
                'assets/icons/language.png',
                width: 30.w,
                fit: .cover,
              ),
            if (icon != null) Icon(icon, size: 30.sp, color: color),
            SizedBox(width: 18.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
