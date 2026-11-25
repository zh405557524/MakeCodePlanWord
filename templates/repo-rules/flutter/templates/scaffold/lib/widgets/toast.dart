import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

/// 全局提示统一入口。换 toast 库时只改这一个文件。
abstract class CustomToast {
  /// 注意组合方式：BotToastInit() 返回的是 TransitionBuilder，
  /// 必须先用业务 builder 产出 child，再交给 BotToastInit 包裹。
  /// 直接写 BotToastInit()(context, builder) 是把 builder 当 child 传，类型就不对。
  static TransitionBuilder init({required TransitionBuilder builder}) {
    final botToastBuilder = BotToastInit();
    return (context, child) => botToastBuilder(context, builder(context, child));
  }

  static void text(String message) => BotToast.showText(text: message);

  static void success(String message) => BotToast.showText(text: message);

  /// 失败提示叫 fail，不叫 error —— 与项目现有调用点保持一致
  static void fail(String message) => BotToast.showText(text: message);

  /// 加载提示统一走 loading()，不要在业务里直接调 BotToast.showLoading()
  static void loading([String? message]) => BotToast.showLoading();

  static void dismiss() => BotToast.closeAllLoading();
}
