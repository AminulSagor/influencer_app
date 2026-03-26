import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/controllers/app_user_session_controller.dart';
import 'package:influencer_app/core/models/job_item.dart';
import 'package:influencer_app/core/models/location_models.dart';
import 'package:influencer_app/core/services/api_error_handler.dart';
import 'package:influencer_app/core/services/campaign_service.dart';
import 'package:influencer_app/core/services/location_service.dart';
import 'package:influencer_app/modules/influencer/models/influencer_profile_model.dart';
import 'package:influencer_app/modules/influencer/services/influencer_profile_service.dart';

import '../../../core/widgets/reason_bottom_sheet.dart';
import 'campaign_shipping_view.dart';

class CampaignShippingController extends GetxController {
  final dynamic arguments;
  CampaignShippingController(this.arguments);

  late final JobItem job;

  final AppUserSessionController _session =
      Get.find<AppUserSessionController>();
  final CampaignService _campaignService = Get.find<CampaignService>();
  final InfluencerProfileService _influencerProfileService =
      Get.find<InfluencerProfileService>();

  final RxInt selectedIndex = (-1).obs;
  final RxBool hasReadTerms = false.obs;
  final RxBool acceptsTerms = false.obs;
  final RxBool isAcceptLoading = false.obs;
  final RxBool isAddressSaving = false.obs;
  final RxBool isAddressLoading = false.obs;

  final RxList<InfluencerAddress> addresses = <InfluencerAddress>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (arguments is! JobItem) {
      throw 'CampaignShipping requires JobItem in Get.arguments';
    }

    job = arguments as JobItem;
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    if (isAddressLoading.value) return;

