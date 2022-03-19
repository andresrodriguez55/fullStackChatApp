import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/Components/NameField.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/Components/ProfilePictureField.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/Components/SendFriendRequestOrDeleteFriend.dart';
import 'package:chatapp/screens/MainScreen/Components/ProfileScreen/Components/UsernameField.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget
{
  late Client client;
  User? contraryUser;
  ProfileScreen(this.client, {this.contraryUser, Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return Material
    (
      child: Scaffold(
        body: Container
        (
          color: Color(0XFFB142238),
          child: Padding
          (
            padding: EdgeInsets.symmetric(horizontal: _width*12/100, vertical: _height*13/100),
            child: ListView
            (
              children:
              [ 
                Column
                (
                  children: 
                  [ 
                    ProfilePictureField(client: this.client, contraryUser: this.contraryUser),

                    NameField(client: this.client, contraryUser: this.contraryUser),

                    Opacity
                    (
                      opacity: 0.2,
                      child: Padding
                      (
                        padding: EdgeInsets.only(top: _height*0.6/100),
                        child: const Divider
                        (
                          color: Colors.grey,
                          height: 10,
                          thickness: 1,
                          endIndent: 0,
                          indent: 0,
                        ),
                      ),
                    ),

                    UsernameField(this.contraryUser==null ? this.client.getCurrentUser().username?? "" : this.contraryUser?.username?? ""),
                    
                    if(this.contraryUser!=null)
                      SendFriendRequestOrDeleteFriend(this.client, this.contraryUser!),
                  ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}