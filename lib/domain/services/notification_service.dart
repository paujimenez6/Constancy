import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../persistence/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final MessagingWrapper _messaging;

  NotificationService(this._repository, this._messaging);

  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
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
    _messaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM: Notificació rebuda en primer pla: ${message.notification?.title}");
      onMessageReceived(message);
    });

    _messaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("FCM: L'usuari ha clicat la notificació des de segon pla!");
      onNotificationOpened(message);
    });

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("FCM: L'app s'ha obert des de zero gràcies a una notificació!");
        onNotificationOpened(message);
      }
    });
  }
}

abstract class MessagingWrapper {
  Future<NotificationSettings> requestPermission({bool alert = true, bool badge = true, bool sound = true});
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<RemoteMessage?> getInitialMessage();
}

class FirebaseMessagingWrapper implements MessagingWrapper {
  @override
  Future<NotificationSettings> requestPermission({bool alert = true, bool badge = true, bool sound = true})
  => FirebaseMessaging.instance.requestPermission(alert: alert, badge: badge, sound: sound);

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => FirebaseMessaging.instance.getInitialMessage();
}