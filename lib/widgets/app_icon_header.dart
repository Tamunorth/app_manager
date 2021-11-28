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
import 'package:path_provider/path_provider.dart';

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
    loadAppIcon();
  }

  Future<void> loadAppIcon() async {
    if (useByte) {
      return;
    }
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;
    iconDirPath = '$appDocPath/AppManager/.icon';
    File cacheFile = File('$iconDirPath/${widget.packageName}');
    if (IconStore().hasCache(widget.packageName)) {
      useByte = true;
      prepare = true;
      cacheFile.writeAsBytes(IconStore().loadCache(widget.packageName));
      if (mounted) {
        setState(() {});
      }
      return;
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
    if (!prepare) {
      return const SizedBox(
        width: 54,
        height: 54,
        child: SpinKitDoubleBounce(
          color: Colors.indigo,
          size: 16.0,
        ),
      );
    } else {
      // Log.d('${widget.packageName} useByte:$useByte');
      if (useByte) {
        return SizedBox(
          child: Padding(
            padding: widget.padding,
            child: Image.memory(
              Uint8List.fromList(IconStore().loadCache(widget.packageName)),
              gaplessPlayback: true,
            ),
          ),
        );
      }
      return SizedBox(
        child: Padding(
          padding: widget.padding,
          child: Image.file(
            File('$iconDirPath/${widget.packageName}'),
            gaplessPlayback: true,
          ),
        ),
      );
    }
  }
}
