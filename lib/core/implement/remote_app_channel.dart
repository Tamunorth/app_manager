import 'package:adbutil/adbutil.dart';
import 'package:app_manager/global/global.dart';
import 'package:global_repository/global_repository.dart';

import 'local_app_channel.dart';

class RemoteAppChannel extends LocalAppChannel {
  String serial;
  @override
  Future<void> openApp(String packageName) async {
    Log.e('openApp $packageName');
    String mainClass = await getAppMainActivity(packageName);
    execCmd('adb -s $serial shell am start -n $packageName/$mainClass');
  }
}
