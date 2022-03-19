import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chatapp/ServerData.dart';
import 'package:chatapp/models/Memory/BackendObserver.dart';
import 'package:flutter/material.dart';

import 'package:websocket_manager/websocket_manager.dart';

class SocketTransporter
{
	String? _username;
	String? _password;
	BackendObserver? _memoryObserver;

  WebSocket? channel;
  StreamSubscription<dynamic>? channelListener;

  late WebsocketManager socket;
	
	void login(String? username, String? password)
	{
		this._username = username;
		this._password = password;

    initConnection();
	}
	
	void setMemoryObserver(BackendObserver memoryObserver)
	{
		this._memoryObserver = memoryObserver;
	}

	initConnection() async 
	{
    socket = await WebsocketManager('ws://'+ServerData.SERVER_IP+"/ws/socket-server/", 
			  {"username" : this._username?? "", "password" : this._password?? ""});

    this.socket.onClose((p0) => this._connect());

     _notificationListener();

    this._connect();
    debugPrint("socket connection initializied");
	}

	_connect() async
	{
		try 
		{
      this.socket.connect().timeout(Duration(seconds: 5));
		} 
		catch (e) 
		{
      await Future.delayed(Duration(seconds: 10));
      _connect();
		}
	}

	_notificationListener() 
	{
    socket.onMessage((serverData) 
    {
      Map<String, dynamic> jsonData = jsonDecode(serverData);
        String? responseType = jsonData["responseType"];
        if(responseType!=null)
        {
          debugPrint(serverData);
          switch(responseType)
          {
            case "messageStatus":
              _memoryObserver?.update("messageStatus", jsonData);
              break;

            case "message":
              _memoryObserver?.update("message", jsonData);
              break;
          }
        }
    });
	}
	
	void sendSocket(var jsonData)
	{
    socket.send(jsonEncode(jsonData));
	}
}