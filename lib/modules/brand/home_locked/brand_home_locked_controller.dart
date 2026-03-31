import 'package:get/get.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/routes/app_routes.dart';

enum StepStatus { completed, inReview, pending, declined }

class ProgressStep {
  final String title;
  final String subtitle;
  final StepStatus status;
  final String? helpText;

  const ProgressStep({
    required this.title,
    required this.subtitle,
    required this.status,
    this.helpText,
  });
}

class BrandHomeLockedController extends GetxController {
  final AppUserSessionController _session =
      Get.find<AppUserSessionController>();

  final isVerificationExpanded = true.obs;
  final isProfileExpanded = true.obs;
  final isLoading = false.obs;

  final verificationSteps = <ProgressStep>[].obs;
  final profileSteps = <ProgressStep>[].obs;

  double get verificationProgress => _progressFromSteps(verificationSteps);
  double get profileProgress => _progressFromSteps(profileSteps);

  @override
  void onInit() {
    super.onInit();

    _buildStepsFromProfile();

    ever<Map<String, dynamic>?>(
      _session.brandProfileJson,
      (_) => _buildStepsFromProfile(),
    );

    Future.microtask(refreshStatus);
  }

  void _buildStepsFromProfile() {
    final json = _session.brandProfileJson.value;

    if (json == null || json.isEmpty) {
      verificationSteps.clear();
      profileSteps.clear();
      return;
    }

    final brandName = _readString(json['brandName']);
    final firstName = _readString(json['firstName']);
    final lastName = _readString(json['lastName']);
    final profileImg = _readString(json['profileImg']);
    final email = _readString(json['email']);
    final phone = _readString(json['phone']).isNotEmpty
        ? _readString(json['phone'])
        : _readString(json['primaryPhone']);

    final thana = _readString(json['thana']);
    final zilla = _readString(json['zilla']);
    final fullAddress = _readString(json['fullAddress']);
    final country = _readString(json['country']);
    final website = _readString(json['website']);

    final niches = _readList(json['niches']);
    final socialLinks = _readList(json['socialLinks']);

    final nidNumber = _readString(json['nidNumber']);
    final nidFrontImg = _readString(json['nidFrontImg']);
    final nidBackImg = _readString(json['nidBackImg']);
    final nidVerification = _readMap(json['nidVerification']);

    final tradeLicenseNumber = _readString(json['tradeLicenseNumber']);
    final tradeLicenseImg = _readString(json['tradeLicenseImg']);
    final tradeLicenseVerification = _readMap(json['tradeLicenseVerification']);

    final tinNumber = _readString(json['tinNumber']);
    final tinImage = _readString(json['tinImage']);
    final tinVerification = _readMap(json['tinVerification']);

    final binNumber = _readString(json['binNumber']);
    final binVerification = _readMap(json['binVerification']);

    final basicInfoCompleted =
        _hasText(brandName) &&
        _hasText(firstName) &&
        _hasText(lastName) &&
        _hasText(email) &&
        _hasText(phone) &&
        _hasText(thana) &&
        _hasText(zilla) &&
        _hasText(fullAddress) &&
        _hasText(country);

    final hasSocialPortfolio = socialLinks.isNotEmpty;
    final hasProfilePhoto = _hasText(profileImg);
    final hasNiches = niches.isNotEmpty;
    final hasWebsite = _hasText(website);
    final hasAddress =
        _hasText(thana) &&
        _hasText(zilla) &&
        _hasText(fullAddress) &&
        _hasText(country);

    final nidSubmitted =
        _hasText(nidNumber) || _hasText(nidFrontImg) || _hasText(nidBackImg);

    final tradeLicenseSubmitted =
        _hasText(tradeLicenseNumber) || _hasText(tradeLicenseImg);

    final tinSubmitted = _hasText(tinNumber) || _hasText(tinImage);
    final binSubmitted = _hasText(binNumber);

    verificationSteps.assignAll([
      ProgressStep(
        title: 'basic_info'.tr,
        subtitle: basicInfoCompleted
            ? 'completed'.tr
            : 'that_is_how_we_reach_you'.tr,
        status: basicInfoCompleted ? StepStatus.completed : StepStatus.pending,
      ),
      ProgressStep(
        title: 'social_portfolio'.tr,
        subtitle: hasSocialPortfolio
            ? 'completed'.tr
            : 'add_at_least_one_social'.tr,
        status: hasSocialPortfolio ? StepStatus.completed : StepStatus.pending,
      ),
      ProgressStep(
        title: 'NID',
        subtitle: _verificationSubtitle(
          hasSubmitted: nidSubmitted,
          status: _readString(nidVerification['nidStatus']),
          rejectReason: _readString(nidVerification['nidRejectReason']),
        ),
        status: _verificationStepStatus(
          hasSubmitted: nidSubmitted,
          status: _readString(nidVerification['nidStatus']),
        ),
      ),
      ProgressStep(
        title: 'trade_license'.tr,
        subtitle: _verificationSubtitle(
          hasSubmitted: tradeLicenseSubmitted,
          status: _readString(tradeLicenseVerification['tradeLicenseStatus']),
          rejectReason: _readString(
            tradeLicenseVerification['tradeLicenseRejectReason'],
          ),
        ),
        status: _verificationStepStatus(
          hasSubmitted: tradeLicenseSubmitted,
          status: _readString(tradeLicenseVerification['tradeLicenseStatus']),
        ),
      ),
      ProgressStep(
        title: 'TIN',
        subtitle: _verificationSubtitle(
          hasSubmitted: tinSubmitted,
          status: _readString(tinVerification['tinStatus']),
          rejectReason: _readString(tinVerification['tinRejectReason']),
        ),
        status: _verificationStepStatus(
          hasSubmitted: tinSubmitted,
          status: _readString(tinVerification['tinStatus']),
        ),
      ),
      ProgressStep(
        title: 'BIN',
        subtitle: _verificationSubtitle(
          hasSubmitted: binSubmitted,
          status: _readString(binVerification['binStatus']),
          rejectReason: _readString(binVerification['binRejectReason']),
        ),
        status: _verificationStepStatus(
          hasSubmitted: binSubmitted,
          status: _readString(binVerification['binStatus']),
        ),
      ),
      ProgressStep(
        title: 'verify_email'.tr,
        subtitle: json['isEmailVerified'] == true
            ? 'completed'.tr
            : 'pending'.tr,
        status: json['isEmailVerified'] == true
            ? StepStatus.completed
            : StepStatus.pending,
      ),
    ]);

    profileSteps.assignAll([
      ProgressStep(
        title: 'add_profile_picture'.tr,
        subtitle: hasProfilePhoto
            ? 'completed'.tr
            : 'that_is_how_we_reach_you'.tr,
        status: hasProfilePhoto ? StepStatus.completed : StepStatus.pending,
      ),
      // ProgressStep(
      //   title: 'add_niches'.tr,
      //   subtitle: hasNiches ? 'completed'.tr : 'pending'.tr,
      //   status: hasNiches ? StepStatus.completed : StepStatus.pending,
      //   helpText: 'niche_help_text'.tr,
      // ),
      ProgressStep(
        title: 'add_website'.tr,
        subtitle: hasWebsite ? 'completed'.tr : 'pending'.tr,
        status: hasWebsite ? StepStatus.completed : StepStatus.pending,
      ),
      ProgressStep(
        title: 'add_address'.tr,
        subtitle: hasAddress ? 'completed'.tr : 'pending'.tr,
        status: hasAddress ? StepStatus.completed : StepStatus.pending,
      ),
    ]);
  }

