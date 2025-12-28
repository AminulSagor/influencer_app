import 'package:get/get.dart';
import '../enums/account_type.dart';

class AccountTypeService extends GetxService {
  /// null = not selected yet
  final Rxn<AccountType> _currentType = Rxn<AccountType>();

  AccountType? get currentType => _currentType.value;

  bool get isBrand => _currentType.value == AccountType.brand;
  bool get isInfluencer => _currentType.value == AccountType.influencer;
  bool get isAdAgency => _currentType.value == AccountType.adAgency;
  bool get hasSelectedRole => _currentType.value != null;

  /// Change role (pass null to reset)
  void setRole(AccountType? type) {
    _currentType.value = type;
  }
}
