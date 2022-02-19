import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/core/foundation/protocol.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/global/icon_store.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:applib_util/applib_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class LocalAppChannel implements AppChannel {
  Future<int> getPort() async {
    if (port != null) {
      // Log.e('port -> $port');
      return port;
    }
    String data =
        await File(RuntimeEnvir.filesPath + '/server_port').readAsString();
    port = int.tryParse(data);
    Log.w('成功获ß取 LocalAppChannel port -> $port');
    return port;
  }

  @override
  Future<List<AppInfo>> getAllAppInfo(bool isSystemApp) async {
    Stopwatch watch = Stopwatch();
    watch.start();
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAllAppInfo + (isSystemApp ? '1' : '0') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    Log.e('watch -> ${watch.elapsed}');
    // Log.e('infos -> $infos');
    final List<AppInfo> entitys = <AppInfo>[];
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      final AppInfo appInfo = AppInfo(
        infoList[0],
        appName: infoList[1],
        minSdk: infoList[2],
        targetSdk: infoList[3],
        versionCode: infoList[5],
        versionName: infoList[4],
        freeze: infoList[6] == 'false',
        hide: infoList[7] == 'true',
        uid: infoList[8],
        apkPath: infoList[9],
      );
      entitys.add(appInfo);
    }
    return entitys;
  }

  @override
  Future<String> getAppDetails(String package) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppDetail + package + '\n');
    final String result = (await manager.getString());
    return result;
  }

  @override
  Future<List<String>> getAppActivitys(String package) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppActivity + package + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    return infos;
  }

  @override
  Future<List<String>> getAppPermission(String package) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppPermissions + package + '\n');
    final List<String> infos = (await manager.getString()).split('\r');
    infos.removeLast();
    return infos;
  }

  @override
  Future<List<int>> getAppIconBytes(String packageName) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    await manager.connect();
    manager.sendMsg(Protocol.getIconData + '$packageName\n');
    List<int> result = await manager.getResult();
    // Log.w(result);
    return result;
  }

  @override
  Future<List<List<int>>> getAllAppIconBytes(List<String> packages) async {
    SocketWrapper manager = SocketWrapper(
      InternetAddress.anyIPv4,
      await getPort(),
    );
    await manager.connect();
    manager.sendMsg(Protocol.getIconDatas + packages.join(' ') + '\n');
    String package = '';
    List<int> buffer = [];
    Completer lock = Completer();
    bool bufferIsIcon = false;
    IconController controller = Get.find();
    bool isBreak = false;
    Stream<Uint8List> stream = manager.mStream;

    stream.listen((event) {
      // BytesBuilder bytesBuilder = BytesBuilder();
      // bytesBuilder.add(event);
      // ByteBuffer byteBuffer = bytesBuilder.takeBytes().buffer;
      // byteBuffer.asByteData().
      Uint8List list = Uint8List.fromList(event);
      while (list.isNotEmpty) {
        if (buffer.isEmpty) {
          Log.i('list : ${list}');
          int packLength =
              list[0] << 24 | list[1] << 16 | list[2] << 8 | list[3];
          buffer.add(packLength);
          list = list.sublist(4);
        }
        Log.i('shouldRead : ${buffer.first}');
        if (buffer.length != buffer.first) {
          int needAppend = buffer.first - buffer.length - 1;
          Log.i('needAppend : $needAppend');
          Log.i('list.length : ${list.length}');
          int souldTake = min(needAppend, list.length);
          buffer.addAll(list.take(souldTake));
          Log.i('buffer : $buffer');
          Log.i('buffer.length : ${buffer.length}');
          list = list.sublist(souldTake + 1);
        }
        if (buffer.length == buffer.first + 1) {
          int index = buffer.indexOf(58);
          String package = utf8.decode(buffer.sublist(1, index));
          Log.i('package : $package');
          List<int> iconByte = buffer.sublist(index + 1);
          Log.i('iconByte : $iconByte');
          IconStore().cache(package, iconByte);
          controller.update();
          buffer.clear();
        }
      }
    }, onDone: () {
      lock.complete();
    });
    await lock.future;
    // List<int> allBytes = await manager.getResult();
    // List<List<int>> byteList = [];
    // byteList.length = packages.length;
    // int index = 0;
    // // 根据png编码的头对图片进行拆分
    // for (int i = 0; i < allBytes.length; i++) {
    //   byteList[index] ??= [];
    //   byteList[index].add(allBytes[i]);
    //   if (i < allBytes.length - 1 - 6 &&
    //       allBytes[i + 1] == 137 &&
    //       allBytes[i + 2] == 80 &&
    //       allBytes[i + 3] == 78 &&
    //       allBytes[i + 4] == 71 &&
    //       allBytes[i + 5] == 13 &&
    //       allBytes[i + 6] == 10 &&
    //       i != 0) {
    //     index++;

    //   }
    // }
    // Log.w(result);
    // return byteList;
  }

  @override
  Future<bool> clearAppData(String packageName) async {
    String result = await Global().exec('pm clear $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> hideApp(String packageName) async {
    String result = await Global().exec('pm hide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> showApp(String packageName) async {
    String result = await Global().exec('pm unhide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result = await Global().exec(
      'pm disable-user --user 0 $packageName',
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> unFreezeApp(String packageName) async {
    String result = await Global().exec('pm enable --user 0 $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> unInstallApp(String packageName) async {
    String result = await Global().exec('pm uninstall  $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<String> getAppMainActivity(String packageName) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    await manager.connect();
    manager.sendMsg(Protocol.getAppMainActivity + packageName + '\n');
    final String result = (await manager.getString());
    Log.e('getAppMainActivity $result');
    return result;
  }

  // @override
  // Future<void> launchActivity(
  //   String packageName,
  //   String activity,
  // ) async {
  //   const MethodChannel channel = MethodChannel('app_manager');
  //   channel.invokeMethod(
  //     'openActivity',
  //     [
  //       packageName,
  //       activity,
  //     ],
  //   );
  // }

  @override
  Future<void> openApp(String packageName) async {
    Log.e('openApp $packageName');
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.openAppByPackage + packageName + '\n');
  }

  @override
  Future<String> getFileSize(String path) async {
    return await Global().exec('stat -c "%s" $path');
  }

  @override
  int port;

  @override
  Future<List<AppInfo>> getAppInfos(List<String> packages) async {
    SocketWrapper manager =
        SocketWrapper(InternetAddress.anyIPv4, await getPort());
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppInfos + packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    final List<AppInfo> entitys = <AppInfo>[];
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      final AppInfo appInfo = AppInfo(
        infoList[0],
        appName: infoList[1],
        minSdk: infoList[2],
        targetSdk: infoList[3],
        versionCode: infoList[5],
        versionName: infoList[4],
        freeze: infoList[6] == 'false',
        hide: infoList[7] == 'true',
        uid: infoList[8],
        apkPath: infoList[9],
      );
      entitys.add(appInfo);
    }
    return entitys;
  }
}
