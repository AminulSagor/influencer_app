import 'package:get/get.dart';

import '../modules/ad_agency/bottom_navbar/bottom_nav_binding.dart';
import '../modules/ad_agency/bottom_navbar/bottom_nav_view.dart';
import '../modules/ad_agency/jobs/jobs_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.bottomNav,
      page: () => const BottomNavView(),
      binding: BottomNavBinding(),
    ),
    GetPage(name: AppRoutes.jobs, page: () => const JobsView()),
  ];
}
