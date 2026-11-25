part of 'index.dart';

class UserProfileController extends GetxController {
  /// 外部参数走构造注入，不用全局变量、不用 Get.arguments
  UserProfileController({required this.userId});

  final String userId;

  // ---- 页面状态：一律 .obs，由 View 侧的 Obx 消费（见 03-状态管理）----
  final loading = true.obs;
  final errorMessage = RxnString();
  final detail = Rxn<Object>(); // TODO: 换成真实模型

  bool get isEmpty =>
      !loading.value && errorMessage.value == null && detail.value == null;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    // 释放 TextEditingController / ScrollController / 定时器 / 订阅
    super.onClose();
  }

  Future<void> loadData() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      // detail.value = await UserApi.detail(userId);
    } catch (e, s) {
      // fail() 会自动写 AppLogger.error，不用再手写一遍日志
      CustomToast.fail('加载失败，请稍后重试', error: e, stackTrace: s);
      errorMessage.value = '加载失败，请稍后重试';
    } finally {
      loading.value = false;
    }
  }

  /// 需要 context 的方法由 View 传入，禁止 Get.context
  void openSettings(BuildContext context) {
    context.pushNamed(RouteName.main);
  }
}
