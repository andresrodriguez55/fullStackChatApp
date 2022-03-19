import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message
{
  String? content;
  String? type;
  DateTime? date;
  bool? isTheMessageOfTheCurrentUser;
  bool? doesMessageReachedServer;
  bool? doesMessageReachedReceiver;
  int? indetifierNumber;

  Message(this.content, this.type, this.date, this.isTheMessageOfTheCurrentUser, 
    this.doesMessageReachedServer, this.doesMessageReachedReceiver, [this.indetifierNumber]);

  Message.currentUserMessage(this.content, this.type, this.date, this.indetifierNumber, [this.isTheMessageOfTheCurrentUser=true, 
    this.doesMessageReachedServer=false, this.doesMessageReachedReceiver=false]);

  Message.contraryUserMessage(this.content, this.type, this.date, [this.isTheMessageOfTheCurrentUser=false]);

  Map<String, dynamic> toJson()
  {
    return 
    {
      "content" : this.content,
      "type" : this.type,
      "date" : this.date==null ? null : this.date?.toIso8601String(),
      "isTheMessageOfTheCurrentUser" : this.isTheMessageOfTheCurrentUser,
      "doesMessageReachedServer" : this.doesMessageReachedServer,
      "doesMessageReachedReceiver" : this.doesMessageReachedReceiver,
      "identifierNumber" : this.indetifierNumber,
    };
  }

  factory Message.returnObjectFromJson(Map<String, dynamic> jsonData)
  {
    return Message
    (
      jsonData["content"],
      jsonData["type"],
      jsonData["date"] == null ? null : DateTime.parse(jsonData["date"]),
      jsonData["isTheMessageOfTheCurrentUser"],
      jsonData["doesMessageReachedServer"],
      jsonData["doesMessageReachedReceiver"],
      jsonData["identifierNumber"]
    );
  }

  String getMessageHourFormated()
  {
    return DateFormat('hh:mm').format(this.date!);
  }

  String getMessageDateFormated()
  {
    return DateFormat('dd/MM/yyyy').format(this.date!);
  }

  bool isTheMessageFromToday()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return (today.day==this.date!.day && today.month==this.date!.month
      && today.year==this.date!.year);
  }

  bool isTheMessageFromYesterday()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday=today.subtract(Duration(days: 1));

    return (yesterday.day==this.date!.day && yesterday.month==this.date!.month
      && yesterday.year==this.date!.year);
  }

  bool doesTheMessageHaveTheSameDate(DateTime anotherDate)
  {
    return (anotherDate.day==this.date!.day && anotherDate.month==this.date!.month
      && anotherDate.year==this.date!.year );
  }

  Widget getTicksWidgetIfIsNecessary(Color selectedColor)
  {
    if(this.isTheMessageOfTheCurrentUser?? false)
    {
      return Row
      (
        children: 
        [
          (this.doesMessageReachedReceiver?? false) ?
              Icon(Icons.done_all, color: selectedColor, size: 17) : 
              (this.doesMessageReachedServer?? false) ?
                Icon(Icons.check, color: selectedColor, size: 17) : Icon(Icons.access_time, color: selectedColor, size: 17),

          SizedBox(width: 4,),
        ],
      );
    }

    return Container();
  }
}