import 'package:chatapp/models/Conversation.dart';
import 'package:chatapp/models/User.dart';
import 'package:chatapp/screens/MainScreens/ChatsScreens/ChatScreen.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget
{
  User user;
  ChatsScreen({Key? key, required User this.user}) : super(key: key);

  @override
  _ChatsScreen createState() => _ChatsScreen();
}

class _ChatsScreen extends State<ChatsScreen>
{
  List<Conversation> conversations = [];

  @override
  void initState() 
  {
    widget.user.getConversations().then((conversation) => 
    setState(()=>
    {
      conversations=conversation,
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

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
              itemCount: conversations.length,
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
                          backgroundImage: conversations[index].user.getUserPictureWidget(),
                          radius: _height*4.5/100,
                        ),
                        /*
                        if(chatsData[index].isActive) 
                          Positioned
                          (
                            right: 0,
                            bottom: 0,
                            child: Container
                            (
                              height: _height*2.2/100,
                              width: _height*2.2/100,
                              decoration: BoxDecoration
                              (
                                color: const Color(0xffb139c1e),
                                shape: BoxShape.circle,
                                border: Border.all
                                (
                                  color: Color(0xffb000000),
                                  width: _height*0.27/100,
                                )
                              ),
                            ),
                          )*/
                      ]
                    ),
                    Expanded
                    (
                      child: Padding
                      (
                        padding: EdgeInsets.symmetric(horizontal: _width*3.5/100),
                        child: InkWell
                        (
                          onTap: ()=>Navigator.push
                          (
                            context, MaterialPageRoute
                            (
                              builder: (context)=>ChatScreen(currentUser: widget.user, conversation: conversations[index])
                            )
                          ),
                          child: Column
                          (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: 
                            [
                              Text
                              (
                                conversations[index].user.Username?? "",
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
                                  conversations[index].messagesStack[0].getTicksWidgetIfIsNecessary(Colors.white70),
                                  Opacity
                                  (
                                    opacity: 0.7,
                                    child: Text
                                    (
                                      conversations[index].getLastMessage().length>16 ? 
                                        conversations[index].getLastMessage().substring(0, 16) + "..." : conversations[index].getLastMessage(),
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
                    
                    Opacity
                    (
                      opacity: 0.7,
                      child: Text
                      (
                        conversations[index].getLastMessageDateTimeFormated(),
                        style: TextStyle(color: Colors.white),
                      )
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

