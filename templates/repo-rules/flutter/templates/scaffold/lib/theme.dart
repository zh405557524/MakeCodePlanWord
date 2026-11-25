import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 设计令牌与主题。颜色的唯一真源。
/// 新增颜色先加到这里，再登记进 90-项目专属规则.mdc 的速查表。
abstract class CustomTheme {
  // 间距
  static const margin = 16.0;
  static const padding = 16.0;
  static const radius = 8.0;

  // 语义色
  static const primary = Color(0xFF5497FF);
  static const success = Color(0xFF0ED529);
  static const warning = Color(0xFFFFD575);
  static const error = Color(0xFFFF5F5F);
  static const info = Color(0xFF309BFF);

  // ---- 系统 UI ----
  static SystemUiOverlayStyle get systemStyle => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      );

  static SystemUiOverlayStyle get systemStyleLight => systemStyle.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  static SystemUiOverlayStyle get systemStyleDark => systemStyle.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFF0D0D0D),
        systemNavigationBarIconBrightness: Brightness.light,
      );

  // ---- 亮色 ----
  static ThemeData get light => _build(const ColorScheme.light(
        surface: Color(0xFFF6F9FF),          // 页面背景
        onSurface: Color(0xFF333333),        // 主文字
        surfaceContainer: Color(0xFFFFFFFF), // 卡片
        onSurfaceVariant: Color(0xFF999999),
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF666666),        // 次文字
        onSecondary: Color(0xFF999999),      // 弱文字
        outline: Color(0xFFD8D8D8),          // 分割线
        outlineVariant: Color(0xFFE0E0E0),   // 边框
        error: error,
        onError: Colors.white,
      ));

  // ---- 暗色（不做暗色主题时可整段删除，并把 main.dart 的 darkTheme 一起删掉）----
  static ThemeData get dark => _build(const ColorScheme.dark(
        surface: Color(0xFF111113),
        onSurface: Colors.white,
        surfaceContainer: Color(0xFF1B1B1C),
        onSurfaceVariant: Color(0xFF9E9E9E),
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF999999),
        onSecondary: Color(0xFF666666),
        outline: Color(0xFF333333),
        outlineVariant: Color(0xFF2A2A2A),
        error: error,
        onError: Colors.white,
      ));

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: scheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: scheme.primary,
        cursorColor: scheme.primary,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: scheme.onSurface, height: 1.2),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        foregroundColor: scheme.onSurface,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 44,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.zero),
          maximumSize: WidgetStatePropertyAll(Size.infinite),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          elevation: WidgetStatePropertyAll(0),
        ),
      ),
    );
  }
}
