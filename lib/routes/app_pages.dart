import 'package:get/get.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_controller.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_expertise_view.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_social_view.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_tin_view.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_trade_license_view.dart';
import 'package:influencer_app/modules/auth/signup_agency/signup_agency_view.dart';
import 'package:influencer_app/modules/auth/signup_brand/signup_brand_address_view.dart';
import 'package:influencer_app/modules/auth/signup_brand/signup_brand_kyc_view.dart';
import 'package:influencer_app/modules/auth/signup_brand/signup_brand_social_view.dart';
import 'package:influencer_app/modules/auth/signup_influencer/signup_influencer_address_view.dart';
import 'package:influencer_app/modules/auth/signup_influencer/signup_influencer_controller.dart';
import 'package:influencer_app/modules/auth/signup_success/signup_success_controller.dart';
import 'package:influencer_app/modules/auth/signup_success/signup_success_view.dart';
import 'package:influencer_app/modules/auth/verification/phone_verified_view.dart';
import 'package:influencer_app/modules/auth/verification/verification_controller.dart';
import 'package:influencer_app/modules/auth/verification/verification_view.dart';
import 'package:influencer_app/modules/influencer/campaign_shipping/campaign_shipping_view.dart';
import 'package:influencer_app/modules/shared/language/language_view.dart';
import 'package:influencer_app/modules/shared/onboarding/onboarding_controller.dart';
import 'package:influencer_app/modules/shared/onboarding/onboarding_view.dart';
import 'package:influencer_app/modules/shared/report_log/report_log_controller.dart';
import 'package:influencer_app/modules/shared/support/support_controller.dart';

import '../core/controllers/language_controller.dart';
import '../modules/shared/bottom_navbar/bottom_nav_controller.dart';
import '../modules/shared/bottom_navbar/bottom_nav_view.dart';
import '../modules/shared/jobs/jobs_view.dart';
import '../modules/auth/forget_password/forgot_password_controller.dart';
import '../modules/auth/forget_password/forgot_password_otp_view.dart';
import '../modules/auth/forget_password/forgot_password_view.dart';
import '../modules/auth/forget_password/reset_password_success_view.dart';
import '../modules/auth/forget_password/reset_password_view.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/signup_account_type/signup_account_type_controller.dart';
import '../modules/auth/signup_account_type/signup_account_type_view.dart';
import '../modules/auth/signup_agency/signup_agency_address_view.dart';
import '../modules/auth/signup_agency/signup_influencer_kyc_view.dart';
import '../modules/auth/signup_brand/signup_brand_controller.dart';
import '../modules/auth/signup_brand/signup_brand_tin_view.dart';
import '../modules/auth/signup_brand/signup_brand_trade_license_view.dart';
import '../modules/auth/signup_brand/signup_brand_view.dart';
import '../modules/auth/signup_influencer/signup_influencer_kyc_view.dart';
import '../modules/auth/signup_influencer/signup_influencer_social_view.dart';
import '../modules/auth/signup_influencer/signup_influencer_view.dart';
import '../modules/influencer/campaign_shipping/campaign_shipping_controller.dart';
import '../modules/shared/report_log/report_log_view.dart';
import '../modules/shared/support/support_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.bottomNav,
      page: () => const BottomNavView(),
      binding: BottomNavBinding(),
    ),
    GetPage(name: AppRoutes.jobs, page: () => const JobsView()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAccountType,
      page: () => const SignupAccountTypeView(),
      binding: SignupAccountTypeBinding(),
    ),
    GetPage(
      name: AppRoutes.signupInfluencer,
      page: () => const SignupInfluencerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupInfluencerController>(
          () => SignupInfluencerController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.phoneVerified,
      page: () => const PhoneVerifiedView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.signupInfluencerAddress,
      page: () => const SignupInfluencerAddressView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupInfluencerController>(
          () => SignupInfluencerController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.signupInfluencerSocial,
      page: () => const SignupInfluencerSocialView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupInfluencerController>(
          () => SignupInfluencerController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.signupInfluencerKyc,
      page: () => const SignupInfluencerKycView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupInfluencerController>(
          () => SignupInfluencerController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.signupSuccess,
      page: () => const SignupSuccessView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupSuccessController>(() => SignupSuccessController());
      }),
    ),
    GetPage(
      name: AppRoutes.signupBrand,
      page: () => const SignupBrandView(),
      binding: SignupBrandBinding(),
    ),
    GetPage(
      name: AppRoutes.signupBrandAddress,
      page: () => const SignupBrandAddressView(),
      binding: SignupBrandBinding(),
    ),
    GetPage(
      name: AppRoutes.signupBrandSocial,
      page: () => const SignupBrandSocialView(),
      binding: SignupBrandBinding(),
    ),
    GetPage(
      name: AppRoutes.signupBrandKyc,
      page: () => const SignupBrandKycView(),
      binding: SignupBrandBinding(),
    ),
    GetPage(
      name: AppRoutes.signupBrandTradeLicense,
      page: () => const SignupBrandTradeLicenseView(),
      binding: SignupBrandBinding(),
    ),
    GetPage(
      name: AppRoutes.signupBrandTin,
      page: () => const SignupBrandTinView(),
      binding: SignupBrandBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordOtp,
      page: () => const ForgotPasswordOtpView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPasswordSuccess,
      page: () => const ResetPasswordSuccessView(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: AppRoutes.signupAgency,
      page: () => const SignupAgencyView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencyAddress,
      page: () => const SignupAgencyAddressView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencyExpertise,
      page: () => const SignupAgencyExpertiseView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencySocial,
      page: () => const SignupAgencySocialView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencyKyc,
      page: () => const SignupAgencyKycView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencyTradeLicense,
      page: () => const SignupAgencyTradeLicenseView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.signupAgencyTin,
      page: () => const SignupAgencyTinView(),
      binding: SignupAgencyBinding(),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.campaignShipping,
      page: () => const CampaignShippingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CampaignShippingController>(
          () => CampaignShippingController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LanguageController>(() => LanguageController());
      }),
    ),
  ];
}
