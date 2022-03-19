import 'dart:convert';

import 'package:chatapp/models/Message.dart';
import 'package:chatapp/models/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Conversation
{
  User user;
  List<Message> messagesStack;

  Conversation(this.user, this.messagesStack);

  Map<String, dynamic> toJson()
  {
    return
    {
      "user" : this.user.toJson(),
      "messagesStack" : this.messagesStack.map<Map<String, dynamic>>((message)=>message.toJson()).toList()
    };
  }

  factory Conversation.returnObjectFromJson(Map<String, dynamic> jsonData)
  {
    return Conversation
    (
      User.returnObjectFromJson(jsonData["user"]),

      List<Message>.from
      (
        jsonData["messagesStack"].map((message)=>
          Message.returnObjectFromJson(message) 
        )
      )

    );
  }

  String getLastMessage()
  {
    return 
    (
      this.messagesStack[0].content!
    );
  }

  String getLastMessageDateTimeFormated()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    final index=this.messagesStack.length-1;

    if(messagesStack[0].date==null)
      return "";

    if(messagesStack[0].date!.day==today.day && messagesStack[0].date!.month==today.month
      && messagesStack[0].date!.year==today.year)
    {
      return DateFormat('hh:mm').format(messagesStack[0].date!);
    }

    if(messagesStack[0].date!.day==yesterday.day && messagesStack[0].date!.month==yesterday.month
      && messagesStack[0].date!.year==yesterday.year)
    {
      return "Yesterday";
    }

    return DateFormat('dd/MM/yyyy').format(messagesStack[0].date!);
  }
}