import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/services/firebase_messaging_service.dart';
import 'package:influencer_app/core/theme/app_theme.dart';
import 'package:influencer_app/routes/app_routes.dart';
import 'core/bindings/initial_binding.dart';
import 'core/localization/app_translations.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseMessagingService.init();

  runApp(InfluencerApp(initialRoute: AppRoutes.bootstrap));
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
        initialBinding: InitialBinding(),
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
