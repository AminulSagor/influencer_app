import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/explore_item.dart';
import 'services/explore_service.dart';

class ExploreController extends GetxController {
  final ExploreService _api = Get.find<ExploreService>();

  final selectedType = ExploreType.influencer.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final items = <ExploreItem>[].obs;

  final totalResults = 0.obs;
  final totalPages = 1.obs;
  final currentPage = 1.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final ScrollController scrollController = ScrollController();

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadFirstPage();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void changeType(ExploreType type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    loadFirstPage();
  }

  void onSearchChanged(String v) {
    searchQuery.value = v;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadFirstPage();
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final pos = scrollController.position.pixels;
    if (max <= 0) return;
    if (pos >= max - 120) {
      loadMore();
    }
  }

  Future<void> refreshPage() async {
    _debounce?.cancel();
    await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    if (isLoading.value || isLoadingMore.value) return;

    hasMore.value = true;
    currentPage.value = 1;
    items.clear();
    totalResults.value = 0;
    totalPages.value = 1;

    await _fetchPage(1, resetOnError: true);
  }

  Future<void> prevPage() async {
    if (isLoading.value) return;
    final targetPage = currentPage.value - 1;
    if (targetPage < 1) return;
    await _fetchPage(targetPage);
  }

  Future<void> nextPage() async {
    if (isLoading.value) return;
    final targetPage = currentPage.value + 1;
    if (targetPage > totalPages.value) return;
    await _fetchPage(targetPage);
  }

  Future<void> _fetchPage(int page, {bool resetOnError = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final res = await _api.fetch(
        type: selectedType.value,
        query: searchQuery.value,
        page: page,
      );

      final normalizedTotal = res.totalPages < 1 ? 1 : res.totalPages;
      final normalizedPage = page < 1
          ? 1
          : (page > normalizedTotal ? normalizedTotal : page);

      items.assignAll(res.items);
      totalResults.value = res.totalResults;
      totalPages.value = normalizedTotal;
      currentPage.value = normalizedPage;
      hasMore.value = normalizedPage < normalizedTotal;
    } catch (_) {
      if (resetOnError) {
        items.clear();
        totalResults.value = 0;
        totalPages.value = 1;
        currentPage.value = 1;
        hasMore.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value) return;
    if (!hasMore.value) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final res = await _api.fetch(
        type: selectedType.value,
        query: searchQuery.value,
        page: nextPage,
      );

      if (res.items.isNotEmpty) {
        items.addAll(res.items);
      }

      final normalizedTotal = res.totalPages < 1 ? 1 : res.totalPages;

      totalResults.value = res.totalResults;
      totalPages.value = normalizedTotal;
      currentPage.value = nextPage < 1
          ? 1
          : (nextPage > normalizedTotal ? normalizedTotal : nextPage);
      hasMore.value = currentPage.value < normalizedTotal;
    } catch (_) {
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
