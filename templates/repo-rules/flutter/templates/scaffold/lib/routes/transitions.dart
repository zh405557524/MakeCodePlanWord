part of 'index.dart';

/// 自定义转场。默认用 CupertinoPage，此处只放特殊场景。
/// 用不到时保留空文件即可，不要删掉 index.dart 里的 part 声明。
class FadePage<T> extends CustomTransitionPage<T> {
  FadePage({required super.child, super.key, super.name})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
}
