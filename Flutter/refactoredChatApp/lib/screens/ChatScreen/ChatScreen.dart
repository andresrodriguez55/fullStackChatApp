
import 'dart:io';

import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/Memory/Conversation.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/Memory/BackendObserver.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/ProfileScreen.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatScreen extends StatefulWidget
{
  Client client;
  User contraryUser;
  List<dynamic> messagesFromStorage;

  ChatScreen(this.client, this.contraryUser, this.messagesFromStorage, {Key? key}) : super(key: key);

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> 
{
  late List<dynamic> messagesFromStorage; 
  late User contraryUser;

  @override
  void initState() 
  {
    messagesFromStorage = widget.messagesFromStorage;
    contraryUser = widget.contraryUser;
    super.initState();
  }

  //lazybox gets every time new instance, then we are using here a different instance than what memory class is using
  void updateShowedMessages() async 
  {
    messagesFromStorage = await widget.client.getMessagesOfConversation(contraryUser.username?? "");
    widget.client.markAsReadedLastMessage(contraryUser.username?? "");
    if(mounted)
      setState((){}); //refresh page
  }

  final textController = TextEditingController();

  InkWell getAppBarRow(double _height, double _width, BuildContext context)
  {
    return InkWell
    (
      onTap: ()=> Navigator.of(context).push
      (
        MaterialPageRoute
        (
          builder: (context)=>ProfileScreen(widget.client, contraryUser: contraryUser)
        )
      ),
      child: Row
      (
        children: 
        [
          CircleAvatar
          (
            backgroundImage: contraryUser.profilePicturePath != null ?
                            Image.file(File(contraryUser.profilePicturePath?? ""), key: UniqueKey()).image :
                            AssetImage("assets/images/profilePhoto.png"),
            radius: _height*2.3/100,
          ),
          Column
          (
            children: 
            [
              Padding
              (
                padding: EdgeInsets.only(left: _width*3/100),
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    Text
                    (
                      contraryUser.username?? "", 
                      style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  ListView getMessages(double _height, double _width)
  {
    Widget getDateWidget(Message message)
    {
      return Row
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
          Container
          (
            constraints: BoxConstraints(minWidth: _width*90/100),
            margin: EdgeInsets.only(top: _height*2/100, left: _width*3.3/100, right: _width*3.3/100),
            padding: EdgeInsets.symmetric(horizontal: _width*3/100, vertical: _height*1.4/100),
            decoration: BoxDecoration
            (
              borderRadius: BorderRadius.circular(10), 
              color: Colors.white70
            ),
            child: Text
            ( 
              message.getMessageDateTimeFormated(getHourFormatIfIsFromToday: false),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.0, color: Colors.black)),
              
          )
        ],
      );
    }

    Widget getDateWidgetIfIsNecessary(List<dynamic> messages, int actualIndex)
    {
      if(actualIndex!=messages.length-1 && !messages[actualIndex+1].doesTheMessageHaveTheSameDate(messages[actualIndex].dateTime))
      {  
        return getDateWidget(messages[actualIndex]);
      }
      
      else if(actualIndex==messages.length-1)
      {
        return getDateWidget(messages[actualIndex]);
      }

      return Container();
    }
    
    return ListView.builder
    (
      itemCount: messagesFromStorage.length,
      reverse: true,
      shrinkWrap: true,
      itemBuilder: (context, index) => Column
      (
        children: 
        [
          getDateWidgetIfIsNecessary(messagesFromStorage, index),
          Row
          (
            mainAxisAlignment: (messagesFromStorage[index].isFromCurrentUser) ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: 
            [
              if(messagesFromStorage[index].type=="Text")
                Row
                (
                  children: 
                  [ 
                    Container
                    (
                      constraints: BoxConstraints(maxWidth: _width*80/100),
                      margin: EdgeInsets.only(top: _height*2/100, left: _width*3.3/100, right: _width*3.3/100),
                      padding: EdgeInsets.symmetric(horizontal: _width*3/100, vertical: _height*1.4/100),
                      decoration: BoxDecoration
                      (
                        borderRadius: BorderRadius.circular(10), 
                        color: (messagesFromStorage[index].isFromCurrentUser) ? Colors.yellowAccent : Colors.white
                      ),
                      child: Column
                      (
                        crossAxisAlignment: (messagesFromStorage[index].isFromCurrentUser) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: 
                        [
                          Text
                          (
                            messagesFromStorage[index].content,
                          ),
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Container
                            (
                              margin: EdgeInsets.only(top: _height*1/100),
                              
                              child: Row
                              (
                                mainAxisAlignment: (messagesFromStorage[index].isFromCurrentUser) ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: 
                                [
                                  Text
                                  (
                                    messagesFromStorage[index].getMessageHourFormated(), 
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
              
                                  if(messagesFromStorage[index].isFromCurrentUser)
                                    Row
                                    (
                                      children: 
                                      [
                                        SizedBox(width: 5,),
                                        (messagesFromStorage[index].status=="client") ?
                                        Icon(Icons.done_all, color: Colors.black, size: 15) :
                                        (messagesFromStorage[index].status=="server") ?
                                          Icon(Icons.check, color: Colors.black, size: 15) : 
                                          Icon(Icons.access_time, color: Colors.black, size: 15),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                )       
            ],
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return Scaffold
    (
      appBar: AppBar
      (
        backgroundColor: Color(0xffb2b8016),
        title: getAppBarRow(_height, _width, context)
      ),

      body: Container
      (
        color: Color(0XFFB142238),
        child:Column
        (
          children: 
          [
            Expanded
            (
              child: ValueListenableBuilder<LazyBox>
              (
                valueListenable: widget.client.getMessagesListener(),
                builder: (context, box, widget) 
                { 
                  updateShowedMessages();
                  return getMessages(_height, _width); 
                }
              )
            ),
            Align
            (
              alignment: Alignment.bottomCenter,
              child: Container
              (
                margin: EdgeInsets.only(bottom: _height*1.5/100, top: _height*1.5/100),
                child: Row
                ( 
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: 
                  [
                    Container
                    (
                      width: _width*86/100,
                      child: Card
                      (
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        margin: EdgeInsets.only(left: _width*6/(2*100), right: _width*6/(2*100), ),
                        child: TextFormField
                        (
                          controller: textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 6,
                          decoration: InputDecoration
                          (
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.emoji_emotions_outlined),
                            hintText: "Type a message...",
                            
                          ), 
                        )
                      )
                    ),

                    InkWell
                    (
                      onTap: () => 
                      {
                        if(textController.text.length>0)
                        {
                          widget.client.addMessageToConversation
                          (
                            contraryUser.username?? "", 
                            Message
                            (
                              messagesFromStorage.length, 
                              textController.text, 
                              "Text", 
                              DateTime.now(), 
                              status: "waiting"
                            ),
                          ),
                          textController.text=''
                        }
                      },

                      child: CircleAvatar
                      (
                        radius: _width*11.5/(2*100),
                        backgroundColor: Color(0xffb2b8016),
                        child: Icon
                        (
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }


}