import 'package:app_manager/bindings/app_manager_binding.dart';
import 'package:app_manager/core/implement/local_app_channel.dart';
import 'package:app_manager/core/implement/remote_app_channel.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'config.dart';

class Global {
  // 工厂模式

  factory Global() => _getInstance();
  Global._internal() {
    appChannel = LocalAppChannel();

  }

  static Global get instance => _getInstance();

  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  AppChannel appChannel;
  Map<String, List<int>> iconCacheMap = {};
  YanProcess process = YanProcess();

  Future<String> exec(String script) {
    return process.exec(script);
  }
}
