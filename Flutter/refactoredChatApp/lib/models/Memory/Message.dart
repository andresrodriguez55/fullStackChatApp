import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'Message.g.dart';

@HiveType(typeId: 2)
class Message extends HiveObject
{
  @HiveField(0)
	int id;

  @HiveField(1)
	String content;
	
  @HiveField(2)
  String type;

  @HiveField(3)
	DateTime dateTime;

  @HiveField(4)
  bool isFromCurrentUser;

  @HiveField(5)
  String? status; //status of message of current user, the status value can be "waiting", "server" or "client"

  @HiveField(6)
  int numberOfCurrentUnreadMessages; //to increase speed when displaying unread messages easily
	
	Message(this.id, this.content, this.type, this.dateTime, 
    {this.isFromCurrentUser = true, this.status, this.numberOfCurrentUnreadMessages = 0});

  String getMessageHourFormated()
  {
    return DateFormat('hh:mm').format(this.dateTime);
  }

  bool _isTheMessageFromToday()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return (today.day==this.dateTime.day && today.month==this.dateTime.month
      && today.year==this.dateTime.year);
  }

  bool _isTheMessageFromYesterday()
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday=today.subtract(Duration(days: 1));

    return (yesterday.day==this.dateTime.day && yesterday.month==this.dateTime.month
      && yesterday.year==this.dateTime.year);
  }

  String getMessageDateTimeFormated({required bool getHourFormatIfIsFromToday})
  {
    if(_isTheMessageFromToday())
      return getHourFormatIfIsFromToday ? getMessageHourFormated() : "Today";
      
    if(_isTheMessageFromYesterday())
      return "Yesterday";

    return DateFormat('dd/MM/yyyy').format(this.dateTime);
  }

  bool doesTheMessageHaveTheSameDate(DateTime anotherDate)
  {
    return (anotherDate.day==this.dateTime.day && anotherDate.month==this.dateTime.month
      && anotherDate.year==this.dateTime.year );
  }

  String showOnlyPrefixOfContent()
  {
    if(this.type == "Text")
      return this.content.length>16 ? this.content.substring(0, 16) + "..." : this.content;

    return "media";
  }
}