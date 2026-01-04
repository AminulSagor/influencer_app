import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/modules/brand/analytics/models/analytics_models.dart';
import 'package:influencer_app/routes/app_routes.dart';

import 'core/services/account_type_service.dart';
import 'core/controllers/language_controller.dart';
import 'core/localization/app_translations.dart';
import 'routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(LanguageController(), permanent: true);
  Get.put<AccountTypeService>(AccountTypeService(), permanent: true);

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(initialRoute: AppRoutes.bottomNav),
    // ),
    InfluencerApp(initialRoute: AppRoutes.onboarding),
  );
}

class InfluencerApp extends StatelessWidget {
  final String initialRoute;
  const InfluencerApp({super.key, required this.initialRoute});

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
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('bn', 'BD')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: "Influencer App",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightThemeMode,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
