import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/battle_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/item_detail_page.dart';
import 'pages/admin/admin_dashboard.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/responsive_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = await ThemeProvider.load();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: themeProvider.mode == AppThemeMode.light
        ? Brightness.dark
        : Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: themeProvider.mode == AppThemeMode.light
        ? Brightness.dark
        : Brightness.light,
  ));
  runApp(GenshinImportApp(themeProvider: themeProvider));
}

class GenshinImportApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const GenshinImportApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => BattleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Genshin Import',
          debugShowCheckedModeBanner: false,
          theme: theme.themeData,
          initialRoute: '/',
          builder: (context, child) => ResponsiveWrapper(child: child!),
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/main': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              return AppScaffold(initialIndex: args is int ? args : 0);
            },
            '/item-detail': (context) => const ItemDetailPage(),
            '/admin': (context) => const AdminDashboard(),
          },
        ),
      ),
    );
  }
}
