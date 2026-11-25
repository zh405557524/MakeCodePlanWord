part of 'index.dart';

/// 全局配置状态。
class ConfigStore extends GetxController {
  static ConfigStore get to => Get.find<ConfigStore>();

  final StorageService _storage = Get.find<StorageService>();

  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _storage.read<bool>(Constants.storageDarkMode) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _storage.write(Constants.storageDarkMode, _isDarkMode.value);
  }
}
