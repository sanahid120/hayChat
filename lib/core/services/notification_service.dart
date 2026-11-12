import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String? _registeredUserId;
  String? _currentToken;
  String? activeConversationId;
  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<User?>? _authSubscription;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat messages',
    description: 'Notifications for new messages.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    try {
      await _plugin.initialize(settings: settings);
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_channel);
      final localPermission = await androidPlugin
          ?.requestNotificationsPermission();
      debugPrint('Local notification permission: $localPermission');
    } catch (error, stackTrace) {
      debugPrint(
        'Local notification initialization failed: $error\n$stackTrace',
      );
    }

    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      _showForegroundMessage,
      onError: (Object error) =>
          debugPrint('FCM foreground listener failed: $error'),
    );

    try {
      final permission = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        'FCM notification permission: ${permission.authorizationStatus}',
      );
      _currentToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token available: ${_currentToken != null}');
    } catch (error, stackTrace) {
      // Local notifications still work if push registration is unavailable.
      debugPrint('FCM setup failed: $error\n$stackTrace');
    }

    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen((token) {
          _currentToken = token;
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) _saveToken(user.uid, token);
        });
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      if (user == null) {
        _removeRegisteredToken();
      } else {
        final token = _currentToken;
        if (token != null) _saveToken(user.uid, token);
      }
    });
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
      _registeredUserId = userId;
    } catch (error) {
      // A later auth or token refresh event will retry registration.
      debugPrint('Unable to save FCM token for $userId: $error');
    }
  }

  Future<void> _removeRegisteredToken() async {
    final userId = _registeredUserId;
    final token = _currentToken;
    _registeredUserId = null;
    if (userId == null || token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .delete();
    } catch (error) {
      // Stale tokens are also removed by the notification function.
      debugPrint('Unable to remove FCM token for $userId: $error');
    }
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final conversationId = message.data['conversationId'];
    if (conversationId != null && conversationId == activeConversationId) {
      return;
    }
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'New message';
    final body =
        notification?.body ?? message.data['body'] ?? 'You received a message.';
    await showMessageNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
    );
  }

  Future<void> showMessageNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to show local notification: $error\n$stackTrace');
    }
  }
}
