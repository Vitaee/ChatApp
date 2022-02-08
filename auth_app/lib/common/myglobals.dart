library globals;

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String currentUsername = "";
WebSocketChannel listen_message = IOWebSocketChannel.connect(
    "ws://10.80.1.167:8080/api/chats",
    headers: {"Current-User": currentUsername});
