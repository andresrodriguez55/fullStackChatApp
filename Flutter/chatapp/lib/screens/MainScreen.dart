import 'package:chatapp/models/User.dart';
import 'package:chatapp/screens/MainScreens/ChatsScreen.dart';
import 'package:chatapp/screens/MainScreens/PetitionsScreen.dart';
import 'package:chatapp/screens/MainScreens/PetitionsScreensComponents/SearchFriendsToChatScreen.dart';
import 'package:flutter/material.dart';
import 'MainScreens/ProfileScreen.dart';

class MainScreen extends StatefulWidget
{
  User user;

  MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState()=>_MainScreenState();
}

class _MainScreenState extends State<MainScreen>
{
  void initState() 
  {
    widget.user.initiateConversationsMemory();
    super.initState();
  }

  int _selectedIndex = 0;

  AppBar? getAppBarIfIsNecessary()
  {
    if(_selectedIndex==0)
    {
      return AppBar
      (
        backgroundColor: Color(0xffb2b8016),
        automaticallyImplyLeading: false,
        title: Text("Chats"),
      );
    }

    return null;
  }

  Widget? getFloatingButtonIfIsNecessary()
  {
    if(_selectedIndex==0)
    {
      return FloatingActionButton
      (
        onPressed: ()
        {
          Navigator.of(context).push
          (
            MaterialPageRoute
            (
              builder: (context)=>SearchFriendsToChatScreen(user: widget.user)
            )
          );
        },
        backgroundColor: Color(0xffb2b8016),
        child: Icon(Icons.chat),
      );
    }

    return null;
  }

  void goToProfileScreen()
  {
    setState(() => _selectedIndex=1 );
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    List screens=
    [
      ChatsScreen(user: widget.user), 
      ProfileScreen(currentUser: widget.user), 
      PetitionsScreen(user: widget.user, notifyParentGoToProfile: goToProfileScreen,)
    ];

    return MaterialApp
    (
      home: Scaffold
      (
        resizeToAvoidBottomInset: false,
        
        appBar: getAppBarIfIsNecessary(),
    
        body: screens[_selectedIndex], 
    
        floatingActionButton: getFloatingButtonIfIsNecessary(),
    
        bottomNavigationBar: BottomNavigationBar
        (
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xffb2b8016),
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          type: BottomNavigationBarType.fixed,
          items: 
          [
            BottomNavigationBarItem
            (
              icon: Icon(Icons.chat_bubble),
              label: "Chats",
            ),
            BottomNavigationBarItem
            (
              icon: Icon(Icons.person,),
              label: "Profile",
            ),
            BottomNavigationBarItem
            (
              icon: Icon(Icons.person_add_alt_1),
              label: "Petitions",
            ),
          ],
    
          currentIndex: _selectedIndex,
          onTap: (index)
          {
            setState(()
            {
              _selectedIndex=index;
            });
          },
        ),
      ),
    ); 
  }
}