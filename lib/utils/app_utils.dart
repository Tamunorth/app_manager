import 'dart:async';
import 'dart:io';

import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/config.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:apputils/apputils.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

enum AppType {
  user,
  system,
}
Completer iconCacheLock = Completer()..complete();
// 根据文件头将一维数组缓拆分成二维数组
Future<void> cacheAllUserIcons(
  List<String> packages,
  AppChannel appChannel,
) async {
  // 所有图
  Log.w('await iconCacheLock.future');
  await iconCacheLock.future;
  iconCacheLock = Completer();
  String pathPrefix = '${RuntimeEnvir.filesPath}/AppManager/.icon';
  List<String> needCachePackages = [];
  for (int i = 0; i < packages.length; i++) {
    String cachePath = '$pathPrefix/${packages[i]}';
    File cacheFile = File(cachePath);
    if (!(await cacheFile.exists())) {
      needCachePackages.add(packages[i]);
    }
  }
  if (needCachePackages.isEmpty) {
    iconCacheLock.complete();
    return;
  }
  Log.w('缓存全部... needCachePackages.length -> ${needCachePackages.length}');
  final List<List<int>> byteList = await appChannel.getAllAppIconBytes(
    needCachePackages,
  );
  // Log.e('allBytes -> $allBytes');
  if (byteList.isEmpty) {
    iconCacheLock.complete();
    return;
  }
  Directory(pathPrefix).createSync(
    recursive: true,
  );
  for (int i = 0; i < needCachePackages.length; i++) {
    String cachePath = '$pathPrefix/${needCachePackages[i]}';
    File cacheFile = File(cachePath);
    if (!(await cacheFile.exists())) {
      await cacheFile.writeAsBytes(byteList[i]);
    }
  }
  iconCacheLock.complete();
}

List<String> parsePMOut(String out) {
  String tmp = out.replaceAll(RegExp('package:'), '');
  return tmp.split('\n');
}

// 这个类，file_selector会用
class AppUtils {
  static Future<List<AppInfo>> getAllAppInfo({
    AppType appType = AppType.user,
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
    Log.e('isSystemApp -> $isSystemApp');
    cacheAllUserIcons(packages, appChannel);
    return entitys;
  }
}