    isAddressLoading.value = true;
    try {
      final result = await _influencerProfileService.getInfluencerAddresses();

      if (!result.isSuccess || result.data == null) return;

      final fetchedAddresses = result.data!;

      addresses.assignAll(fetchedAddresses);

      final profile = _session.influencerProfile.value;
      if (profile != null) {
        _session.influencerProfile.value = profile.copyWith(
          addresses: fetchedAddresses,
        );
      }

      _syncSelectedIndex();
    } finally {
      isAddressLoading.value = false;
    }
  }

  void _syncSelectedIndex({String? preferredAddressName}) {
    if (addresses.isEmpty) {
      selectedIndex.value = -1;
      return;
    }

    if (preferredAddressName != null &&
        preferredAddressName.trim().isNotEmpty) {
      final preferredIndex = addresses.indexWhere(
        (a) => (a.addressName ?? '').trim() == preferredAddressName.trim(),
      );
      if (preferredIndex >= 0) {
        selectedIndex.value = preferredIndex;
        return;
      }
    }

    final defaultIndex = addresses.indexWhere((a) => a.isDefault);
    selectedIndex.value = defaultIndex >= 0 ? defaultIndex : 0;
  }

  InfluencerAddress? get selectedAddress {
    final index = selectedIndex.value;
    if (index < 0 || index >= addresses.length) return null;
    return addresses[index];
  }

  void onAddressSelected(int index) {
    if (index < 0 || index >= addresses.length) return;
    selectedIndex.value = index;
  }

  void toggleReadTerms(bool? value) {
    hasReadTerms.value = value ?? false;
  }

  void toggleAcceptTerms(bool? value) {
    acceptsTerms.value = value ?? false;
  }

  Future<void> onAddAnotherPressed() async {
    if (isAddressSaving.value) return;

    final result = await Get.dialog<InfluencerAddress>(
      const AddressFormDialog(),
      barrierDismissible: false,
    );

    if (result == null) return;

    isAddressSaving.value = true;
    try {
      final savedAddressName = (result.addressName?.trim().isNotEmpty ?? false)
          ? result.addressName!.trim()
          : 'Custom';

      final apiResult = await _influencerProfileService.addAddress(
        addressName: savedAddressName,
        thana: result.thana?.trim() ?? '',
        zilla: result.zilla?.trim() ?? '',
        fullAddress: result.fullAddress?.trim() ?? '',
        isDefault: result.isDefault,
      );

      if (!apiResult.isSuccess) return;

      await _fetchAddresses();
      _syncSelectedIndex(preferredAddressName: savedAddressName);

      Get.snackbar(
        'shipping_success_title'.tr,
        'shipping_address_added_success'.tr,
      );
    } finally {
      isAddressSaving.value = false;
    }
  }

  Future<void> onEditPressed(int index) async {
    if (isAddressSaving.value) return;
    if (index < 0 || index >= addresses.length) return;

    final initial = addresses[index];

    final result = await Get.dialog<InfluencerAddress>(
      AddressFormDialog(initial: initial),
      barrierDismissible: false,
    );

    if (result == null) return;

    final currentAddressName = initial.addressName?.trim();
    if (currentAddressName == null || currentAddressName.isEmpty) {
      Get.snackbar(
        'shipping_error_title'.tr,
        'shipping_address_edit_name_missing'.tr,
      );
      return;
    }

    isAddressSaving.value = true;
    try {
      final updatedAddressName =
          (result.addressName?.trim().isNotEmpty ?? false)
          ? result.addressName!.trim()
          : currentAddressName;

      final apiResult = await _influencerProfileService.updateAddress(
        currentAddressName: currentAddressName,
        addressName: updatedAddressName,
        thana: result.thana?.trim() ?? '',
        zilla: result.zilla?.trim() ?? '',
        fullAddress: result.fullAddress?.trim() ?? '',
        isDefault: result.isDefault,
      );

      if (!apiResult.isSuccess) return;

      await _fetchAddresses();
      _syncSelectedIndex(preferredAddressName: updatedAddressName);

      Get.snackbar(
        'shipping_success_title'.tr,
        'shipping_address_updated_success'.tr,
      );
    } finally {
      isAddressSaving.value = false;
    }
  }

  Future<void> onDeclinePressed() async {
    final jobId = job.id?.trim();
    if (jobId == null || jobId.isEmpty) {
      Get.snackbar('shipping_error_title'.tr, 'campaign_missing_id'.tr);
      return;
    }

    final reason = await showReasonBottomSheet(
      title: 'jobs_decline_reason_title'.tr,
      hintText: 'jobs_decline_reason_hint'.tr,
      submitText: 'jobs_decline_submit'.tr,
    );

    if (reason == null || reason.trim().isEmpty) return;

    if (isAcceptLoading.value) return;

    isAcceptLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _campaignService.declineInfluencerJobOffer(
          jobId: jobId,
          reason: reason,
        ),
      );

      if (result.isSuccess) {
        Get.back(id: 1, result: {'declined': true});
      }
    } finally {
      isAcceptLoading.value = false;
    }
  }

  Map<String, dynamic>? _buildAcceptPayloadFromSelectedAddress() {
    if (!(job.needToSendSample == true)) return null;

    final address = selectedAddress;
    if (address == null) return null;

    return {
      'addressName': (address.addressName ?? '').trim(),
      'thana': (address.thana ?? '').trim(),
      'zilla': (address.zilla ?? '').trim(),
      'fullAddress': (address.fullAddress ?? '').trim(),
    };
  }

  Future<void> onAcceptPressed() async {
    if (!hasReadTerms.value) {
      Get.snackbar('shipping_error_title'.tr, 'shipping_confirm_read_terms'.tr);
      return;
    }

    if (!acceptsTerms.value) {
      Get.snackbar(
        'shipping_error_title'.tr,
        'shipping_accept_license_terms'.tr,
      );
      return;
    }

    if (selectedAddress == null) {
      Get.snackbar(
        'shipping_error_title'.tr,
        'shipping_select_address_error'.tr,
      );
      return;
    }

    final jobId = job.id?.trim();
    if (jobId == null || jobId.isEmpty) {
      Get.snackbar('shipping_error_title'.tr, 'campaign_missing_id'.tr);
      return;
    }

    if (isAcceptLoading.value) return;

    isAcceptLoading.value = true;
    try {
      final payload = _buildAcceptPayloadFromSelectedAddress();

      final result = await ApiErrorHandler.call(
        () => _campaignService.acceptInfluencerJobOffer(
          jobId: jobId,
          payload: payload,
        ),
      );

      if (result.isSuccess) {
        Get.back(id: 1, result: true);
      }
    } finally {
      isAcceptLoading.value = false;
    }
  }
}

class AddressFormController extends GetxController {
  final InfluencerAddress? initial;

  AddressFormController({this.initial});

  final LocationService _locationService = Get.find<LocationService>();

  late final TextEditingController nameCtrl;
  late final TextEditingController fullAddressCtrl;

  final RxBool isDefault = false.obs;
  final RxBool isLoadingZillas = false.obs;
  final RxBool isLoadingThanas = false.obs;

  final RxList<ZillaModel> zillas = <ZillaModel>[].obs;
  final RxList<ThanaModel> thanas = <ThanaModel>[].obs;

