library globals;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String currentUsername = "";
FirebaseMessaging fcm = FirebaseMessaging.instance;
late WebSocketChannel home_channel;
late WebSocketChannel room_channel;
