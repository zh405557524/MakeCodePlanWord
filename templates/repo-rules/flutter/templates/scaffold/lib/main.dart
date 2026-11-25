import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:your_project/global.dart';
import 'package:your_project/routes/index.dart';
import 'package:your_project/theme.dart';
import 'package:your_project/utils/index.dart';
import 'package:your_project/widgets/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(CustomTheme.systemStyleLight);

  // 初始化失败不阻塞启动：记录日志后以降级状态进入 App，
  // 由各页面按 loading/error 状态自行处理缺失的依赖。
  try {
    await Global.init();
  } catch (e, s) {
    Logger.error('Global.init 失败，降级启动', tag: 'Boot', error: e, stackTrace: s);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '应用名称',
      theme: CustomTheme.light,
      darkTheme: CustomTheme.dark,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'en'),
      ],
      locale: WidgetsBinding.instance.platformDispatcher.locale,
      routerConfig: CustomRouter.config,
      builder: (context, child) {
        return Builder(
          builder: (innerContext) {
            ScreenUtil.init(
              innerContext,
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
            );
            return CustomToast.init(
              builder: (ctx, c) => MediaQuery(
                // 禁用系统字体缩放，保证设计稿还原度
                data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.noScaling),
                child: c ?? const SizedBox.shrink(),
              ),
            )(innerContext, child);
          },
        );
      },
    );
  }
}
