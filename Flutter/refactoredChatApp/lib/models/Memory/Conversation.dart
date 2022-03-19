import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/User/User.dart';

class Conversation
{
	User contraryUser;
	Message lastMessage;
  int numberOfUnreadMessages;
  
	Conversation(this.contraryUser, this.lastMessage, {this.numberOfUnreadMessages=0});
}