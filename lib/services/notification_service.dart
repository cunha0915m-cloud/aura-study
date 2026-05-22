import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificações push (FCM) + locais.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Permissões FCM (iOS)
    await FirebaseMessaging.instance.requestPermission();

    // Inicializa plugin local
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Foreground listener
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _local.show(
          n.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('aura_study', 'Aura Study'),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    });

    if (kDebugMode) {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('🔔 FCM token: $token');
    }
  }
}
