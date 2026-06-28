import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background message received: ${message.messageId}');
  // Handle background notification
  await NotificationService._handleMessage(message);
} 

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static String? _fcmToken;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else {
        print('❌ Notification permission denied');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');

      // Save token to backend
      if (_fcmToken != null) {
        await _saveFcmTokenToBackend(_fcmToken!);
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _saveFcmTokenToBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
        _showLocalNotification(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📬 Notification tapped (background): ${message.data}');
        _handleNotificationTap(message);
      });

      // Check if app was opened from a notification (terminated state)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 Notification tapped (terminated): ${initialMessage.data}');
        _handleNotificationTap(initialMessage);
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _initialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  /// Initialize local notifications for beautiful in-app notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 Local notification tapped: ${response.payload}');
        if (response.payload != null) {
          // Handle notification tap
          final data = json.decode(response.payload!);
          _handleNotificationTapData(data);
        }
      },
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels for different types
  static Future<void> _createNotificationChannels() async {
    // Urgent Blood Request Channel
    const AndroidNotificationChannel urgentBloodChannel =
        AndroidNotificationChannel(
      'urgent_blood',
      'Urgent Blood Requests',
      description: 'Notifications for urgent blood donation requests',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Request Updates Channel
    const AndroidNotificationChannel requestUpdatesChannel =
        AndroidNotificationChannel(
      'request_updates',
      'Request Updates',
      description: 'Updates about your requests',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Donations Channel
    const AndroidNotificationChannel donationsChannel =
        AndroidNotificationChannel(
      'donations',
      'Donations',
      description: 'Notifications when you receive donations',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Default Channel
    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
      'default',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    // Create all channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentBloodChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(requestUpdatesChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(donationsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    print('✅ Notification channels created');
  }

  /// Show beautiful local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Get channel ID from data or use default
    String channelId = data['channelId'] ?? 'default';

    // Choose icon and color based on notification type
    String icon = '@mipmap/ic_launcher';
    int color = 0xFF2A9D8F; // Your app's primary color

    if (data['type'] == 'blood_request_approved') {
      icon = '@drawable/ic_blood'; // You'll need to add this icon
      color = 0xFFE63946; // Red for blood
    } else if (data['type'] == 'donation_received') {
      icon = '@drawable/ic_donation'; // You'll need to add this icon
      color = 0xFF06D6A0; // Green for success
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'urgent_blood' ? 'Urgent Blood Requests' : 'Notifications',
      channelDescription: 'Helping Hand notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: icon,
      color: Color(color),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        contentTitle: notification.title,
        summaryText: 'Helping Hand',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: json.encode(data),
    );
  }

  /// Save FCM token to backend
  static Future<void> _saveFcmTokenToBackend(String token) async {
    try {
      await ApiService.post('/user/update-fcm-token', {
        'fcm_token': token,
      }, includeAuth: true);
      print('✅ FCM token saved to backend');
    } catch (e) {
      print('❌ Error saving FCM token to backend: $e');
    }
  }

  /// Handle incoming messages
  static Future<void> _handleMessage(RemoteMessage message) async {
    // Save notification to local storage for in-app notification list
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    final notificationData = {
      'id': message.messageId,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    notifications.insert(0, json.encode(notificationData));

    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications = notifications.sublist(0, 100);
    }

    await prefs.setStringList('notifications', notifications);
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationTapData(message.data);
  }

  /// Handle notification tap with data
  static void _handleNotificationTapData(Map<String, dynamic> data) {
    final type = data['type'];

    // TODO: Navigate to appropriate screen based on notification type
    print('🎯 Handling notification tap: $type');

    // Example navigation logic (you'll need to implement this with your navigation)
    switch (type) {
      case 'blood_request_approved':
        // Navigate to blood request details
        print('Navigate to blood request: ${data['request_id']}');
        break;
      case 'education_request_approved':
        // Navigate to education request details
        print('Navigate to education request: ${data['request_id']}');
        break;
      case 'family_request_approved':
        // Navigate to family request details
        print('Navigate to family request: ${data['request_id']}');
        break;
      case 'donation_received':
        // Navigate to donations screen
        print('Navigate to donations');
        break;
      default:
        print('Unknown notification type: $type');
    }
  }

  /// Get all saved notifications
  static Future<List<Map<String, dynamic>>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    return notifications
        .map((n) => json.decode(n) as Map<String, dynamic>)
        .toList();
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    notifications = notifications.map((n) {
      final data = json.decode(n) as Map<String, dynamic>;
      if (data['id'] == notificationId) {
        data['read'] = true;
      }
      return json.encode(data);
    }).toList();

    await prefs.setStringList('notifications', notifications);
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }

  /// Get unread count
  static Future<int> getUnreadCount() async {
    final notifications = await getSavedNotifications();
    return notifications.where((n) => n['read'] == false).length;
  }

  /// Get FCM token
  static String? getFcmToken() => _fcmToken;

  /// Update FCM token after user login
  static Future<void> updateTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _saveFcmTokenToBackend(_fcmToken!);
    }
  }
}
