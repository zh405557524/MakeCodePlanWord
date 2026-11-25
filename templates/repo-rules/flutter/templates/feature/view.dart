part of 'index.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    // GetBuilder 只负责用 init: 托管 Controller 生命周期；
    // 刷新交给内层 Obx —— 二者不可颠倒（见 03-状态管理 第二节）
    return GetBuilder<UserProfileController>(
      init: UserProfileController(userId: userId),
      builder: (controller) => Obx(
        () => CustomScaffold(
          appBar: AppBar(title: const Text('个人资料')),
          body: _buildBody(context, controller),
        ),
      ),
    );
  }

  /// 从 Obx 闭包同步调用的方法，内部的 .value 同样被追踪，可以放心拆
  ///
  /// 也可将 Controller 状态映射为 ViewState，交给公共容器统一展示：
  ///   AppStateBuilder(state: controller.viewState, builder: (_) => ...)
  /// 其中 viewState 需在 Controller 定义；loading/error/empty 是 Widget 插槽，
  /// 不是布尔状态。参数以 lib/widgets/app_state_builder.dart 为准。
  Widget _buildBody(BuildContext context, UserProfileController controller) {
    if (controller.loading.value) return const AppLoading();
    if (controller.errorMessage.value != null) {
      return AppError(
        message: controller.errorMessage.value!,
        onRetry: controller.loadData,
      );
    }
    if (controller.isEmpty) return const AppEmpty();
    return const SizedBox.shrink(); // TODO: 正常内容
  }
}
