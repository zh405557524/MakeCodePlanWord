import 'package:flutter/foundation.dart';

/// 分级日志。debug 模式默认开启，release 自动关闭。
abstract class Logger {
  // 公开级别常量，外部可用于 setLevel
  static const int levelDebug = 0;
  static const int levelInfo = 1;
  static const int levelWarning = 2;
  static const int levelError = 3;

  static int _currentLevel = levelDebug;
  static bool _enabled = kDebugMode;

  /// 设置最低输出级别，低于此级别的日志被忽略。
  static void setLevel(int level) => _currentLevel = level;

  static void setEnabled(bool enabled) => _enabled = enabled;

  static void debug(Object? message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(levelDebug, message, tag: tag, error: error, stackTrace: stackTrace);

  static void info(Object? message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(levelInfo, message, tag: tag, error: error, stackTrace: stackTrace);

  static void warning(Object? message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(levelWarning, message, tag: tag, error: error, stackTrace: stackTrace);

  static void error(Object? message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(levelError, message, tag: tag, error: error, stackTrace: stackTrace);

  static void _log(
    int level,
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level < _currentLevel) return;

    const names = ['DEBUG', 'INFO', 'WARNING', 'ERROR'];
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final prefix = '[$time] [${names[level]}]${tag != null ? '[$tag]' : ''}';

    debugPrint('$prefix $message');
    if (error != null) debugPrint('$prefix Error: $error');
    if (stackTrace != null) debugPrint('$prefix Stack: $stackTrace');
  }
}