  Future<void> refreshStatus() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _session.preloadUserData(forceRefresh: true);
      _buildStepsFromProfile();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleVerificationSection() => isVerificationExpanded.toggle();
  void toggleProfileSection() => isProfileExpanded.toggle();

  void openVerificationGuide() {}

  void goToProfile() {
    Get.toNamed(AppRoutes.profile, id: 1);
  }

  void contactSupport() {
    Get.toNamed(AppRoutes.support, id: 1);
  }

  double _progressFromSteps(List<ProgressStep> steps) {
    if (steps.isEmpty) return 0.0;

    double total = 0;
    for (final step in steps) {
      switch (step.status) {
        case StepStatus.completed:
          total += 1.0;
          break;
        case StepStatus.inReview:
          total += 0.5;
          break;
        case StepStatus.pending:
        case StepStatus.declined:
          total += 0.0;
          break;
      }
    }

    return (total / steps.length).clamp(0.0, 1.0);
  }

  StepStatus _verificationStepStatus({
    required bool hasSubmitted,
    required String status,
  }) {
    if (!hasSubmitted) return StepStatus.pending;

    switch (status.toLowerCase()) {
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

  String _verificationSubtitle({
    required bool hasSubmitted,
    required String status,
    required String rejectReason,
  }) {
    if (!hasSubmitted) return 'pending'.tr;

    switch (status.toLowerCase()) {
      case 'approved':
        return 'verified'.tr;
      case 'pending':
        return 'in_review'.tr;
      case 'rejected':
        return _hasText(rejectReason) ? rejectReason : 'declined'.tr;
      default:
        return 'pending'.tr;
    }
  }

  List<dynamic> _readList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  bool _hasText(String value) => value.trim().isNotEmpty;
}

class BrandHomeLockedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandHomeLockedController>(() => BrandHomeLockedController());
  }
}
