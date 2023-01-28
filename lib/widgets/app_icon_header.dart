import 'dart:io';
import 'dart:typed_data';
import 'package:app_manager/controller/icon_controller.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/config.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppIconHeader extends StatefulWidget {
  const AppIconHeader({
    Key? key,
    this.packageName,
    this.padding = const EdgeInsets.all(8.0),
    required this.channel,
  }) : super(key: key);
  final String? packageName;
  final EdgeInsets padding;
  final AppChannel? channel;

  @override
  _AppIconHeaderState createState() => _AppIconHeaderState();
}

class _AppIconHeaderState extends State<AppIconHeader> {
  bool useByte = false;
  bool prepare = false;
  IconController iconController = Get.find();
  String? iconDirPath;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Log.e('http://127.0.0.1:${widget.channel?.port ?? Global().appChannel.port}/icon/${widget.packageName}');
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: Image.network(
          'http://127.0.0.1:${widget.channel?.port ?? Global().appChannel!.port}/icon/${widget.packageName}',
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return Image.asset(
              '${Config.flutterPackage}assets/placeholder.png',
              gaplessPlayback: true,
            );
          },
        ),
      ),
    );
  }
}
