import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:presgo_app/views/splash_view.dart';
import 'package:presgo_app/config/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await AppSettingsController.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'PresGo Absensi',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E66FF),
              primary: const Color(0xFF2E66FF),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E66FF),
              primary: const Color(0xFF2E66FF),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF080C24),
            useMaterial3: true,
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(settings.fontSizeMultiplier),
              ),
              child: child!,
            );
          },
          initialRoute: "/",
          routes: {'/': (context) => const SplashView1()},
        );
      },
    );
  }
}
