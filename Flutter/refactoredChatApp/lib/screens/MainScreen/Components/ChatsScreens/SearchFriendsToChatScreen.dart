
import 'dart:io';
import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/ChatScreen/ChatScreen.dart';
import 'package:flutter/material.dart';

class SearchFriendsToChatScreen extends StatefulWidget 
{
  Client client;
  SearchFriendsToChatScreen(this.client, {Key? key}) : super(key: key);

  @override
  _SearchFriendsToChatScreen createState() => _SearchFriendsToChatScreen();
}

class _SearchFriendsToChatScreen extends State<SearchFriendsToChatScreen> 
{
  late List<User> friends;
  late List<User> queryFriendList;
  bool userIsQueryingAName=false;
  
  @override
  void initState() 
  {
    friends = widget.client.getFriends();
    queryFriendList = List.from(friends);
    super.initState();
  }

  void switchSearchMod()
  {
    setState(()
    {
      userIsQueryingAName=!userIsQueryingAName;
      if(!userIsQueryingAName)
        queryFriendList = List.from(friends); //get all friend list again
    });
  }

  void filterQuery(String searchedString)
  {
    setState(() 
    {
      queryFriendList=friends.where((friend) => 
        friend.username!.contains(searchedString) || friend.name!.contains(searchedString)
      ).toList();
    });
  }

  AppBar getAppBar()
  {
    if(!userIsQueryingAName)
    {
      return AppBar
      (
        backgroundColor: Color(0xffb2b8016),
        automaticallyImplyLeading: false,
        title: Text("Friends"),
        actions: 
        [
          IconButton
          (
            onPressed: ()=> switchSearchMod(), 
            icon: Icon(Icons.search)
          )
        ],
      );
    }

    return AppBar
    (
      backgroundColor: Color(0xffb2b8016),
      automaticallyImplyLeading: false,
      title: Container
      (
        decoration: BoxDecoration
        (
          borderRadius: BorderRadius.circular(5)),
          child: Center
          (
            child: TextField
            (
              onChanged: (text)=>filterQuery(text),
              decoration: InputDecoration
              (
                filled: false,
                prefixIcon: InkWell
                (
                  onTap: ()=> switchSearchMod(),
                  child: Icon
                  (
                    Icons.arrow_back
                  ),
                ),
                hintText: 'Search...',
                border: InputBorder.none
              ),
            )
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return Material
    (
      child: Scaffold
      (
        appBar: getAppBar(),

        body: Container
        (
          color: Color(0XFFB142238),
          child: ListView.builder
          (
            itemCount: queryFriendList.length,
            itemBuilder: (context, index) => 
            Padding
            (
              padding: EdgeInsets.symmetric(horizontal: _width*5/100, vertical: _height*2/100),
              child: Row
              (
                children: 
                [
                  CircleAvatar
                  (
                    backgroundImage: (queryFriendList[index].profilePicturePath!=null) ? 
                      Image.file(File(queryFriendList[index].profilePicturePath?? ""), key: UniqueKey()).image :
                      AssetImage("assets/images/profilePhoto.png"),
                    radius: _height*4.5/100,
                  ),
                  Expanded
                  (
                    child: Padding
                    (
                      padding: EdgeInsets.symmetric(horizontal: _width*3.5/100),
                      child: InkWell
                      (
                        onTap: () async
                        {
                          List<dynamic> messagesFromStorage = await widget.client.getMessagesOfConversation(queryFriendList[index].username?? "");
                          Navigator.push
                          (
                            context, MaterialPageRoute
                            (
                              builder: (context)=>ChatScreen(widget.client, queryFriendList[index], messagesFromStorage),
                            )
                          );                        
                        },
                        child: Column
                        (
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: 
                          [
                            Text
                            (
                              queryFriendList[index].username?? "",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            SizedBox
                            (
                              height: _height*0.6/100,
                            ),
                            Opacity
                            (
                              opacity: 0.7,
                              child: Text
                              (
                                queryFriendList[index].name ?? "",
                                style: TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        
      ),
    );
  }
}