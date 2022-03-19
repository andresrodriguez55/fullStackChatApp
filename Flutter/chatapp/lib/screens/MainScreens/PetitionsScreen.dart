import 'package:chatapp/models/User.dart';
import 'package:flutter/material.dart';
import 'ProfileScreen.dart';

class PetitionsScreen extends StatefulWidget
{
  User user;
  final Function() notifyParentGoToProfile;

  PetitionsScreen({Key? key, required this.user, required this.notifyParentGoToProfile}) : super(key: key);

  @override
  _PetitionsScreen createState() => _PetitionsScreen();
}

class _PetitionsScreen extends State<PetitionsScreen>
{
  final textController = TextEditingController();
  bool searchLoading=false;
  bool showSearchedResults=false;
  List<User>? searchedUsers;

  void refresh()
  {
    setState((){});
  }

  void acceptFriendRequest(String? acceptUsername) 
  {
    widget.user.acceptFriendRequest(acceptUsername); 
    refresh();
  }

  void rejectFriendRequest(String? rejectUsername) 
  {
    widget.user.rejectFriendRequest(rejectUsername);
    refresh();
  }

  ListView showUserFriendRequests(double _width, double _height)
  {
    return ListView.builder
    (
      itemCount: (widget.user.Requests!=null) ? widget.user.Requests!.length : 0,
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
              backgroundImage: widget.user.Requests![index].getUserPictureWidget(),
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
                      widget.user.Requests![index].Username?? "",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    SizedBox
                    (
                      height: _height*0.3/100,
                    ),
                    Text
                    (
                      widget.user.Requests![index].Name?? (widget.user.Requests![index].Username?? ""),
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
                  onTap: ()
                  {
                    acceptFriendRequest(widget.user.Requests![index].Username);
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
                  onTap: () 
                  {
                    rejectFriendRequest(widget.user.Requests![index].Username);
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
    this.searchedUsers= await widget.user.searchUsers(searchedUsername);
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
          if(widget.user.Username==searchedUsers![index].Username)
          {
            if(mounted)
              widget.notifyParentGoToProfile();
          }
          else
          {
            searchedUsers![index].isTheUserTheCurrentUser=false;
            Navigator.of(context).push
            (
              MaterialPageRoute
              (
                builder: (context)=>ProfileScreen(currentUser: searchedUsers![index], ownerUser: widget.user)
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
                backgroundImage: searchedUsers![index].getUserPictureWidget(),
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
                        searchedUsers![index].Username?? "",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      SizedBox
                      (
                        height: _height*0.3/100,
                      ),
                      Text
                      (
                        searchedUsers![index].Name?? (searchedUsers![index].Username?? ""),
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