import 'package:app_channel/app_channel.dart';
import 'package:get/get.dart';

class CheckController extends GetxController {
  List<AppInfo?> check = [];

  void addCheck(AppInfo? entity) {
    check.add(entity);
    update();
  }

  void removeCheck(AppInfo? entity) {
    check.remove(entity);
    update();
  }

  void clearCheck() {
    check.clear();
    update();
  }
}
