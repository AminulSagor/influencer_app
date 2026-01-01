import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/explore_item.dart';
import 'services/explore_mock_api.dart';

class ExploreController extends GetxController {
  final _api = ExploreMockApi();

  final selectedType = ExploreType.influencer.obs;

  final isLoading = false.obs;
  final items = <ExploreItem>[].obs;

  final totalResults = 0.obs;
  final totalPages = 1.obs;
  final currentPage = 1.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadPage(1);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void changeType(ExploreType type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    currentPage.value = 1;
    loadPage(1);
  }

  void onSearchChanged(String v) {
    searchQuery.value = v;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      currentPage.value = 1;
      loadPage(1);
    });
  }

  Future<void> loadPage(int page) async {
    isLoading.value = true;
    try {
      final res = await _api.fetch(
        type: selectedType.value,
        query: searchQuery.value,
        page: page,
      );
      items.assignAll(res.items);
      totalResults.value = res.totalResults;
      totalPages.value = res.totalPages;
      currentPage.value = page.clamp(1, res.totalPages);
    } catch (_) {
      items.clear();
      totalResults.value = 0;
      totalPages.value = 1;
      currentPage.value = 1;
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (isLoading.value) return;
    if (currentPage.value >= totalPages.value) return;
    loadPage(currentPage.value + 1);
  }

  void prevPage() {
    if (isLoading.value) return;
    if (currentPage.value <= 1) return;
    loadPage(currentPage.value - 1);
  }
}
