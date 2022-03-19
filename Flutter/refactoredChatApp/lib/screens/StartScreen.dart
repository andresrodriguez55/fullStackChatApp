import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/MainScreen/MainScreen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget
{
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
{
  late Client client;

  late String usernameWritten;
  late String passwordWritten;
  late bool signInLoading;

  @override
  void initState() 
  {
    client=Client();

    usernameWritten = '';
    passwordWritten = '';
    signInLoading = false;
    
    super.initState();
  }

  void login(String username, String password) async
  {
    setState(() => signInLoading=true);
    bool wasSessionOpened=await client.hasTheSessionBeenStartedSuccessfully(username, password);
    setState(() => signInLoading=false);
    
    if(wasSessionOpened)
    {
      Navigator.of(context).pushAndRemoveUntil
      (
        MaterialPageRoute
        (
          builder: (context)=>MainScreen(client)
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
                      usernameWritten=value;
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
                      passwordWritten=value;
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
                    login(this.usernameWritten, this.passwordWritten);
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