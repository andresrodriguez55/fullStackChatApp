import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:chatapp/models/User.dart';
import 'package:flutter/foundation.dart';

import '../ServerData.dart';
import 'Message.dart';

class SocketController 
{
  User? currentUser;

  String wsUrl = 'ws://'+ServerData().SERVER_IP+"/ws/socket-server/";
  static final SocketController _singleton = SocketController._internal();
  SocketController._internal();

  StreamSubscription<dynamic>? channelListener;
  StreamController<String> streamController = new StreamController.broadcast(sync: true);

  WebSocket? channel;

  factory SocketController(User? currentUser) 
  {
    _singleton.currentUser=currentUser;

    return _singleton;
  }

  initWebSocketConnection() async 
  {
    debugPrint("conecting...");
    this.channel = await connectWs();
    debugPrint("socket connection initializied");
    this.channel?.done.then((dynamic _) => _onDisconnected());
    broadcastNotifications();
  }

  void _onDisconnected() 
  {
    initWebSocketConnection();
  }

  connectWs() async
  {
    try 
    {
      return await WebSocket.connect(
        wsUrl, 
        headers: {"username" : this.currentUser?.Username, "password" : this.currentUser?.Password
      });
    } 
    catch (e) 
    {
      debugPrint("Error! can not connect WS connectWs " + e.toString());
      await Future.delayed(Duration(milliseconds: 10000));
      return await connectWs();
    }
  }

  void broadcastNotifications() 
  {
    channelListener = this.channel?.listen
    (
      (serverData) 
      {
        Map<String, dynamic> jsonData = jsonDecode( serverData);

        if(jsonData["responseType"] == "messageStatus")
        {
          debugPrint(jsonData["status"]);
          this.currentUser?.changeMessageStatusAtMemory(jsonData["username"], jsonData["identifierNumber"], jsonData["status"]);
        }
        
        streamController.add(serverData);
      }, 
      onDone: () 
      {
        debugPrint("sending message");
        //initWebSocketConnection();
      }, 
      onError: (e) 
      {
        debugPrint('Server error: $e');
        initWebSocketConnection();
      }
    );
  }

  void sendMessageToUser(String? toUsername, Message message)
  {
    if(channelListener!=null)
    {
      channelListener?.pause();

      this.channel?.add(
        jsonEncode({
          "identifierNumber" : message.indetifierNumber,
          "content" : message.content,
          "type" : message.type,
          "receiver" : toUsername,
        })
      );

      channelListener?.resume();
    }
  }
}