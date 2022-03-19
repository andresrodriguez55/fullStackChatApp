import 'dart:io';
import 'package:chatapp/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../ServerData.dart';

class ProfileScreen extends StatelessWidget
{
  User currentUser;
  User? ownerUser;
  ProfileScreen({Key? key, required this.currentUser, this.ownerUser}) : super(key: key);

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
                    ImageProfile(user: this.currentUser),
                    NameField(user: this.currentUser),
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
                    UsernameField(Username: this.currentUser.Username,),
                    
                    if(ownerUser!=null)
                      SendFriendRequestOrDeleteFriend(senderUser: ownerUser, receiverUser: currentUser),
                  ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}



class ImageProfile extends StatefulWidget
{
  User user;
  ImageProfile({required this.user, Key? key}) : super(key: key);

  @override
  _ImageProfile createState()=>_ImageProfile();
}

class _ImageProfile extends State<ImageProfile>
{
  @override
  void initState()
  {
    super.initState();
  }

  void refreshProfilePicture()
  {
    imageCache?.clear();
    setState(()=>{
      imageCache?.clear(),
      imageCache?.clearLiveImages(),
     
    });
  }

  Future pickImage(ImageSource source) async
  {
    try
    {
      final image=await ImagePicker().pickImage(source: source);
      if(image==null)
        return;
      
      final croppedImage = await ImageCropper().cropImage
      (
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
        compressFormat: ImageCompressFormat.png,
        androidUiSettings: AndroidUiSettings
        (
            toolbarTitle: 'Crop your image',
            toolbarColor: Color(0xffb2b8016),
        ),
        iosUiSettings: IOSUiSettings
        (
          title: 'Crop your image',
        )
      );
      if(croppedImage==null)
        return;

      await saveImage(croppedImage);
    }
    on PlatformException catch(e)
    {
    }
  }

  Future saveImage(File? newImage) async
  {
    SharedPreferences storage=await SharedPreferences.getInstance();
    final directory=await getApplicationDocumentsDirectory();
    final route = '${directory.path}/${widget.user.Username}UserPicture.png';

    bool doesFileExists = await File(route).exists();
    if(doesFileExists)
    {
      await File(route).delete(); //delete if exists
      refreshProfilePicture();
    }

    if(newImage!=null)
    {
      await File(newImage.path).copy('${directory.path}/${widget.user.Username}UserPicture.png');
      await storage.setString("imagepath${widget.user.Username}", route);
      widget.user.UserPicturePath = route;
    }

    else
    {
      await storage.remove("imagepath${widget.user.Username}");
      widget.user.UserPicturePath=null;
    }
    
    await widget.user.updateUserPicture(newImage);

    refreshProfilePicture();
    debugPrint("aaa");
  }

  Future resetProfileImage() async  
  {
    await saveImage(null);
  }

