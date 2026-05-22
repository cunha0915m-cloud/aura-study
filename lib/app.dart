import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

/// Root widget da app. Configura tema, rotas e título.
class AuraStudyApp extends StatelessWidget {
  const AuraStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Aura Study',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
    );
  }
}
