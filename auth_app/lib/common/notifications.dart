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
