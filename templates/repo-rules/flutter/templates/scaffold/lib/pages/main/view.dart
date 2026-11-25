part of 'index.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: MainController(),
      builder: (controller) => const CustomScaffold(
        body: Center(child: Text('Hello Flutter')),
      ),
    );
  }
}
