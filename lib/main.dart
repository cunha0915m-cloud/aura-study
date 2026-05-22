import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/goals_provider.dart';
import 'utils/constants.dart';
import 'services/notification_service.dart';

/// Entry point da aplicação Aura Study.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Só inicializa Firebase se as opções tiverem sido geradas pelo
  // `flutterfire configure` (e não forem os placeholders "REPLACE_ME").
  final opts = DefaultFirebaseOptions.currentPlatform;
  final hasRealConfig = !opts.apiKey.contains('REPLACE_ME');
  if (hasRealConfig) {
    try {
      await Firebase.initializeApp(options: opts);
      await NotificationService.instance.init();
      AppConfig.useFirebase = true;
    } catch (e) {
      debugPrint('⚠️ Firebase falhou: $e');
      AppConfig.useFirebase = false;
    }
  } else {
    debugPrint('ℹ️ Firebase em modo local (chaves placeholder).');
    AppConfig.useFirebase = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProxyProvider<AuthProvider, GoalsProvider>(
          create: (_) => GoalsProvider(),
          update: (_, auth, goals) {
            goals ??= GoalsProvider();
            goals.updateSession(auth.user?.uid);
            return goals;
          },
        ),
        // ChatProvider escuta as Definições (para API Key) e o Auth (para o ID de utilizador)
        // para carregar e guardar o histórico de perguntas/respostas de forma automática.
        ChangeNotifierProxyProvider2<SettingsProvider, AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, settings, auth, chat) {
            chat ??= ChatProvider();
            chat.updateSession(auth.user?.uid, settings);
            return chat;
          },
        ),
      ],
      child: const AuraStudyApp(),
    ),
  );
}
