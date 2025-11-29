import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/routes/app_routes.dart';

import 'routes/app_pages.dart';

void main() {
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(initialRoute: AppRoutes.bottomNav),
    // ),
    MyApp(initialRoute: AppRoutes.bottomNav),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        // FOR DEVICE PREVIEW
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        //
        title: "Influencer App",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightThemeMode,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
