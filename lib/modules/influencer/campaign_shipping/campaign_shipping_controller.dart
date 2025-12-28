import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'campaign_shipping_view.dart';

class ShippingAddress {
  final String labelKey; // can be a translation key or plain text
  final String address; // full address line
  final bool isDefault;

  ShippingAddress({
    required this.labelKey,
    required this.address,
    this.isDefault = false,
  });

  ShippingAddress copyWith({
    String? labelKey,
    String? address,
    bool? isDefault,
  }) {
    return ShippingAddress(
      labelKey: labelKey ?? this.labelKey,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class CampaignShippingController extends GetxController {
  /// Selected address index; -1 means nothing selected.
  final RxInt selectedIndex = 0.obs;

  /// Terms checkboxes
  final RxBool hasReadTerms = false.obs;
  final RxBool acceptsTerms = false.obs;

  /// Dummy data for now – later you can load from backend.
  final RxList<ShippingAddress> addresses = <ShippingAddress>[
    ShippingAddress(
      labelKey: 'shipping_address_house',
      address: 'House 61, Road 8, Block F, Banani, Dhaka 1213',
      isDefault: true,
    ),
    ShippingAddress(
      labelKey: 'shipping_address_office',
      address: 'Road No 7A, Banani, Dhaka 1213',
    ),
  ].obs;

  void onAddressSelected(int index) {
    selectedIndex.value = index;
  }

  void toggleReadTerms(bool? value) {
    hasReadTerms.value = value ?? false;
  }

  void toggleAcceptTerms(bool? value) {
    acceptsTerms.value = value ?? false;
  }

  /// Ensure only one address is default at a time
  ShippingAddress _applyDefaultRules(
    ShippingAddress newAddress, {
    int? editingIndex,
  }) {
    if (!newAddress.isDefault) return newAddress;

    for (var i = 0; i < addresses.length; i++) {
      if (editingIndex != null && i == editingIndex) continue;
      final a = addresses[i];
      if (a.isDefault) {
        addresses[i] = a.copyWith(isDefault: false);
      }
    }
    return newAddress;
  }

  Future<void> onAddAnotherPressed() async {
    final result = await Get.dialog<ShippingAddress>(
      AddressFormDialog(), // no initial
      barrierDismissible: false,
    );

    if (result != null) {
      final saved = _applyDefaultRules(result);
      addresses.add(saved);
      selectedIndex.value = addresses.length - 1;
    }
  }

  /// Open form pre-filled for edit
  Future<void> onEditPressed(int index) async {
    final initial = addresses[index];

    final result = await Get.dialog<ShippingAddress>(
      AddressFormDialog(initial: initial),
      barrierDismissible: false,
    );

    if (result != null) {
      final updated = _applyDefaultRules(result, editingIndex: index);
      addresses[index] = updated;

      if (updated.isDefault) {
        selectedIndex.value = index;
      }
    }
  }

  void onDeclinePressed() {
    // TODO: handle decline flow
  }

  void onAcceptPressed() {
    // TODO: validate & proceed
  }
}

class AddressFormController extends GetxController {
  final ShippingAddress? initial;

  AddressFormController({this.initial});

  // text controllers
  late final TextEditingController nameCtrl;
  late final TextEditingController fullAddressCtrl;

  // default toggle
  final RxBool isDefault = false.obs;

  // ----- dropdown data -----
  // store **translation keys** so UI can use `.tr`
  final List<String> thanaKeys = [
    'shipping_thana_banani',
    'shipping_thana_gulshan',
    'shipping_thana_dhanmondi',
    'shipping_thana_mirpur',
  ];

  final List<String> zillaKeys = [
    'shipping_zilla_dhaka',
    'shipping_zilla_chattogram',
    'shipping_zilla_sylhet',
    'shipping_zilla_rajshahi',
  ];

  final RxnString selectedThanaKey = RxnString();
  final RxnString selectedZillaKey = RxnString();

  @override
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController(
      text: initial != null ? initial!.labelKey.tr : '',
    );

    fullAddressCtrl = TextEditingController(text: initial?.address ?? '');
    isDefault.value = initial?.isDefault ?? false;

    // if you ever store thana/zilla in the model later,
    // you can pre-select them here.
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    fullAddressCtrl.dispose();
    super.onClose();
  }

  void toggleDefault() => isDefault.toggle();

  void setThana(String? key) {
    selectedThanaKey.value = key;
  }

  void setZilla(String? key) {
    selectedZillaKey.value = key;
  }

  void save() {
    final label = nameCtrl.text.trim();
    final fullAddress = fullAddressCtrl.text.trim();

    if (selectedThanaKey.value == null || selectedZillaKey.value == null) {
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

    final result = ShippingAddress(
      // if label empty, fall back to a generic translated label
      labelKey: label.isEmpty ? 'shipping_address_custom'.tr : label,
      address: fullAddress,
      isDefault: isDefault.value,
    );

    Get.back(result: result);
  }
}
