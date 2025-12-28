// lib/modules/ad_agency/home_locked/home_locked_controller.dart
import 'package:get/get.dart';
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

class BrandHomeLockedController extends GetxController {
  /// For now this is just a flag – later you can flip it
  /// and route to the unlocked home/dashboard.
  final isVerified = false.obs;

  // Expand / collapse
  final isVerificationExpanded = true.obs;
  final isProfileExpanded = true.obs;

  // Fake progress values (0–1)
  final verificationProgress = 0.45.obs;
  final profileProgress = 0.30.obs;

  // ---- Data for the 2 timelines ----
  final List<ProgressStep> verificationSteps = const [
    ProgressStep(
      title: 'Basic Informations', // 'home_locked_basic_info'.tr
      subtitle: 'That’s how we are going to reach you',
      status: StepStatus.completed,
    ),
    ProgressStep(
      title: 'Social Portfolio',
      subtitle: '1 Added · You can always add more',
      status: StepStatus.completed,
    ),
    ProgressStep(
      title: 'NID',
      subtitle: 'In Review',
      status: StepStatus.inReview,
    ),
    ProgressStep(
      title: 'Trade License',
      subtitle:
          'Declined, document details don\'t match with the provided information',
      status: StepStatus.declined,
    ),
    ProgressStep(title: 'TIN', subtitle: 'Pending', status: StepStatus.pending),
    ProgressStep(title: 'BIN', subtitle: 'Pending', status: StepStatus.pending),
    ProgressStep(
      title: 'Payment Setup',
      subtitle: 'Pending',
      status: StepStatus.pending,
    ),
    ProgressStep(
      title: 'Verify Email',
      subtitle: 'Pending',
      status: StepStatus.pending,
    ),
  ];

  final List<ProgressStep> profileSteps = const [
    ProgressStep(
      title: 'Add Profile Picture',
      subtitle: 'That’s how we are going to reach you',
      status: StepStatus.completed,
    ),
    ProgressStep(
      title: 'Add Niches',
      subtitle: 'Pending',
      status: StepStatus.pending,
      helpText:
          'A niche is a focused area of interest, need, or demographic that an influencer or agency focuses on exclusively.',
    ),
    ProgressStep(
      title: 'Add Skills',
      subtitle: 'Pending',
      status: StepStatus.pending,
      helpText:
          'To be a successful agency, you need a mix of creative, technical, interpersonal, and business skills.',
    ),
    ProgressStep(
      title: 'Add Bio',
      subtitle: 'Pending',
      status: StepStatus.pending,
    ),
  ];

  // ---- Actions ----
  void toggleVerificationSection() => isVerificationExpanded.toggle();

  void toggleProfileSection() => isProfileExpanded.toggle();

  void openVerificationGuide() {
    // TODO: navigate to verification guide page
  }

  void contactSupport() {
    Get.toNamed(AppRoutes.support, id: 1);
  }
}

class BrandHomeLockedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandHomeLockedController>(() => BrandHomeLockedController());
  }
}
