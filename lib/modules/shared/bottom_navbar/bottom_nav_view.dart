import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/services/account_type_service.dart';
import 'package:influencer_app/core/utils/constants.dart';
import 'package:influencer_app/core/widgets/custom_button.dart';
import '../../../core/widgets/logout_dialog.dart';
import 'bottom_nav_controller.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/services/auth_services.dart';
import 'utils/bottom_nav_route_generator.dart';

class BottomNavView extends StatelessWidget {
  const BottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomNavController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back(id: 1, closeOverlays: true);
      },
      child: Obx(
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
                    // Dev mode: always show dashboard home (no verification checks)
                    initialRoute: AppRoutes.home,
                    onGenerateRoute: BottomNavRouteGenerator.generateRoute,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildCustomBottomNav(),
        ),
      ),
    );
  }

  // ---------------- TOP BAR (shared) ----------------
  Widget _buildTopBar() {
    final session = Get.find<AppUserSessionController>();
    final controller = Get.find<BottomNavController>();

    // Builder gives us a context that is *below* the Scaffold,
    // so Scaffold.of(context).openEndDrawer() works.
    return Builder(
      builder: (context) {
        return Obx(() {
          final userName = session.displayName.value.trim();
          final avatarUrl = session.profileImageUrl.value.trim();
          final unreadCount = session.unreadNotificationCount;
          final welcomeText = userName.isNotEmpty
              ? 'topbar_welcome_user'.tr.replaceFirst('User', userName)
              : 'topbar_welcome_user'.tr;

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
                        welcomeText,
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

                GestureDetector(
                  onTap: () => controller.openNotifications(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/icons/notification.png',
                        width: 28.w,
                        height: 28.h,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6.w,
                          top: -6.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 1.h,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: 14.w),

                GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: CircleAvatar(
                    radius: 23.r,
                    backgroundColor: AppPalette.background,
                    child: CircleAvatar(
                      radius: 21.r,
                      backgroundColor: Colors.white,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _buildCustomBottomNav() {
    final controller = Get.find<BottomNavController>();
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
    Future<void> logout() async {
      final session = Get.find<AppUserSessionController>();

      if (Scaffold.of(context).isEndDrawerOpen) {
        Navigator.of(context).pop();
      }

      final confirmed = await LogoutDialog.show();
      if (!confirmed) return;

      await session.logout();
    }

    return SafeArea(
      top: false,
      child: SizedBox(
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
                    final index = _accountTypeService.isBrand ? 4 : 3;
                    Get.find<BottomNavController>().onTabChanged(index);
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 24.h,
                  ),
                  child: Divider(height: 1, color: Colors.grey[300]),
                ),

                _DrawerActionItem(
                  icon: Icons.logout_rounded,
                  color: AppPalette.complemetary,
                  label: 'Logout',
                  onTap: logout,
                ),
                40.h.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader();

  double _parseRating(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double _resolveRating(
    AppUserSessionController session,
    AccountTypeService accountTypeService,
  ) {
    if (accountTypeService.isInfluencer &&
        session.influencerProfile.value != null) {
      return session.influencerProfile.value!.averageRating;
    }

    if (accountTypeService.isAdAgency &&
        session.agencyProfileJson.value != null) {
      final agencyJson = session.agencyProfileJson.value!;
      return _parseRating(agencyJson['averageRating']);
    }

    return 0.0;
  }

  String _resolveLocation(
    AppUserSessionController session,
    AccountTypeService accountTypeService,
  ) {
    if (accountTypeService.isInfluencer &&
        session.influencerProfile.value != null) {
      final address = session.influencerProfile.value!.primaryAddress;
      final formatted = address?.formattedAddress ?? '';
      if (formatted.trim().isNotEmpty) return formatted.trim();
    }

    if (accountTypeService.isAdAgency &&
        session.agencyProfileJson.value != null &&
        session.agencyProfileJson.value!['address'] is Map) {
      final agencyJson = session.agencyProfileJson.value!;
      final address = agencyJson['address'] as Map;
      final thana = (address['thana'] ?? '').toString().trim();
      final zilla = (address['zilla'] ?? '').toString().trim();
      final fullAddress = (address['fullAddress'] ?? '').toString().trim();
      final country = (address['country'] ?? '').toString().trim();
      final parts = <String>[
        if (fullAddress.isNotEmpty) fullAddress,
        if (thana.isNotEmpty) thana,
        if (zilla.isNotEmpty) zilla,
        if (country.isNotEmpty) country,
      ];
      if (parts.isNotEmpty) return parts.join(', ');
    }

    return 'Dhaka, Bangladesh';
  }

  bool _resolveVerified(
    AppUserSessionController session,
    AccountTypeService accountTypeService,
  ) {
    if (accountTypeService.isInfluencer &&
        session.influencerProfile.value != null) {
      return session.influencerProfile.value!.isOnboardingComplete;
    }

    if (accountTypeService.isAdAgency &&
        session.agencyProfileJson.value != null) {
      final agencyJson = session.agencyProfileJson.value!;
      return agencyJson['isOnboardingComplete'] as bool? ?? false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AppUserSessionController>();
    final accountTypeService = Get.find<AccountTypeService>();
    double topPadding = MediaQuery.of(context).padding.top;
    return Obx(() {
      final avatarUrl = session.profileImageUrl.value.trim();
      final name = session.displayName.value.trim().isNotEmpty
          ? session.displayName.value.trim()
          : 'User';
      final shouldShowRating =
          accountTypeService.isInfluencer || accountTypeService.isAdAgency;

      final ratingValue = shouldShowRating
          ? _resolveRating(session, accountTypeService)
          : 0.0;

      final ratingLabel = shouldShowRating
          ? ratingValue.toStringAsFixed(1)
          : '';
      final location = _resolveLocation(session, accountTypeService);
      final isVerified = _resolveVerified(session, accountTypeService);

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
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 40.sp, color: Colors.grey[600])
                    : null,
              ),
            ),
            SizedBox(height: 24.h),
            if (shouldShowRating) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ..._buildRatingStars(
                    rating: ratingValue,
                    size: 20.sp,
                    filledColor: AppPalette.starDark,
                    emptyColor: AppPalette.starDark.withOpacity(0.35),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    ratingLabel,
                    style: TextStyle(
                      color: AppPalette.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isVerified) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.verified_rounded,
                    size: 18.sp,
                    color: Colors.lightBlue[300],
                  ),
                ],
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${location.split(',').last}, Bangladesh',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.secondary, fontSize: 16.sp),
            ),
          ],
        ),
      );
    });
  }
}

List<Widget> _buildRatingStars({
  required double rating,
  required double size,
  required Color filledColor,
  required Color emptyColor,
}) {
  final clamped = rating.clamp(0.0, 5.0);
  final full = clamped.floor();
  final hasHalf = (clamped - full) >= 0.5;

  return List.generate(5, (i) {
    final IconData icon;
    if (i < full) {
      icon = Icons.star_rounded;
    } else if (i == full && hasHalf) {
      icon = Icons.star_half_rounded;
    } else {
      icon = Icons.star_outline_rounded;
    }

    final isFilled = i < full || (i == full && hasHalf);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Icon(icon, size: size, color: isFilled ? filledColor : emptyColor),
    );
  });
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
