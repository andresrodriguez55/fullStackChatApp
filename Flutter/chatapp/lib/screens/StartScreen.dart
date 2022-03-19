import 'package:chatapp/models/User.dart';
import 'package:chatapp/screens/MainScreen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget
{
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
{
  String Username='';
  String? Password='';
  bool signInLoading = false;

  User user=User();

  void getUserData(String username, String? password) async
  {
    if(mounted)
      setState(() => signInLoading=true);
    bool wasSessionOpened=await user.setUserData(username, password);
    if(mounted)
      setState(() => signInLoading=false);
    
    if(wasSessionOpened)
    {
      Navigator.of(context).pushAndRemoveUntil
      (
        MaterialPageRoute
        (
          builder: (context)=>MainScreen(user: user)
        ),
        (route)=>false
      );      
    }
    else
      debugPrint("Error to open session...");
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return Scaffold
    (
      resizeToAvoidBottomInset: false,
      body: Container
      (
        color: Color(0XFFB142238),

        child: Padding
        (
          padding: EdgeInsets.symmetric(horizontal: _width*10/100),
          child: Column
          (
            children: 
            [
              SizedBox(height: 100,),

              Container
              (
                child: Image.asset
                (
                  "assets/images/logo.png",
                  height: _height*25/100,
                  width: _width,
                ),
              ),

              Container
              (
                margin: EdgeInsets.only(top: _height*3/100),

                child: TextField
                (
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                  onChanged: (value)
                  {
                    setState(() 
                    {
                      Username=value;
                    });
                  },
                  decoration: InputDecoration
                  (
                    hintStyle: TextStyle(fontSize: 16.0, color: Colors.white60),
                    hintText: "Username"
                  ),
                ),
              ),

              Container
              (
                margin: EdgeInsets.only(top: _height*2/100,),

                child: TextField
                (
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                  onChanged: (value)
                  {
                    setState(() 
                    {
                      Password=value;
                    });
                  },
                  decoration: InputDecoration
                  (
                    hintStyle: TextStyle(fontSize: 16.0, color: Colors.white60),
                    hintText: "Password"
                  ),
                ),
              ),

              Container
              (
                margin: EdgeInsets.only(top: _height*5/100),

                width: double.infinity, //MediaQuery.of(context).size.width
                height: _height*7/100,

                decoration: BoxDecoration
                (
                  borderRadius: BorderRadius.circular(1.00),
                ),

                child: ElevatedButton
                (
                  style: ElevatedButton.styleFrom
                  (
                    primary: Color(0xffb2b8016),
                  ),
                  onPressed: ()
                  {
                    getUserData(this.Username, this.Password);
                  },
                  child: signInLoading ? CircularProgressIndicator(color: Colors.white,) : const Text("Sign In", style: TextStyle(fontSize: 20),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
Container
              (
                padding: EdgeInsets.only(left: _width*5/100, right: _width*5/100),
                width: double.infinity, //MediaQuery.of(context).size.width
                height: _height*7/100,
                
                decoration: BoxDecoration
                (
                  borderRadius: BorderRadius.circular(1.00),
                ),
                child: ElevatedButton
                (
                  style: ElevatedButton.styleFrom
                  (
                    primary: Color(0xffbc2bd2b),
                  ),
                  onPressed: (){},
                  child: const Text("Sign Up"),
                ),
              )
 */