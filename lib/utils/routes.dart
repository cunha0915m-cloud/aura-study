import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/study/pomodoro_screen.dart';
import '../screens/study/calendar_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/profile/my_posts_screen.dart';
import '../screens/profile/ranking_screen.dart';
import '../screens/profile/notifications_screen.dart';

/// Tabela centralizada de rotas nomeadas.
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const main = '/main';
  static const chat = '/chat';
  static const upload = '/upload';
  static const profile = '/profile';
  static const settings = '/settings';
  static const pomodoro = '/pomodoro';
  static const calendar = '/calendar';
  static const favorites = '/favorites';
  static const myPosts = '/my-posts';
  static const ranking = '/ranking';
  static const notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgot: (_) => const ForgotPasswordScreen(),
        main: (_) => const MainNavigation(),
        chat: (_) => const ChatScreen(),
        upload: (_) => const UploadScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        pomodoro: (_) => const PomodoroScreen(),
        calendar: (_) => const CalendarScreen(),
        favorites: (_) => const FavoritesScreen(),
        myPosts: (_) => const MyPostsScreen(),
        ranking: (_) => const RankingScreen(),
        notifications: (_) => const NotificationsScreen(),
      };
}
