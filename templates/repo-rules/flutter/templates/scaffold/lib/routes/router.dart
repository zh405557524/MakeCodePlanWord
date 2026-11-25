part of 'index.dart';

abstract class CustomRouter {
  static final RouteObservers observer = RouteObservers();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter config = GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    observers: <NavigatorObserver>[observer],

    /// 路由守卫集中在这里，不要散落到页面。
    /// 依赖的状态一律从 store/ 读。
    redirect: (context, state) {
      if (UserStore.to.isLogin) return null;
      final allowed = <String>[
        state.namedLocation(RouteName.main),
        state.namedLocation(RouteName.login),
      ];
      if (allowed.contains(state.matchedLocation)) return null;
      return state.namedLocation(RouteName.login);
    },

    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouteName.main,
        pageBuilder: (context, state) => CupertinoPage<void>(
          key: state.pageKey,
          name: state.fullPath,
          child: const MainPage(),
        ),
        // 子流程注册为子路由，path 用相对写法（不带前导 /）
        // routes: <RouteBase>[ GoRoute(path: 'detail', ...) ],
      ),
    ],
  );
}
