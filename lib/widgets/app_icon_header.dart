import 'dart:io';
import 'dart:typed_data';
import 'package:app_manager/controller/icon_controller.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/global/icon_store.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppIconHeader extends StatefulWidget {
  const AppIconHeader({
    Key key,
    this.packageName,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);
  final String packageName;
  final EdgeInsets padding;
  @override
  _AppIconHeaderState createState() => _AppIconHeaderState();
}

class _AppIconHeaderState extends State<AppIconHeader> {
  bool useByte = false;
  bool prepare = false;
  IconController iconController = Get.find();
  String iconDirPath;
  @override
  void initState() {
    super.initState();
    iconController.addListener(loadAppIcon);
    // loadAppIcon();
  }

  Future<void> loadAppIcon() async {
    if (useByte) {
      return;
    }
    // Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = RuntimeEnvir.filesPath;
    iconDirPath = '$appDocPath/AppManager/.icon';
    File cacheFile = File('$iconDirPath/${widget.packageName}');
    Directory(iconDirPath).createSync(recursive: true);
    if (IconStore().hasCache(widget.packageName)) {
      useByte = true;
      prepare = true;
      cacheFile.writeAsBytes(IconStore().loadCache(widget.packageName));
      if (mounted) {
        setState(() {});
      }
      return;
    } else {
      useByte = true;
      prepare = true;
      List<int> byte =
          await Global().appChannel.getAppIconBytes(widget.packageName);
      IconStore().cache(widget.packageName, byte);
      if (mounted) {
        setState(() {});
      }
    }
    if (await cacheFile.exists()) {
      prepare = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    iconController.removeListener(loadAppIcon);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: Image.network(
          'http://127.0.0.1:${Global().appChannel.port}/icon/${widget.packageName}',
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return Image.asset('assets/placeholder.png');
          },
        ),
      ),
    );
    if (!prepare) {
      return SizedBox(
        width: 54,
        height: 54,
        child: SpinKitDoubleBounce(
          color: Colors.indigo,
          size: 16.0,
        ),
      );
    } else {
      // Log.d('${widget.packageName} useByte:$useByte');
      Widget child;
      if (useByte) {
        Uint8List byte =
            Uint8List.fromList(IconStore().loadCache(widget.packageName));
        if (byte.isEmpty) {
          return SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.adb,
              size: 12,
            ),
          );
        }
        child = SizedBox(
          child: Image.memory(
            Uint8List.fromList(byte),
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) {
              return SizedBox(
                width: 32,
                height: 32,
                child: SpinKitDoubleBounce(
                  color: Colors.indigo,
                  size: 16.0,
                ),
              );
            },
          ),
        );
      } else {
        child = SizedBox(
          child: Image.file(
            File('$iconDirPath/${widget.packageName}'),
            gaplessPlayback: true,
          ),
        );
      }
      return Padding(
        padding: widget.padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.w),
          child: child,
        ),
      );
    }
  }
}
