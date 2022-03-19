import 'dart:io';
import 'package:chatapp/models/User.dart';
import 'package:flutter/material.dart';

import '../ChatsScreens/ChatScreen.dart';

class SearchFriendsToChatScreen extends StatefulWidget 
{
  User? user;
  SearchFriendsToChatScreen({this.user, Key? key}) : super(key: key);

  @override
  _SearchFriendsToChatScreen createState() => _SearchFriendsToChatScreen();
}

class _SearchFriendsToChatScreen extends State<SearchFriendsToChatScreen> 
{
  List<User>? friendList;
  bool searchMod=false;

  @override
  void initState() 
  {
    friendList=widget.user!.Friends!;
    super.initState();
  }

  void switchSearchMod()
  {
    setState(()
    {
      searchMod=!searchMod;
      if(!searchMod)
        friendList=widget.user!.Friends!;
    });
  }

  void filterFriendList(String searchedString)
  {
    setState(() 
    {
      friendList=widget.user!.Friends!.where((friend) => 
        friend.Username!.contains(searchedString) || friend.Name!.contains(searchedString)
      ).toList();
    });
  }

  AppBar getAppBar()
  {
    if(!searchMod)
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
              onChanged: (text)=>filterFriendList(text),
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
            itemCount: friendList!.length,
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
                    backgroundImage: (friendList![index].UserPicturePath!=null) ? 
                      Image.file(File(friendList![index].UserPicturePath!), key: UniqueKey()).image :
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
                        onTap: ()=>
                        {
                          widget.user!.getConversation(friendList![index]).then((conv)=>
                            Navigator.push
                            (
                              context, MaterialPageRoute
                              (
                                builder: (context)=>ChatScreen(currentUser: widget.user!, conversation: conv),
                              )
                            )
                          )                        
                        },
                        child: Column
                        (
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: 
                          [
                            Text
                            (
                              friendList![index].Username!,
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
                                friendList![index].Name!,
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