import 'package:get/get.dart';
import 'number_formatter.dart';

String localizeDueLabel(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return 'common_no_deadline'.tr;

  if (s.toLowerCase().contains('tomorrow')) {
    return 'label_due_tomorrow'.tr;
  }

  final match = RegExp(r'(\d+)').firstMatch(s);
  if (match != null) {
    final days = int.tryParse(match.group(1) ?? '') ?? 0;
    return 'label_due_days'.trParams({'days': formatNumberByLocale(days)});
  }

  return s; // fallback
}

String localizeDaysRemainingFromDue(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return 'common_no_deadline'.tr;

  if (s.toLowerCase().contains('tomorrow')) {
    return 'label_days_remaining'.trParams({'days': formatNumberByLocale(1)});
  }

  final match = RegExp(r'(\d+)').firstMatch(s);
  if (match != null) {
    final days = int.tryParse(match.group(1) ?? '') ?? 0;
    return 'label_days_remaining'.trParams({
      'days': formatNumberByLocale(days),
    });
  }

  return 'common_no_deadline'.tr;
}
