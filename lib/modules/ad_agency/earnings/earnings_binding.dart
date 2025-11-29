import 'package:get/get.dart';
import 'earnings_controller.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsController>(() => EarningsController());
  }
}
