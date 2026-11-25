part of 'index.dart';

/// 全局用户状态。Store 层用 .obs + Obx（见 03-状态管理 第一节）。
class UserStore extends GetxController {
  static UserStore get to => Get.find<UserStore>();

  final StorageService _storage = Get.find<StorageService>();

  final RxBool _isLogin = false.obs;
  bool get isLogin => _isLogin.value;

  final RxString _token = ''.obs;
  String get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final saved = _storage.read<String>(Constants.storageToken);
    if (saved != null && saved.isNotEmpty) {
      _token.value = saved;
      _isLogin.value = true;
    }
  }

  Future<void> login(String token) async {
    _token.value = token;
    _isLogin.value = true;
    await _storage.write(Constants.storageToken, token);
  }

  Future<void> logout() async {
    _token.value = '';
    _isLogin.value = false;
    await _storage.remove(Constants.storageToken);
  }
}
