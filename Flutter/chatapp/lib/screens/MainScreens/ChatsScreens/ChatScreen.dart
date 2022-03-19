import 'package:chatapp/models/Conversation.dart';
import 'package:chatapp/models/Message.dart';
import 'package:chatapp/models/User.dart';
import 'package:chatapp/screens/MainScreens/ProfileScreen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget
{
  User currentUser;
  Conversation conversation;

  ChatScreen({Key? key, required this.currentUser, required this.conversation}) : super(key: key);

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen>
{
  final textController = TextEditingController();

  void appendNewMessage(Message newMessage)
  {
    debugPrint("${newMessage.indetifierNumber}");
    widget.currentUser.saveNewMessageToMemory(newMessage, widget.conversation.user);
    widget.currentUser.sendMessageSocket(widget.conversation.user.Username, newMessage);
    setState(() => widget.conversation.messagesStack.insert(0, newMessage));
  }

  InkWell getAppBarRow(double _height, double _width, BuildContext context)
  {
    widget.conversation.user.isTheUserTheCurrentUser=false;
    return InkWell
    (
      onTap: ()=> Navigator.of(context).push
      (
        MaterialPageRoute
        (
          builder: (context)=>ProfileScreen(currentUser: widget.conversation.user, ownerUser: widget.currentUser,)
        )
      ),
      child: Row
      (
        children: 
        [
          CircleAvatar
          (
            backgroundImage:  widget.conversation.user.getUserPictureWidget(),
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
                      widget.conversation.user.Username?? "", 
                      style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 2),
                    /*Text
                    (
                      "Active 5m ago", 
                      style: TextStyle(fontSize: 12),
                      ),*/
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
              (message.isTheMessageFromToday()) ? 
                "Today" : (message.isTheMessageFromYesterday()) ? "Yesterday" :  message.getMessageDateFormated(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.0, color: Colors.black)),
              
          )
        ],
      );
    }

    Widget getDateWidgetIfIsNecessary(List<Message> messages, int actualIndex)
    {
      if(actualIndex!=messages.length-1 && !messages[actualIndex+1].doesTheMessageHaveTheSameDate(messages[actualIndex].date!))
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
      itemCount: widget.conversation.messagesStack.length,
      reverse: true,
      shrinkWrap: true,
      itemBuilder: (context, index) => Column
      (
        children: 
        [
          getDateWidgetIfIsNecessary(widget.conversation.messagesStack, index),
          Row
          (
            mainAxisAlignment: (widget.conversation.messagesStack[index].isTheMessageOfTheCurrentUser!) ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: 
            [
              if(widget.conversation.messagesStack[index].type=="Text")
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
                        color: (widget.conversation.messagesStack[index].isTheMessageOfTheCurrentUser!) ? Colors.yellowAccent : Colors.white
                      ),
                      child: Column
                      (
                        crossAxisAlignment: (widget.conversation.messagesStack[index].isTheMessageOfTheCurrentUser!) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: 
                        [
                          Text
                          (
                            widget.conversation.messagesStack[index].content!,
                          ),
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Container
                            (
                              margin: EdgeInsets.only(top: _height*1/100),
                              
                              child: Row
                              (
                                mainAxisAlignment: (widget.conversation.messagesStack[index].isTheMessageOfTheCurrentUser!) ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: 
                                [
                                  Text
                                  (
                                    widget.conversation.messagesStack[index].getMessageHourFormated(), 
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                  SizedBox(width: 4,),
                                  widget.conversation.messagesStack[index].getTicksWidgetIfIsNecessary(Colors.black)
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
            Expanded(child: getMessages(_height, _width)),
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
                          appendNewMessage(
                            Message.currentUserMessage(textController.text, "Text", 
                              DateTime.now(), widget.conversation.messagesStack.length
                            )
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