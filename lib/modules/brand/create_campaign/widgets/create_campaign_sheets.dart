// lib/modules/brand/create_campaign/widgets/create_campaign_sheets.dart
part of '../create_campaign_controller.dart';

class CreateCampaignSheets {
  static void openSimplePicker({
    required String title,
    required List<String> options,
    required String? selected,
    required void Function(String) onSelect,
  }) {
    Get.bottomSheet(
      _SimplePickerSheet(
        title: title,
        options: options,
        selected: selected,
        onSelect: (v) {
          onSelect(v);
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void openInfluencerPicker({
    required String title,
    required List<InfluencerUiModel> items,
    required RxList<String> selectedIds,
    required void Function(InfluencerUiModel) onToggle,
  }) {
    Get.bottomSheet(
      _InfluencerPickerSheet(
        title: title,
        items: items,
        selectedIds: selectedIds,
        onToggle: onToggle,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _SimplePickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  const _SimplePickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              12.h.verticalSpace,
              ...options.map((e) {
                final active = e == selected;
                return ListTile(
                  title: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: active
                      ? Icon(Icons.check_circle, size: 20.sp)
                      : null,
                  onTap: () => onSelect(e),
                );
              }),
              8.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfluencerPickerSheet extends StatefulWidget {
  final String title;
  final List<InfluencerUiModel> items;
  final RxList<String> selectedIds;
  final void Function(InfluencerUiModel) onToggle;

  const _InfluencerPickerSheet({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  State<_InfluencerPickerSheet> createState() => _InfluencerPickerSheetState();
}

class _InfluencerPickerSheetState extends State<_InfluencerPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            12.h.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            8.h.verticalSpace,
            Flexible(
              child: Obx(() {
                final selected = widget.selectedIds.toList(growable: false);
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? items
                    : items
                          .where((e) => e.name.toLowerCase().contains(query))
                          .toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No results',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final isSelected = selected.contains(item.id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: item.rating == null
                          ? null
                          : Text('★ ${item.rating!.toStringAsFixed(1)}'),
                      onChanged: (_) => widget.onToggle(item),
                    );
                  },
                );
              }),
            ),
            8.h.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('common_done'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