  @override
  Widget build(BuildContext context) 
  {
    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;
    
    return Center
    (
      child: Stack
      (
        children: 
        [
          CircleAvatar
          (
            key: UniqueKey(),
            radius: _width*27/100,
            foregroundImage: (widget.user.UserPicturePath!=null) ?
              Image.file(File(widget.user.UserPicturePath!) ,).image :
              AssetImage("assets/images/profilePhoto.png"),
          ),

          if(widget.user.isTheUserTheCurrentUser)
            Positioned
            (
              bottom: 0,
              right: 0,
              child: InkWell
              (
                onTap: () => showModalBottomSheet
                (
                  backgroundColor: Color(0XFFB1e2f4a),
                  context: context,
                  builder: (BuildContext context) => Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: _height*3/100, horizontal: _width*10/100),
                    child: Column
                    (
                      mainAxisSize: MainAxisSize.min,
                      children: 
                      [
                        Row
                        (
                          children: 
                          [
                            Text("Profile picture", style: TextStyle(fontSize: 22, color: Colors.white),),
                            Expanded
                            (
                              child: Container
                              (
                                alignment: Alignment.bottomRight,
                                child: InkWell
                                (
                                  onTap: ()=>{resetProfileImage(), Navigator.pop(context)},
                                  child: Icon
                                  (
                                    Icons.delete, 
                                    size:  _width*7/100, 
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding
                        (
                          padding: EdgeInsets.only(top: _height*3/100),
                          child: Row
                          (
                            children: 
                            [
                              Column
                              (
                                children: 
                                [
                                  InkWell
                                  (
                                    onTap: ()=>{pickImage(ImageSource.camera), Navigator.pop(context)},
                                    child: CircleAvatar(child: Icon(Icons.camera, size: _width*7/100,), radius: _width*6/100,)
                                  ),
                                  SizedBox(height: _height*1.5/100,),
                                  Text("Camera", style: TextStyle(fontSize: 15, color: Colors.grey))
                                ],
                              ),
                              SizedBox(width: _width*7/100,),
                              Column
                              (
                                children: 
                                [
                                  InkWell
                                  (
                                    onTap: ()=>{pickImage(ImageSource.gallery), Navigator.pop(context)},
                                    child: CircleAvatar(child: Icon(Icons.photo, size: _width*7/100), radius: _width*6/100,)
                                  ),
                                  SizedBox(height: _height*1.5/100,),
                                  Text("Galery", style: TextStyle(fontSize: 15, color: Colors.grey))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
                child: Icon
                (
                  Icons.camera_alt,
                  color: Color(0xffb2b8016),
                  size: _width*12/100,
                ),
              ),
            )
        ],
      ),
    );
  }
}


class SendFriendRequestOrDeleteFriend extends StatefulWidget
{
  User? senderUser;
  User receiverUser;
  SendFriendRequestOrDeleteFriend({required this.senderUser, required this.receiverUser, Key? key}) : super(key: key);

  @override
  _SendFriendRequestOrDeleteFriend createState()=>_SendFriendRequestOrDeleteFriend();
} 

class _SendFriendRequestOrDeleteFriend extends State<SendFriendRequestOrDeleteFriend>
{
  bool requestLoading=false;
  bool isFriendDeleted=false; //for optimization

  bool areTheyFriends()
  {
    for (var user in widget.senderUser!.Friends!) 
    {
      if(user.Username==widget.receiverUser.Username)
        return true;
    }

    return false;
  }

  void deleteFriend(BuildContext context) async
  {
    setState(()=>requestLoading=true);
    await widget.senderUser!.deleteFriend(widget.receiverUser.Username);
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
    await widget.senderUser!.postFriendRequest(widget.receiverUser.Username);
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


class NameField extends StatefulWidget
{
  User user;
  NameField({required this.user, Key? key}) : super(key: key);

  @override
  _NameFieldState createState()=>_NameFieldState();
}

class _NameFieldState extends State<NameField>
{
  String? name='';
  var client = http.Client();
  String serverURL=ServerData().SERVER_URL;

  void updateName(String newName) async //MOSTRAR ERRORES
  {
    bool result=await widget.user.updateName(newName);
    if(result)
    {
      setState(()=>name=newName);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    name=(widget.user.Name!=null)? widget.user.Name : ((widget.user.Username!=null)?widget.user.Username:'aaa');

    var _height=MediaQuery.of(context).size.height;
    var _width=MediaQuery.of(context).size.width;

    final TextEditingController nameController = TextEditingController(text: name);
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
                  Text(name!, style: TextStyle(fontSize: 18, color: Colors.white)),
                ]
              ),
            ),
            ),

            if(widget.user.isTheUserTheCurrentUser)
              Container(
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
                            Container(
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

class UsernameField extends StatelessWidget
{
  String? Username;
  UsernameField({Key? key, required String? this.Username}) : super(key: key);

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
                  Text(this.Username?? "", style: TextStyle(fontSize: 18, color: Colors.white)),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}