import 'package:chatapp/models/Memory/Conversation.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/Memory/BackendObserver.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/*
  hive gives errors when getting inheritance type objects from a box again, it also gives problems 
  when trying to get a map of a specific key data type, for this reason the objects are encoded and 
  decoded with a map<dynamic, dynamic> format
*/

class Memory implements BackendObserver
{
	String? _username;

  //phone storage
  var _conversations; //conversations of users
  var _lastMessages; //to increment speed
  var _users;

  Memory()
  {
    this.initializeUserStorage();
  }

  Future initializeUserStorage() async
  {
    this._users = await Hive.openBox<User>("users");
  }

  Future initializeConversationStorage(String username) async
  {
    this._username=username;
    this._conversations = await Hive.openLazyBox<List>("${this._username}conversations");
    this._lastMessages = await Hive.openBox<Message>("${this._username}lastMessages");

    await this._conversations.clear();
    await this._lastMessages.clear();
  }

  void putUserToStorage(User user) 
  {
    this._users.put(user.username, user);
  }

  User getUserFromStorage(String username)
  {
    return this._users.get(username);
  }

  List<User> getUsersFromStorage(List<String> usernames)
  {
    List<User> users = [];
    
    usernames.forEach((username) 
    {
      users.add(this.getUserFromStorage(username));
    });

    return users;
  }

  List<Conversation> getConversations() 
  {
    List<Conversation> conversations = [];

    final usernames = this._lastMessages.keys;
    for(var username in usernames)
    {
      Message lastMessage = this._lastMessages.get(username);
      User contraryUser = this.getUserFromStorage(username);
      conversations.add(Conversation(contraryUser, lastMessage));
    }

    conversations.sort((a, b) => b.lastMessage.dateTime.compareTo(a.lastMessage.dateTime));
    return conversations;
  }

  Future<List<dynamic>> getMessagesOfConversation(String username) async
  {
    var messages = await this._conversations.get(username);
    if(messages == null)
      return [];

    return messages;
  }

  void _putMessageToLastMessages(String contraryUsername, Message message)
  {
    debugPrint("${message.content}");
    this._lastMessages.put(contraryUsername, message);
  }

  Future _saveMessagesOfConversation(String contraryUsername, List<dynamic> messages) async
  {
    await this._conversations.put(contraryUsername, messages);
  }

  Future addMessageToConversation(String contraryUsername, Message message, {var messagesFromStorage}) async
  {
    if(messagesFromStorage == null)
      messagesFromStorage = await this.getMessagesOfConversation(contraryUsername);

    messagesFromStorage.insert(0, message);
    await this._saveMessagesOfConversation(contraryUsername, messagesFromStorage);

    this._putMessageToLastMessages(contraryUsername, message);
  }

  static Future<String?> saveBase64EncodedProfilePictureAndReturnPath(String? base64EncodedProfilePicture, 
                                                              String? username) async
  {
    if(username != null)
    {
      final directory=await getApplicationDocumentsDirectory();
      String root = '${directory.path}/${username}ProfilePicture.png';

      try { await File(root).delete(); } catch(e){ } //delete if exists

      if(base64EncodedProfilePicture!=null)
      {
        var file = base64Decode(base64.normalize(base64EncodedProfilePicture));
        File(root).writeAsBytes(file); //save file
        return root; 
      }
    }

    return null; 
  }

  Future<String?> saveProfilePictureFileAndReturnPath(File? ProfilePictureFile, 
                                                  String? username) async
  {
    if(username != null)
    {
      final directory=await getApplicationDocumentsDirectory();
      final root = '${directory.path}/${username}ProfilePicture.png';

      try { await File(root).delete(); } catch(e){ } //delete if exists

      if(ProfilePictureFile!=null)
      {
        await File(ProfilePictureFile.path).copy(root);
        return root;
      }
    }
  }

  Future changeMessageStatus(String contraryUsername, int idMessage, String status, {var messagesFromStorage}) async
  {
    var lastMessage = this._lastMessages.get(contraryUsername);
    if(lastMessage?.id == idMessage) 
    {
      lastMessage?.status = status;
      this._putMessageToLastMessages(contraryUsername, lastMessage);
    }

    if(messagesFromStorage == null)
      messagesFromStorage = await this.getMessagesOfConversation(contraryUsername);

    for(Message message in messagesFromStorage) 
    {
      if(message.id==idMessage)
      {
        message.status = status;
        await this._saveMessagesOfConversation(contraryUsername, messagesFromStorage);
        
        return;
      }
    }
  }

  void markAsReadedLastMessage(String contraryUsername)
  {
    if(this._lastMessages.get(contraryUsername) != null) //to escape from errors
    {
      Message lastMessage = this._lastMessages.get(contraryUsername) ;
      lastMessage.numberOfCurrentUnreadMessages = 0;
      this._putMessageToLastMessages(contraryUsername, lastMessage);
    };
  }

  getLastMessagesListener()
  {
    return Hive.box<Message>("${this._username}lastMessages").listenable();
  }

  getMessagesListener()
  {
    return Hive.lazyBox<List>("${this._username}conversations").listenable();
  }
	
  //update content by backend message
	@override
  void update(String caseOfUpdate, var data) 
	{
    switch(caseOfUpdate)
    {
      case "putUser":
        this.putUserToStorage(data);
        break;

      case "messageStatus":
        this.changeMessageStatus(data["username"], data["identifierNumber"], data["status"]);
        break;

      case "message":
        int currentCountOfUnreadMessages = 0;
        if( this._lastMessages.get(data["contraryUsername"])!=null)
          currentCountOfUnreadMessages = this._lastMessages.get(data["contraryUsername"]).numberOfCurrentUnreadMessages;

        Message newMessage = Message(0, data["content"], data["type"], DateTime.now(), isFromCurrentUser: false, 
                                    numberOfCurrentUnreadMessages: currentCountOfUnreadMessages + 1);

        this.addMessageToConversation(data["contraryUsername"], newMessage);
        
        break;
    }
	}
}