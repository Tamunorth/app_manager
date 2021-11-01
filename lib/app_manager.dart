library app_manager;

import 'global/global.dart';

export 'home.dart';
export 'routes/app_pages.dart';
export 'bindings/app_manager_binding.dart';
export 'utils/app_utils.dart';
export 'core/implement/local_app_channel.dart';
export 'core/implement/remote_app_channel.dart';
export 'model/app.dart';
export 'modules/app_page/app_list_page.dart';
export 'utils/dex_server.dart';

class AppManager {
  static Global globalInstance = Global();
}
