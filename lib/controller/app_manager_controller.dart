import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

/// pm 命令
/// -U 显示 uid
/// -f 显示相关路径
/// -3 显示三方app
/// -u 显示已卸载的app
/// -d 只显示被禁用的app
class AppManagerController extends GetxController {
  AppManagerController() {}
  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
    }
    isInit = true;
    await getUserApp();
    await getSysApp();
    cacheUserIcon();
  }

  //用户应用
  List<AppInfo> _userApps = <AppInfo>[];
  //系统应用
  List<AppInfo> _sysApps = <AppInfo>[];
  List<AppInfo> get userApps => _userApps;
  List<AppInfo> get sysApps => _sysApps;

  Future<void> getUserApp() async {
    _userApps = await AppUtils.getAllAppInfo(
      appChannel: Global().appChannel,
    );
    update();
  }

  Future<void> cacheSysIcon() async {
    List<String> packages = [];
    packages.clear();
    for (AppInfo info in _sysApps) {
      packages.add(info.packageName);
    }
    // await cacheAllUserIcons(packages, Global().appChannel);
  }

  Future<void> cacheUserIcon() async {
    List<String> packages = [];
    packages.clear();
    for (AppInfo info in _userApps) {
      packages.add(info.packageName);
    }
    // await cacheAllUserIcons(packages, Global().appChannel);
  }

  Future<void> getSysApp() async {
    _sysApps = await AppUtils.getAllAppInfo(
      appType: AppType.system,
      appChannel: Global().appChannel,
    );
    update();
  }

  void removeEntity(AppInfo entity) {
    if (_userApps.contains(entity)) {
      _userApps.remove(entity);
    }
    if (_sysApps.contains(entity)) {
      _userApps.remove(entity);
    }
    update();
  }
}
