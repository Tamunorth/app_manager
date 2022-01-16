import 'dart:async';
import 'dart:io';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/model/app.dart';
import 'package:global_repository/global_repository.dart';
// import 'package:path_provider/path_provider.dart';

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
  // Directory appDocDir = await getApplicationSupportDirectory();
  String appDocPath = RuntimeEnvir.filesPath;
  // Log.w('getTemporaryDirectory -> ${await getTemporaryDirectory()}');
  // Log.w('getLibraryDirectory -> ${await getLibraryDirectory()}');
  // Log.w('getApplicationDocumentsDirectory -> ${await getApplicationDocumentsDirectory()}');
  // Log.w('getDownloadsDirectory -> ${await getDownloadsDirectory()}');
  // Log.w('缓存的图标文件夹 -> $appDocPath');
  String pathPrefix = '$appDocPath/AppManager/.icon';
  List<String> needCachePackages = [];
  for (int i = 0; i < packages.length; i++) {
    String cachePath = '$pathPrefix/${packages[i]}';
    File cacheFile = File(cachePath);
    if (!(await cacheFile.exists())) {
      needCachePackages.add(packages[i]);
    }
  }
  if (needCachePackages.isEmpty) {
    return;
  }
  Log.w('缓存全部... needCachePackages.length -> ${needCachePackages.length}');
  final List<List<int>> byteList = await appChannel.getAllAppIconBytes(
    needCachePackages,
  );
  // Log.e('allBytes -> $allBytes');
  // if (byteList.isEmpty) {
  //   return;
  // }
  // Directory(pathPrefix).createSync(
  //   recursive: true,
  // );
  // for (int i = 0; i < needCachePackages.length; i++) {
  //   String cachePath = '$pathPrefix/${needCachePackages[i]}';
  //   File cacheFile = File(cachePath);
  //   if (!(await cacheFile.exists())) {
  //     IconStore().cache(needCachePackages[i], byteList[i]);
  //     // cacheFile.writeAsBytes(byteList[i]);
  //   }
  // }
  // IconController controller = Get.find();
  // controller.update();
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
    return entitys;
  }
}