  final RxnString selectedZillaKey = RxnString();
  final RxnString selectedZillaId = RxnString();
  final RxnString selectedThanaKey = RxnString();
  final RxnString selectedThanaId = RxnString();

  List<String> get zillaOptions =>
      zillas.map((e) => e.displayName).toList(growable: false);

  List<String> get thanaOptions =>
      thanas.map((e) => e.displayName).toList(growable: false);

  @override
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController(text: initial?.addressName ?? '');
    fullAddressCtrl = TextEditingController(text: initial?.fullAddress ?? '');
    isDefault.value = initial?.isDefault ?? false;

    selectedZillaKey.value = initial?.zilla;
    selectedThanaKey.value = initial?.thana;

    loadZillas();
  }

  Future<void> loadZillas() async {
    if (isLoadingZillas.value) return;
    isLoadingZillas.value = true;

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllZillas(),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      zillas.assignAll(result.data!);

      if (selectedZillaKey.value != null &&
          selectedZillaKey.value!.trim().isNotEmpty) {
        final matchedZilla = zillas.firstWhereOrNull(
          (e) => e.displayName == selectedZillaKey.value,
        );

        if (matchedZilla != null) {
          selectedZillaId.value = matchedZilla.id;
          await loadThanasByZilla(
            matchedZilla.id,
            preselectedThanaName: selectedThanaKey.value,
          );
        } else {
          selectedZillaKey.value = null;
          selectedThanaKey.value = null;
          selectedZillaId.value = null;
          selectedThanaId.value = null;
          thanas.clear();
        }
      }
    }

    isLoadingZillas.value = false;
  }

  Future<void> loadThanasByZilla(
    String zillaId, {
    String? preselectedThanaName,
  }) async {
    if (isLoadingThanas.value) return;
    isLoadingThanas.value = true;

    final result = await ApiErrorHandler.call(
      () => _locationService.fetchAllThanasByZilla(zillaId: zillaId),
      showError: false,
    );

    if (result.isSuccess && result.data != null) {
      thanas.assignAll(result.data!);

      if (preselectedThanaName != null &&
          preselectedThanaName.trim().isNotEmpty) {
        final matchedThana = thanas.firstWhereOrNull(
          (e) => e.displayName == preselectedThanaName,
        );
        selectedThanaKey.value = matchedThana?.displayName;
        selectedThanaId.value = matchedThana?.id;
      }
    }

    isLoadingThanas.value = false;
  }

  void toggleDefault() => isDefault.toggle();

  Future<void> setZilla(String? value) async {
    selectedZillaKey.value = value;
    selectedThanaKey.value = null;
    selectedThanaId.value = null;
    thanas.clear();

    if (value == null || value.trim().isEmpty) {
      selectedZillaId.value = null;
      return;
    }

    final matchedZilla = zillas.firstWhereOrNull((e) => e.displayName == value);

    selectedZillaId.value = matchedZilla?.id;

    if (matchedZilla != null) {
      await loadThanasByZilla(matchedZilla.id);
    }
  }

  void setThana(String? value) {
    selectedThanaKey.value = value;

    if (value == null || value.trim().isEmpty) {
      selectedThanaId.value = null;
      return;
    }

    final matchedThana = thanas.firstWhereOrNull((e) => e.displayName == value);
    selectedThanaId.value = matchedThana?.id;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    fullAddressCtrl.dispose();
    super.onClose();
  }

  void save() {
    final label = nameCtrl.text.trim();
    final fullAddress = fullAddressCtrl.text.trim();

    if (selectedZillaKey.value == null ||
        selectedZillaKey.value!.trim().isEmpty) {
      Get.snackbar(
        'shipping_address_form_error_title'.tr,
        'shipping_address_form_error_thana_zilla_required'.tr,
      );
      return;
    }

    if (selectedThanaKey.value == null ||
        selectedThanaKey.value!.trim().isEmpty) {
      Get.snackbar(
        'shipping_address_form_error_title'.tr,
        'shipping_address_form_error_thana_zilla_required'.tr,
      );
      return;
    }

    if (fullAddress.isEmpty) {
      Get.snackbar(
        'shipping_address_form_error_title'.tr,
        'shipping_address_form_error_full_required'.tr,
      );
      return;
    }

    final result = InfluencerAddress(
      addressName: label.isEmpty ? 'Custom' : label,
      thana: selectedThanaKey.value,
      zilla: selectedZillaKey.value,
      country: 'Bangladesh',
      fullAddress: fullAddress,
      isDefault: isDefault.value,
    );

    Get.back(result: result);
  }
}
