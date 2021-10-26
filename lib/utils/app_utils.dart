import 'dart:io';

import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/config.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');
int port = 6000;
enum AppType {
  user,
  system,
}

// 根据文件头将一维数组缓拆分成二维数组
Future<void> cacheAllUserIcons(
  List<String> packages,
  AppChannel appChannel,
) async {
  // 所有图
  final List<List<int>> byteList =
      await appChannel.getAllAppIconBytes(packages);
  // Log.e('allBytes -> $allBytes');
  if (byteList.isEmpty) {
    return;
  }
  Log.w('缓存全部...');
  Directory('${RuntimeEnvir.filesPath}/AppManager/.icon').createSync(
    recursive: true,
  );
  for (int i = 0; i < packages.length; i++) {
    String cachePath =
        '${RuntimeEnvir.filesPath}/AppManager/.icon/${packages[i]}';
    File cacheFile = File(cachePath);
    if (!(await cacheFile.exists())) {
      await cacheFile.writeAsBytes(
        byteList[i],
      );
    }
  }
}

List<String> parsePMOut(String out) {
  String tmp = out.replaceAll(RegExp('package:'), '');
  return tmp.split('\n');
}

// 之后有时间把命令行完全换成server
class AppUtils {
  static Future<List<AppInfo>> getAllAppInfo({
    AppType appType = AppType.user,
    Executable executable,
    AppChannel appChannel,
  }) async {
    bool isSystemApp = false;
    if (appType == AppType.system) {
      isSystemApp = true;
    }
    Log.w('getUserApp');
    //拿到应用软件List
    Stopwatch watch = Stopwatch();
    watch.start();
    List<AppInfo> entitys = await appChannel.getAllAppInfo(isSystemApp);
    if (entitys.isEmpty) {
      return [];
    }
    // 排序
    entitys.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    List<String> packages = [];
    for (AppInfo info in entitys) {
      packages.add(info.packageName);
    }
    cacheAllUserIcons(packages, appChannel);
    return entitys;
  }
}
