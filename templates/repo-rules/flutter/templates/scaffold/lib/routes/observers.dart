part of 'index.dart';

/// 路由观察器：维护可读的页面栈历史，便于埋点与调试。
class RouteObservers extends RouteObserver<Route<dynamic>> {
  final List<String> history = <String>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name;
    if (name != null) history.add(name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (history.isNotEmpty) history.removeLast();
  }
}
