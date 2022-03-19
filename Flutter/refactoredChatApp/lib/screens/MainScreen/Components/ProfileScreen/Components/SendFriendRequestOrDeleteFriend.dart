import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:flutter/material.dart';

class SendFriendRequestOrDeleteFriend extends StatefulWidget
{
  Client client;
  User contraryUser;
  SendFriendRequestOrDeleteFriend(this.client, this.contraryUser, {Key? key}) : super(key: key);

  @override
  _SendFriendRequestOrDeleteFriend createState()=>_SendFriendRequestOrDeleteFriend();
} 

class _SendFriendRequestOrDeleteFriend extends State<SendFriendRequestOrDeleteFriend>
{
  bool requestLoading=false;
  bool isFriendDeleted=false; //for optimization

  bool areTheyFriends()
  {
    List<String>? clientFriendsUsernames = widget.client.getCurrentUser().friendsUsernames;
    if(clientFriendsUsernames == null)
      return false;

    var n = clientFriendsUsernames.length;
    for(var index = 0; index<n; index++)
    {
      if(widget.contraryUser.username == clientFriendsUsernames[index])
        return true;
    }

    return false;
  }

  void deleteFriend(BuildContext context) async
  {
    setState(()=>requestLoading=true);
    await widget.client.deleteFriend(widget.contraryUser.username?? "");
    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar
      (
        content: Text('Friend deleted :(', style: TextStyle(fontSize: 17, color: Colors.white))
      )
    );
    setState(()
    {
      isFriendDeleted=true;
      requestLoading=false;
    });
  }

  void postFriendRequest(BuildContext context) async
  {
    setState(()=>requestLoading=true);
    await widget.client.sendFriendRequest(widget.contraryUser.username?? "");
    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar
      (
        content: Text('Request sended!', style: TextStyle(fontSize: 17, color: Colors.white))
      )
    );
    setState(()=>requestLoading=false);
  }

  @override
  Widget build(BuildContext context)
  {
    var _height=MediaQuery.of(context).size.height;
    
    if(!isFriendDeleted && areTheyFriends())
    {
      return Container
      (
        padding: EdgeInsets.only(top: _height*2/100),
        child: Row
        (
          children: 
          [
            Expanded
            (
              child: ButtonTheme
              (
                child: ElevatedButton
                (
                  style: ElevatedButton.styleFrom
                  (
                    padding: EdgeInsets.all(10),
                    primary: Colors.red,
                  ),
                  onPressed: ()=>deleteFriend(context),
                  
                  child: requestLoading ? 
                    CircularProgressIndicator(color: Colors.white,) : 
                    Row
                    (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: 
                      [
                        Icon(Icons.person_remove_sharp, size: 25,),
                        SizedBox(width: 10,),
                        Text("Delete", style: TextStyle(fontSize: 18),)
                      ],
                    ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container
    (
      padding: EdgeInsets.only(top: _height*2/100),
      child: Row
      (
        children: 
        [
          Expanded
          (
            child: ButtonTheme
            (
              child: ElevatedButton
              (
                style: ElevatedButton.styleFrom
                (
                  padding: EdgeInsets.all(10),
                  primary: Color(0xffb2b8016),
                ),
                onPressed: ()=>postFriendRequest(context),
                
                child: requestLoading ? 
                  CircularProgressIndicator(color: Colors.white,) : 
                  Row
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: 
                    [
                      Icon(Icons.person_add_alt_rounded, size: 25,),
                      SizedBox(width: 10,),
                      Text("Add", style: TextStyle(fontSize: 18),)
                    ],
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
