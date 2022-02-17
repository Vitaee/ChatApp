import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class Notif {
  static final _notifs = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    await _notifs.initialize(settings, onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }

  static Future notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails('channel name', 'channel description',
          importance: Importance.max),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future showNotif({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifs.show(id, title, body, await notificationDetails(),
          payload: payload);
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'my_channel',
  'Important notifications from my server.',
  importance: Importance.high,
);

class Notifications {
  static final _notifs = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails('channel name', 'channel description',
          icon: '@mipmap/ic_launcher', importance: Importance.max),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future showNotif({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifs.show(id, title, body, await notificationDetails(),
          payload: payload);

  static Future init(FirebaseMessaging fcm) async {
    //FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);
    await _notifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notifs.initialize(settings, onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });

    await fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showNotif(
          title: notification.title,
          body: notification.body,
          payload: message.data.toString(),
        );

        /*flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.name,
                channel.description.toString(),
                icon: '@mipmap/ic_launcher',
              ),
            ));*/
      }
    });
  }
}
