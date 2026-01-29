// lib/modules/influencer/home_locked/influencer_home_locked_controller.dart
import 'package:get/get.dart';
import 'package:influencer_app/core/services/onboarding_check_service.dart';
import 'package:influencer_app/routes/app_routes.dart';

enum StepStatus { completed, inReview, pending, declined }

class ProgressStep {
  final String title;
  final String subtitle;
  final StepStatus status;

  /// Optional help text for the profile card question mark.
  final String? helpText;

  const ProgressStep({
    required this.title,
    required this.subtitle,
    required this.status,
    this.helpText,
  });
}

class InfluencerHomeLockedController extends GetxController {
  final _onboardingService = Get.find<OnboardingCheckService>();

  // Expand / collapse
  final isVerificationExpanded = true.obs;
  final isProfileExpanded = true.obs;

  // Loading state
  final isLoading = false.obs;

  // Reactive lists for steps
  final verificationSteps = <ProgressStep>[].obs;
  final profileSteps = <ProgressStep>[].obs;

  // Progress values (0–1)
  double get verificationProgress =>
      _onboardingService.status.value?.influencerVerificationProgress ?? 0.0;
  double get profileProgress =>
      _onboardingService.status.value?.profileProgress ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    _buildStepsFromStatus();

    // Listen for status changes
    ever(_onboardingService.status, (_) => _buildStepsFromStatus());
  }

  void _buildStepsFromStatus() {
    final status = _onboardingService.status.value;
    if (status == null) return;

    // Build verification steps
    verificationSteps.value = [
      ProgressStep(
        title: 'basic_info'.tr,
        subtitle: status.hasAddress
            ? 'completed'.tr
            : 'that_is_how_we_reach_you'.tr,
        status: status.hasAddress ? StepStatus.completed : StepStatus.pending,
      ),
      ProgressStep(
        title: 'social_portfolio'.tr,
        subtitle: status.hasSocialLinks
            ? 'completed'.tr
            : 'add_at_least_one_social'.tr,
        status: status.hasSocialLinks
            ? StepStatus.completed
            : StepStatus.pending,
      ),
      ProgressStep(
        title: 'NID',
        subtitle: _getNidSubtitle(status),
        status: _getNidStatus(status),
      ),
      ProgressStep(
        title: 'payment_setup'.tr,
        subtitle: status.hasPayoutSetup ? 'completed'.tr : 'pending'.tr,
        status: status.hasPayoutSetup
            ? StepStatus.completed
            : StepStatus.pending,
      ),
      ProgressStep(
        title: 'verify_email'.tr,
        subtitle: status.isEmailVerified ? 'completed'.tr : 'pending'.tr,
        status: status.isEmailVerified
            ? StepStatus.completed
            : StepStatus.pending,
      ),
    ];

    // Build profile steps (optional, for profile completion)
    profileSteps.value = [
      ProgressStep(
        title: 'add_profile_picture'.tr,
        subtitle: status.hasProfileImage
            ? 'completed'.tr
            : 'that_is_how_we_reach_you'.tr,
        status: status.hasProfileImage
            ? StepStatus.completed
            : StepStatus.pending,
      ),
      ProgressStep(
        title: 'add_niches'.tr,
        subtitle: status.hasNiches ? 'completed'.tr : 'pending'.tr,
        status: status.hasNiches ? StepStatus.completed : StepStatus.pending,
        helpText: 'niche_help_text'.tr,
      ),
      ProgressStep(
        title: 'add_skills'.tr,
        subtitle: status.hasSkills ? 'completed'.tr : 'pending'.tr,
        status: status.hasSkills ? StepStatus.completed : StepStatus.pending,
        helpText: 'skills_help_text'.tr,
      ),
      ProgressStep(
        title: 'add_bio'.tr,
        subtitle: status.hasBio ? 'completed'.tr : 'pending'.tr,
        status: status.hasBio ? StepStatus.completed : StepStatus.pending,
      ),
    ];
  }

  String _getNidSubtitle(OnboardingStatus status) {
    if (!status.hasNidSubmitted) return 'pending'.tr;
    switch (status.nidStatus) {
      case 'approved':
        return 'verified'.tr;
      case 'pending':
        return 'in_review'.tr;
      case 'rejected':
        return 'declined'.tr;
      default:
        return 'pending'.tr;
    }
  }

  StepStatus _getNidStatus(OnboardingStatus status) {
    if (!status.hasNidSubmitted) return StepStatus.pending;
    switch (status.nidStatus) {
      case 'approved':
        return StepStatus.completed;
      case 'pending':
        return StepStatus.inReview;
      case 'rejected':
        return StepStatus.declined;
      default:
        return StepStatus.pending;
    }
  }

  // ---- Actions ----
  void toggleVerificationSection() => isVerificationExpanded.toggle();

  void toggleProfileSection() => isProfileExpanded.toggle();

  Future<void> refreshStatus() async {
    isLoading.value = true;
    await _onboardingService.fetchOnboardingStatus();
    isLoading.value = false;
  }

  void openVerificationGuide() {
    // TODO: navigate to verification guide page
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile, id: 1);
  }

  void contactSupport() {
    Get.toNamed(AppRoutes.support, id: 1);
  }
}

class InfluencerHomeLockedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InfluencerHomeLockedController>(
      () => InfluencerHomeLockedController(),
    );
  }
}
