import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget
{
  String Username;
  UsernameField(this.Username, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    return Container
    (
      margin: EdgeInsets.only(top: _height*0.6/100),
      child: Row
      (
        children: 
        [
          Icon(Icons.message_sharp, color: Colors.grey, size: _width*7/100,),
          Expanded
          (
            child: Padding
            (
              padding: EdgeInsets.only(left: _width*5/100, bottom: _height*1/100),
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text("Username", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: _height*1/100),
                  Text(this.Username, style: TextStyle(fontSize: 18, color: Colors.white)),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}