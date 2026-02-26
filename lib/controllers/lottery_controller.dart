import 'package:get/get.dart';

class LotteryController extends GetxController {
  RxBool isLoading = false.obs;
  RxString title = ''.obs;
  RxInt total = 0.obs;
}

final LotteryController lotteryController = Get.put(LotteryController());
