import 'package:get/get.dart';

class HomeController extends GetxController {
  RxString imageUrl = ''.obs;
  RxString uname = ''.obs;
  RxString mid = ''.obs;
}

final HomeController homeController = Get.put(HomeController());
