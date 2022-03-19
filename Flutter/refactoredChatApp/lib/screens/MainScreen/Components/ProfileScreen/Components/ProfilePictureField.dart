import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureField extends StatefulWidget
{
  late Client client;
  User? contraryUser;
  ProfilePictureField({required this.client, this.contraryUser, Key? key}) : super(key: key);

  @override
  _ProfilePictureField createState()=>_ProfilePictureField();
}

class _ProfilePictureField extends State<ProfilePictureField>
{
  bool isTheClientProfile = true;
  String? profilePicturePathDisplayed;

  @override
  void initState()
  {
    if(widget.contraryUser != null)
    {
      isTheClientProfile = false;

      if(widget.contraryUser?.profilePicturePath != null)
      {
        this.profilePicturePathDisplayed = widget.contraryUser?.profilePicturePath;
      }
    }
    
    else
    {
      if(widget.client.getCurrentUser().profilePicturePath != null)
      { 
        this.profilePicturePathDisplayed = widget.client.getCurrentUser().profilePicturePath;
        debugPrint(profilePicturePathDisplayed);
      }
    }

    super.initState();
  }

  void refreshProfilePicture()
  {
    setState(()=>
    {
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

      await widget.client.updateProfilePicture(croppedImage);
      this.profilePicturePathDisplayed = widget.client.getCurrentUser().profilePicturePath;
      refreshProfilePicture();
    }
    on PlatformException catch(e)
    {

    }
  }

  Future resetProfileImage() async  
  {
    await widget.client.updateProfilePicture(null);
    this.profilePicturePathDisplayed=null;
    refreshProfilePicture();
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
            foregroundImage: (this.profilePicturePathDisplayed!=null) ?
                                Image.file(File(this.profilePicturePathDisplayed!)).image :
                                AssetImage("assets/images/profilePhoto.png"),
          ),

          if(isTheClientProfile)
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