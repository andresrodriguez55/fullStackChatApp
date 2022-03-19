import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/Backend/Backend.dart';
import 'package:chatapp/models/Memory/Conversation.dart';
import 'package:chatapp/models/Memory/Memory.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:flutter/material.dart';

/*
flutter run -d emulator-5554  --no-sound-null-safety
flutter run -d emulator-5556  --no-sound-null-safety
 */

class Client
{
  late User _user;
	late Backend _backend;
	late Memory _memory;

  Client()
  {
    _backend = Backend();
    _memory = Memory();
    _backend.rest_api.setMemoryObserver(_memory); //set memory observer to rest api
    _backend.socketTransporter.setMemoryObserver(_memory); //set memory observer to rest api
  }

	Future<bool> hasTheSessionBeenStartedSuccessfully(String username, String password) async
	{
		User? serverUserCopy = await _backend.rest_api.login(username, password); //initialize rest api
    if(serverUserCopy == null)
      return false;

    _user = serverUserCopy; //user data from rest api
    await _memory.initializeConversationStorage(username); //initialize user conversations
    _backend.socketTransporter.login(username, password); //initialize alive TCP connection
    
    return true;
	}
	
	User getCurrentUser()
	{
		return _user;
	}
	
	Future<bool> updateProfilePicture(File? newUserPicture) async
	{
    bool wasTheOperationPerformed = await _backend.rest_api.updateUserProfilePicture(newUserPicture);
    if(!wasTheOperationPerformed)
    {
      return false;
    }

    String? userPicturePath = await _memory.saveProfilePictureFileAndReturnPath(newUserPicture, _user.username);
		_user.setProfilePicturePath(userPicturePath);
    return true;
	}
	
	Future<bool> updateName(String? newName) async
	{
		bool wasTheOperationPerformed = await _backend.rest_api.updateUserName(newName);
    if(!wasTheOperationPerformed)
      return false;

		_user.setName(newName);
    return true;
	}
	
	Future<bool> sendFriendRequest(String contraryUsername) async
	{
		bool wasTheOperationPerformed = await _backend.rest_api.sendUserFriendRequest(contraryUsername);
    if(!wasTheOperationPerformed)
      return false;

    return true;
	}
	
	Future<bool> deleteFriend(String contraryUsername) async
	{
		bool wasTheOperationPerformed = await _backend.rest_api.deleteUserFriend(contraryUsername);
    if(!wasTheOperationPerformed)
      return false;

    //delete from ram
    _user.deleteFriendUsername(contraryUsername);

    return true;
	}
	
	Future<bool> acceptFriendRequest(String contraryUsername) async
	{
		bool wasTheOperationPerformed = await _backend.rest_api.acceptUserFriendRequest(contraryUsername);
    if(!wasTheOperationPerformed)
      return false;

    //add to ram
    _user.addFriendUsername(contraryUsername);
    _user.deleteRequestUsername(contraryUsername);

    return true;
	}
	
	Future<bool> rejectFriendRequest(String contraryUsername) async
	{
		bool wasTheOperationPerformed = await _backend.rest_api.rejectUserFriendRequest(contraryUsername);
    if(!wasTheOperationPerformed)
      return false;

    //delete from ram
    _user.deleteRequestUsername(contraryUsername);

    return true;
	}
	
	Future<User?> getSearchedUser(String? searchedUsername) async 
  {
    User? searchedUser = await _backend.rest_api.getSearchedUser(searchedUsername);

    return searchedUser;
	}
	
	Future<List<User?>?> getSearchedUsers(String? token) async
	{
    List<User?>? searchedUsers = await _backend.rest_api.getSearchedUsers(token);

    return searchedUsers;
	}
	
	List<User> getFriends() 
	{
    List<String> usernames = _user.friendsUsernames?? <String>[];
    return _memory.getUsersFromStorage(usernames);
	}
	
	List<User> getRequests() 
	{
    List<String> usernames = _user.requestsUsernames?? <String>[];
    return _memory.getUsersFromStorage(usernames);
	}

  Future<List<Conversation>> getConversations() async
  {
    List<Conversation> conversations = await this._memory.getConversations();
    return conversations;
  }

  Future<List<dynamic>> getMessagesOfConversation(String username) async
  {
    List<dynamic> messages = await this._memory.getMessagesOfConversation(username);
    return messages;
  }
	
	Future addMessageToConversation(String contraryUsername, Message message, {var messagesFromStorage}) async 
	{
    if(messagesFromStorage != null)
      await _memory.addMessageToConversation(contraryUsername, message, messagesFromStorage: messagesFromStorage);
    else
      await _memory.addMessageToConversation(contraryUsername, message);
    _backend.socketTransporter.sendSocket
    (
      {
        "identifierNumber" : message.id,
        "content" : message.content,
        "type" : message.type,
        "receiver" : contraryUsername,
      }
    );
	}

  void markAsReadedLastMessage(String contraryUsername)
  {
    this._memory.markAsReadedLastMessage(contraryUsername);
  }

  getMessagesListener()
  {
    return this._memory.getMessagesListener();
  }

  getLastMessagesListener()
  {
    return this._memory.getLastMessagesListener();
  }
}