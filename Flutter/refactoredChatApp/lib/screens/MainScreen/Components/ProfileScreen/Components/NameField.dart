import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:flutter/material.dart';

class NameField extends StatefulWidget
{
  late Client client;
  User? contraryUser;
  NameField({required this.client, this.contraryUser, Key? key}) : super(key: key);

  @override
  _NameFieldState createState()=>_NameFieldState();
}

class _NameFieldState extends State<NameField>
{
  late String displayedName;

  @override
  void initState() 
  {
    if(widget.contraryUser != null)
      displayedName = widget.contraryUser?.name?? widget.contraryUser?.username?? "";
    else
      displayedName = widget.client.getCurrentUser().name?? widget.client.getCurrentUser().username?? "";

    super.initState();
  }

  void updateName(String newName) async //MOSTRAR ERRORES
  {
    bool result=await widget.client.updateName(newName);
    if(result)
    {
      setState(()=>displayedName = newName);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    final TextEditingController nameController = TextEditingController(text: displayedName);
    final formkey = GlobalKey<FormState>();

    return Container
    (
      margin: EdgeInsets.only(top: _height*5/100),
      child: Row
      (
        children: 
        [
          Icon(Icons.person, color: Colors.grey, size: _width*7/100,),
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
                  Text("Name", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: _height*1/100),
                  Text(displayedName, style: TextStyle(fontSize: 18, color: Colors.white)),
                ]
              ),
            ),
            ),

            if(widget.contraryUser==null)
              Container
              (
                child: InkWell
                (
                  child: Icon(Icons.edit, color: Color(0xffb2b8010), size: _width*7/100,),
                  onTap: ()=> showModalBottomSheet
                  (
                    backgroundColor: Color(0XFFB1e2f4a),
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) => Padding
                    (
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Padding
                      (
                        padding: EdgeInsets.symmetric(vertical: _height*3/100, horizontal: _width*10/100),
                        child: Column
                        (
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: 
                          [
                            Text("Change your name", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            Form
                            (
                              key: formkey,
                              child: Padding
                              (
                                padding:  EdgeInsets.only(top:_height*2/100),
                                child: TextFormField
                                (
                                  autofocus: true,
                                  maxLength: 25,
                                  controller: nameController,
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                  validator: (value)
                                  {
                                    if(value!.isEmpty)
                                      return "Name can't be empty";
                                    return null;
                                  },
                                  decoration: InputDecoration
                                  (
                                    fillColor: Colors.white,                        
                                    counterStyle:  TextStyle(color: Colors.white, fontSize: 15),
                                    errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                                  ), 
                                ),
                              ),
                            ),
                            Container
                            (
                              child: Padding
                              (
                                padding: EdgeInsets.only(top: _height*2/100),
                                child: Row
                                (
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: 
                                  [
                                    TextButton
                                    (
                                      onPressed: () => Navigator.pop(context), 
                                      child: Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.white60))
                                    ),
                                    TextButton
                                    (
                                      onPressed: ()
                                      {
                                        final form = formkey.currentState;
                                        if(form != null && form.validate())
                                        {  
                                          updateName(nameController.text);
                                          Navigator.pop(context);
                                        }
                                      }, 
                                      child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white60))
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  )
                ),
              )
        ],
      ),
    );
  }
}