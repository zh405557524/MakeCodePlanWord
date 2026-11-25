import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:your_project/services/index.dart';
import 'package:your_project/store/index.dart';

/// 应用级一次性初始化与依赖注入。
/// 只放初始化编排，不放业务逻辑。
abstract class Global {
  static PackageInfo? _platform;

  static String get version => _platform?.version ?? '0.0.0';
  static String get build => _platform?.buildNumber ?? '0';
  static String get appName => _platform?.appName ?? '-';

  static Future<void> init() async {
    _platform = await PackageInfo.fromPlatform();

    // 有异步初始化的 Service 先注入，后面的 Store 依赖它
    await Get.putAsync<StorageService>(() => StorageService().init());

    Get.put<EventService>(EventService());
    Get.put<HttpService>(HttpService());

    // Store 依赖 StorageService，必须在其之后
    Get.put<ConfigStore>(ConfigStore());
    Get.put<UserStore>(UserStore());
  }
}
