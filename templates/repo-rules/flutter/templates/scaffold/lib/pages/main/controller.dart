part of 'index.dart';

/// 主壳页面 Controller。
/// 页面层用裸字段 + update()，不用 .obs（见 03-状态管理 第一节）。
class MainController extends GetxController {
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // 释放 TextEditingController / 定时器 / 订阅
    super.onClose();
  }
}
