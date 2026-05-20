import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../persistence/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  Future<bool> requestPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() => _repository.getDeviceToken();

  Stream<String> get onTokenRefresh => _repository.onTokenRefresh;

  void initializeNotificationListeners({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onNotificationOpened,
  }) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM: Notificació rebuda en primer pla: \${message.notification?.title}");
      onMessageReceived(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("FCM: L'usuari ha clicat la notificació des de segon pla!");
      onNotificationOpened(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("FCM: L'app s'ha obert des de zero gràcies a una notificació!");
        onNotificationOpened(message);
      }
    });
  }
}