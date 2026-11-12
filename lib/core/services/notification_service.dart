import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String? _registeredUserId;
  String? _currentToken;
  String? activeConversationId;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat messages',
    description: 'Notifications for new messages.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _currentToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Local notifications still work if push registration is unavailable.
    }
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _currentToken = token;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) _saveToken(user.uid, token);
    });
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _removeRegisteredToken();
      } else {
        _registeredUserId = user.uid;
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
    } catch (_) {
      // A later auth or token refresh event will retry registration.
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
    } catch (_) {
      // Stale tokens are also removed by the notification function.
    }
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final conversationId = message.data['conversationId'];
    if (conversationId != null && conversationId == activeConversationId) {
      return;
    }
    final notification = message.notification;
    if (notification == null) return;
    await showMessageNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title ?? 'New message',
      body: notification.body ?? '',
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

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
