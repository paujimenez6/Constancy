import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/notification_service.dart';
import '../../main.dart';
import '../screens/notifications_screen.dart';
import '../screens/search_screen.dart';
import 'auth_provider.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  final AuthService _authService;

  NotificationProvider(this._service, this._authService);

  Future<void> initializeNotifications(String userId) async {
    final granted = await _service.requestPermissions();
    if (granted) {
      final token = await _service.getToken();
      debugPrint("FCM Token: $token");

      if (token != null) {
        await _authService.updateDeviceToken(userId, token);
        debugPrint("Token guardat a Supabase per a l'usuari: $userId");
      }
    }
  }

  void setupListeners() {
    _service.initializeNotificationListeners(
      onMessageReceived: (RemoteMessage message) {
        _showInAppBanner(message);
        notifyListeners();
      },
      onNotificationOpened: (RemoteMessage message) {
        _handleNavigation(message);
      },
    );
  }

  void _handleNavigation(RemoteMessage message) {
    final type = message.data['type'];
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'new_follower') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    } else if (type == 'league_end') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      );
    } else if (type == 'end_of_day' || type == 'group_habit_completed' || type == 'habit_reminder'){
      context.read<AuthProvider>().setTabIndex(0);
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  void _showInAppBanner(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final theme = Theme.of(context);
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    OverlayEntry? overlayEntry;
    Timer? timer;

    void removeOverlay() {
      if (overlayEntry != null && overlayEntry.mounted) {
        overlayEntry.remove();
        timer?.cancel();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => removeOverlay(),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -20),
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  removeOverlay();
                  _handleNavigation(message);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.notification?.title ?? "Notificació",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message.notification?.body ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
    timer = Timer(const Duration(seconds: 4), removeOverlay);
  }
}