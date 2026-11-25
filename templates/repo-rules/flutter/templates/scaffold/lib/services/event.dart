part of 'index.dart';

/// 轻量事件总线。跨模块通知用，不要拿来当全局状态使。
class EventService extends GetxService {
  final Map<String, List<void Function(dynamic)>> _bus = {};

  void on(String event, void Function(dynamic) callback) {
    _bus.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, [void Function(dynamic)? callback]) {
    if (callback == null) {
      _bus.remove(event);
    } else {
      _bus[event]?.remove(callback);
    }
  }

  void emit(String event, [dynamic data]) {
    // 复制一份再遍历，避免回调中 off 导致并发修改
    final callbacks = List<void Function(dynamic)>.from(_bus[event] ?? const []);
    for (final cb in callbacks) {
      cb(data);
    }
  }

  @override
  void onClose() {
    _bus.clear();
    super.onClose();
  }
}
