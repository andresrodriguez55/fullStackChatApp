
import 'dart:io';

import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/ProfileScreen.dart';
import 'package:flutter/material.dart';

class FriendRequestsAndSearchUsersScreen extends StatefulWidget
{
  Client client;
  final Function() notifyParentGoToProfile; //function to redirection to another page

  FriendRequestsAndSearchUsersScreen(this.client, this.notifyParentGoToProfile, {Key? key}) : super(key: key);

  @override
  _FriendRequestsAndSearchUsersScreen createState() => _FriendRequestsAndSearchUsersScreen();
}

class _FriendRequestsAndSearchUsersScreen extends State<FriendRequestsAndSearchUsersScreen>
{
  final textController = TextEditingController();
  bool searchLoading=false;
  bool showSearchedResults=false;
  List<User?>? searchedUsers;
  late List<User> requestsUsers;

  @override
  void initState() 
  {
    requestsUsers = widget.client.getRequests();

    // TODO: implement initState
    super.initState();
  }

  void refresh()
  {
    if(mounted)
      setState((){});
  }

  Future acceptFriendRequest(String acceptUsername) async //add to friends
  {
    await widget.client.acceptFriendRequest(acceptUsername);
    refresh();
  }

  Future rejectFriendRequest(String rejectUsername) async
  {
    await widget.client.rejectFriendRequest(rejectUsername);
    refresh();
  }

  ListView showUserFriendRequests(double _width, double _height)
  {
    return ListView.builder
    (
      itemCount: this.requestsUsers.length,
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
              backgroundImage: this.requestsUsers[index].profilePicturePath != null ?
                                Image.file(File(this.requestsUsers[index].profilePicturePath?? ""), key: UniqueKey()).image :
                                AssetImage("assets/images/profilePhoto.png"),
              radius: _height*4.5/100,
            ),
            Expanded
            (
              child: Padding
              (
                padding: EdgeInsets.symmetric(horizontal: _width*3.5/100),
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: 
                  [
                    Text
                    (
                      this.requestsUsers[index].username?? "",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    SizedBox
                    (
                      height: _height*0.3/100,
                    ),
                    Text
                    (
                      this.requestsUsers[index].name?? (this.requestsUsers[index].username?? ""),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Row
            (
              children: 
              [
                InkWell
                (
                  onTap: () async
                  {
                    await acceptFriendRequest(this.requestsUsers[index].username?? "");
                  },
                  child: CircleAvatar
                  (
                    backgroundColor: Color(0xffb2b8016),
                    child: Icon(Icons.check, size: _height*4.5/100, color: Colors.white,),
                    radius: _height*3.2/100,
                  ),
                ),
                SizedBox
                (
                  width: _width*2/100,
                ),
                InkWell
                (
                  onTap: () async
                  {
                    await rejectFriendRequest(this.requestsUsers[index].username?? "");
                  },
                  child :Icon
                  (
                    Icons.cancel, 
                    size: _height*7.3/100, 
                    color: Colors.red,
                  ),
                
                )
              ]
            )
          ],
        ),
      ),
    );
  }

  void setSearchedUsersDataAndNotify(String searchedUsername) async
  {
    this.searchedUsers= await widget.client.getSearchedUsers(searchedUsername);
    if(textController.text.length!=0 && mounted)
    {
      setState(()=>
      {
        this.showSearchedResults=true,
        this.searchLoading=false
      });
    }
  }

  Widget showSearchedUsers(double _width, double _height, String searchedUsername) 
  {
    if(this.searchLoading)
    {
      setSearchedUsersDataAndNotify(searchedUsername);
      return Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: 
        [
          SizedBox
          (
            child: CircularProgressIndicator(color: Colors.grey, ),
            height: _width*20/100,
            width:  _width*20/100,
          )
        ],
      );
    }

    return ListView.builder
    (
      itemCount: (searchedUsers!=null) ? searchedUsers!.length : 0,
      itemBuilder: (context, index) => 
      InkWell
      (
        onTap: () 
        {
          if(widget.client.getCurrentUser().username==searchedUsers![index]?.username)
          {
            if(mounted)
              widget.notifyParentGoToProfile();
          }
          else
          {
            Navigator.of(context).push
            (
              MaterialPageRoute
              (
                builder: (context)=>ProfileScreen(widget.client, contraryUser: searchedUsers![index],)
              ),
            );
          }
        },
        child: Padding
        (
          padding: EdgeInsets.symmetric(horizontal: _width*5/100, vertical: _height*2/100),
          child: Row
          (
            children: 
            [
              CircleAvatar
              (
                backgroundImage: searchedUsers![index]?.profilePicturePath != null ?
                  Image.file(File(searchedUsers![index]?.profilePicturePath?? ""), key: UniqueKey()).image :
                  AssetImage("assets/images/profilePhoto.png"),
                
                radius: _height*4.5/100,
              ),
              Expanded
              (
                child: Padding
                (
                  padding: EdgeInsets.symmetric(horizontal: _width*3.5/100),
                  child: Column
                  (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                    [
                      Text
                      (
                        searchedUsers![index]?.username?? "",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      SizedBox
                      (
                        height: _height*0.3/100,
                      ),
                      Text
                      (
                        searchedUsers![index]?.name?? (searchedUsers![index]?.username?? ""),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          Container
          (
            color: Color(0xffb2b8016),
            child: Padding
            (
              padding: EdgeInsets.symmetric(vertical: _height*2.2/100),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: 
                [
                  Container
                  (
                    width: _width*93/100,
                    child: Card
                    (
                      child: TextFormField
                      (
                        onChanged: (text)
                        {
                          if(text.length>0)
                          {
                            setState(()=>this.searchLoading=true);
                          }
                          else
                          {
                            setState(()=>
                            {
                              this.searchLoading=false,
                              this.showSearchedResults=false
                            });
                          }
                        },
                        controller: textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 1,
                        decoration: InputDecoration
                        (
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Search user by username...",
                        ), 
                      )
                    )
                  )
                ],
              ),
            ),
          ),
          Expanded
          (
            child: (searchLoading!=true && showSearchedResults!=true) ?  
              showUserFriendRequests(_width, _height) :
              showSearchedUsers(_width, _height, textController.text),
          )
        ],
      )
    );
  }
}