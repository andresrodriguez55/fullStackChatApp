import 'dart:io';

import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/Memory/Conversation.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/ChatScreen/ChatScreen.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget
{
  Client client;
  ChatsScreen(this.client, {Key? key}) : super(key: key);

  @override
  _ChatsScreen createState() => _ChatsScreen();
}

class _ChatsScreen extends State<ChatsScreen>
{
  @override
  void initState() 
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return ValueListenableBuilder
    (
      valueListenable: widget.client.getLastMessagesListener(),
      builder: (context, child, value)
      {
         return FutureBuilder<List<Conversation>>
        (
          future: widget.client.getConversations(),
          builder: (context, conversations)
          { 
            if(conversations.connectionState != ConnectionState.done)
              return Container(color: Color(0XFFB142238));
      
            else
            {
              return Container
              (
                color: Color(0XFFB142238),
            
                child:Column
                ( 
                  children:
                  [
                    Expanded
                    (
                      child: ListView.builder
                      (
                        itemCount: conversations.data?.length,
                        itemBuilder: (context, index) => 
                        Padding
                        (
                          padding: EdgeInsets.symmetric(horizontal: _width*5/100, vertical: _height*2/100),
                          child: Row
                          (
                            children: 
                            [
                              Stack
                              (
                                children: 
                                [
                                  CircleAvatar
                                  (
                                    backgroundImage: conversations.data?[index].contraryUser.profilePicturePath != null ?
                                      Image.file(File(conversations.data?[index].contraryUser.profilePicturePath?? ""), key: UniqueKey()).image :
                                      AssetImage("assets/images/profilePhoto.png"),
                                    radius: _height*4.5/100,
                                  ),
                                ]
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
                                      List<dynamic> messagesFromStorage = await widget.client.getMessagesOfConversation(conversations.data?[index].contraryUser.username?? "");
                                      Navigator.push
                                      (
                                        context, MaterialPageRoute
                                        (
                                          builder: (context)=>ChatScreen(widget.client, conversations.data?[index].contraryUser as User, messagesFromStorage)
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
                                          conversations.data?[index].contraryUser.username?? "",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                                        ),
                                        SizedBox
                                        (
                                          height: _height*0.6/100,
                                        ),
                                        Row
                                        (
                                          children: 
                                          [
                                            if(conversations.data?[index].lastMessage.isFromCurrentUser?? false) 
                                              Row
                                              (
                                                children: 
                                                [
                                                  (conversations.data?[index].lastMessage.status=="client") ?
                                                    Icon(Icons.done_all, color: Colors.grey, size: 17) :
                                                    (conversations.data?[index].lastMessage.status=="server") ?
                                                      Icon(Icons.check, color: Colors.grey, size: 17) : 
                                                      Icon(Icons.access_time, color: Colors.grey, size: 17),
                                                  SizedBox(width: 5,)
                                                ],
                                              ),
            
                                            Opacity
                                            (
                                              opacity: 0.7,
                                              child: Text
                                              (
                                                conversations.data?[index].lastMessage.showOnlyPrefixOfContent()?? "",
                                                style: TextStyle(color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        )
                                        
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              Column
                              (
                                children: 
                                [
                                  Opacity
                                  (
                                    opacity: 0.7,
                                    child: Text
                                    (
                                      conversations.data?[index].lastMessage.getMessageDateTimeFormated(getHourFormatIfIsFromToday: true)?? "",
                                      style: TextStyle(color: conversations.data?[index].lastMessage.numberOfCurrentUnreadMessages == 0 ? Colors.white : Color(0xffb2b8016)),
                                    )
                                  ),
                                  SizedBox
                                  (
                                    height: _height*0.6/100,
                                  ),
                                  if(conversations.data?[index].lastMessage.numberOfCurrentUnreadMessages != 0)  
                                    Container
                                    (
                                      width: _width*4.2/100,
                                      height: _width*4.2/100,
                                      decoration: new BoxDecoration
                                      (
                                        color: Color(0xffb2b8016),
                                        shape: BoxShape.circle,
                                      )
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              );
            }
          }
        );
      }
    );
  } 
}

