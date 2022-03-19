import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';

import 'package:chatapp/ServerData.dart';
import 'package:chatapp/models/Memory/BackendObserver.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/models/User/UserMakerDirector.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class REST_API
{
  //used to can auth http requests
	String? _username; 
	String? _password;
  BackendObserver? _memoryObserver;

	var _apiCommunicator= http.Client(); //used for http requests
	
	Future<User?> login(String? username, String? password) async  //GUARDAR USUARIOS A MEMORIA
  {
    var response = await _apiCommunicator.get( Uri.parse("${ServerData.SERVER_URL}/getUser/$username/$password") ); //define timeout

    if(response.statusCode==200)
    {
      var jsonData=jsonDecode(response.body);

      //set data
      this._username = jsonData["Username"];
      this._password = jsonData["Password"];

      List<String> friendsUsernames = [];
      if(jsonData["Friends"]!=null)
      {
        for(var friend in jsonData["Friends"]) //anadir datos a memory
        {
          friendsUsernames.add(friend["Username"]);

          User? user = await UserMakerDirector.makeSecondaryUser(friend["Username"], friend["Name"], friend["ProfilePicture"]);
          _memoryObserver?.update("putUser", user);
        }
      }

      List<String> requestsUsernames = [];
      if(jsonData["Requests"]!=null)
      {
        for(var request in jsonData["Requests"])
        {
          requestsUsernames.add(request["Username"]);

          User? user = await UserMakerDirector.makeSecondaryUser(request["Username"], request["Name"],request["ProfilePicture"]);
          _memoryObserver?.update("putUser", user);
        }
      }

      User? user = await UserMakerDirector.makePrimaryUser(jsonData["Username"], jsonData["Password"], jsonData["Email"], 
                                              jsonData["Name"], jsonData["ProfilePicture"], friendsUsernames,
                                              requestsUsernames);

      return user;
    }

    else
    {
      return null;
    }
	}

  void setMemoryObserver(BackendObserver memoryObserver)
  {
    this._memoryObserver = memoryObserver;
  }
	
	Future<bool> updateUserProfilePicture(File? newUserPicture) async 
  {
		final url=Uri.parse("${ServerData.SERVER_URL}/postProfilePicture/${this._username}/${this._password}");
    var request = new http.MultipartRequest("POST", url);

    if(newUserPicture!=null) //add file as image to POST request
    {
      var stream = new http.ByteStream(DelegatingStream.typed(newUserPicture.openRead()));
      var length = await newUserPicture.length();
      var multipartFile = new http.MultipartFile('ProfilePicture', stream, length,filename: "ProfilePicture");
      request.files.add(multipartFile);
    }

    await request.send().then((response) 
    {
      debugPrint("${response.statusCode}");
      if (response.statusCode == 200)
      { 
        return true;
      }
    });

    return true; //arreglar
	}
	
	Future<bool> updateUserName(String? newName) async
	{
		final url=Uri.parse("${ServerData.SERVER_URL}/updateName/${this._username}/${this._password}/${newName}");
    final response=await _apiCommunicator.put(url);
    if(response.statusCode==200)
    {
      return true;
    }
    return false;
	}
	
	Future<bool> sendUserFriendRequest(String? contraryUsername) async
	{
		final url=Uri.parse("${ServerData.SERVER_URL}/postFriendRequest/${this._username}/${this._password}/${contraryUsername}");
    var response = await _apiCommunicator.post(url);
    if(response.statusCode==200)
    {  
      return true;
    }
    return false;
	}
	
	Future<bool> deleteUserFriend(String? contraryUsername) async
	{
		final url=Uri.parse("${ServerData.SERVER_URL}/deleteFriend/${this._username}/${this._password}/${contraryUsername}");
    var response = await _apiCommunicator.post(url);
    if(response.statusCode==200) 
    {
      return true;
    }
    return false;
	}
	
	Future<bool> acceptUserFriendRequest(String? contraryUsername) async
	{
		final url=Uri.parse("${ServerData.SERVER_URL}/acceptFriendRequest/${this._username}/${this._password}/${contraryUsername}");
    var response = await _apiCommunicator.post(url);
    if(response.statusCode==200) 
    {
      return true;
    } 
    return false;
	}
	
	Future<bool> rejectUserFriendRequest(String? contraryUsername) async
	{
		final url=Uri.parse("${ServerData.SERVER_URL}/rejectFriendRequest/${this._username}/${this._password}/${contraryUsername}");
    var response = await _apiCommunicator.post(url);
    if(response.statusCode==200) 
    {
      return true;
    }
    return false;
	}

  Future<User?> getSearchedUser(String? username) async
	{
		
	}
	
	Future<List<User?>> getSearchedUsers(String? token) async
	{
    List<User?> result=<User?>[];

    final url=Uri.parse("${ServerData.SERVER_URL}/getUsersWhichContainString/${token}");
    final response=await _apiCommunicator.get(url);

    if(response.statusCode==200)
    {
      List<dynamic> jsonList = jsonDecode(response.body);

      for(var jsonUser in jsonList)
      {
        User? user = await UserMakerDirector.makeSecondaryUser(jsonUser["Username"], jsonUser["Name"], jsonUser["ProfilePicture"]);
        result.add(user);
      }
    }

    return result;
	}
}