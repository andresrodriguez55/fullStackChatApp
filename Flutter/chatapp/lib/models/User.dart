import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/models/Conversation.dart';
import 'package:chatapp/models/Message.dart';
import 'package:chatapp/models/SocketController.dart';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import '../ServerData.dart';


import 'package:flutter/widgets.dart';

class User
{
  String? Username;
  String? Password;
  String? Email;
  String? Name;
  Uint8List? UserPicture;
  String? UserPicturePath;
  List<User>? Requests;
  List<User>? Friends;

  bool isTheUserTheCurrentUser=true;

  SocketController? notificationController=null; 

  final client = http.Client();
  final String serverURL=ServerData().SERVER_URL;
  final String serverIP=ServerData().SERVER_IP;

  User([this.Username, this.Password, this.Email, this.Name, this.UserPicture, 
    this.UserPicturePath, this.Requests, this.Friends]);

  User.usernameNameUserPictureConstructor(String? Username, String? Name, String? base64StringUserPicture)
  {
    this.Username = Username;
    this.Name = Name;
    if(base64StringUserPicture!=null)
    {
      this.UserPicture = base64Decode(base64.normalize(base64StringUserPicture));
      setStorageUserPicturePath();
    }
  }

  void setFromJson(Map parsedJson)  
  {
    this.Username=parsedJson['Username'];
    this.Password=parsedJson['Password'];
    this.Email= parsedJson['Email'];
    this.Name=parsedJson['Name'];
    this.UserPicture=(parsedJson['UserPicture']!=null)?base64Decode(base64.normalize(parsedJson['UserPicture'])):null;
    setStorageUserPicturePath();

    if(parsedJson['Requests']!=null)
    {
      this.Requests=<User>[];
      for (var request in parsedJson['Requests'])
      {
        this.Requests!.add(new User.usernameNameUserPictureConstructor(request["Username"], request["Name"], request["UserPicture"]));
      }
    }
    
    if(parsedJson['Friends']!=null)
    {
      this.Friends=<User>[];
      for (var request in parsedJson['Friends'])
      {
        this.Friends!.add(User.usernameNameUserPictureConstructor(request["Username"], request["Name"], request["UserPicture"]));
      }
    }
  }
        
  Map toJson() 
  {
    return 
    {
      "Username": this.Username,
      "Password": this.Password,
      "Email": this.Email,
      "Name": this.Name,
      "UserPicturePath" : this.UserPicturePath,
      "Requests" : this.Requests,
      "Friends" : this.Friends
    };
  }

  static User returnObjectFromJson(Map<String, dynamic> jsonData)
  {
    return User
    (
      jsonData["Username"],
      jsonData["Password"],
      jsonData["Email"],
      jsonData["Name"],
      null,
      jsonData["UserPicturePath"],
    );
  }

  Future setStorageUserPicturePath() async //solo actualizar cuando sea necesario, optimizar proximamente
  {
    if(this.UserPicture!=null)
    {
      final directory=await getApplicationDocumentsDirectory();

      File('${directory.path}/${this.Username}profilePhoto.png').delete(); //delete if exists
      File('${directory.path}/${this.Username}profilePhoto.png').writeAsBytes(UserPicture!); //save file

      SharedPreferences storage=await SharedPreferences.getInstance();
      storage.setString("imagepath${this.Username}", '${directory.path}/${this.Username}profilePhoto.png');
      this.UserPicturePath='${directory.path}/${this.Username}profilePhoto.png';
    }
  }

  ImageProvider<Object> getUserPictureWidget()
  {
    return (this.UserPicturePath!=null) ? 
      Image.file(File(this.UserPicturePath!), key: UniqueKey()).image : 
      AssetImage("assets/images/profilePhoto.png");
  }

  void initiateConversationsMemory() async
  {
    SharedPreferences storage = await SharedPreferences.getInstance();

    if(!storage.containsKey("conversations${this.Username}"))
    {
      List<Conversation> conversations=<Conversation>[];

      String conversationsEncoded = jsonEncode
      ( 
        conversations.map( (conversation) => 
          conversation.toJson()).toList() 
      );

      await storage.setString("conversations${this.Username}", conversationsEncoded);
    }
  }

  Future<List<Conversation>> getConversations() async
  {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String jsonEncodedMap = storage.get("conversations${this.Username}");
 
    Iterable decoded = jsonDecode(jsonEncodedMap);
    List<Conversation> conversations = List<Conversation>.from
    (
      decoded.map((conversation)=>
        Conversation.returnObjectFromJson(conversation) 
      )
    );

    return conversations;
  }

  Future<Conversation> getConversation(User contraryUser, 
    {List<Conversation>? conversationsData, bool deleteFromConversations=false}) async
  {
    List<Conversation> conversations = conversationsData==null ? await this.getConversations() : conversationsData;
    final n = conversations.length;

    for(var index=0; index<n; index++)
    {
      if(conversations[index].user.Username == contraryUser.Username)
      { 
        Conversation result = conversations[index];
        if(deleteFromConversations)
        {
          conversations.removeAt(index);
        } 
        return result;
      }
    }

    return Conversation(contraryUser, <Message>[]);
  }

  void saveNewMessageToMemory(Message newMessage, User contraryUser) async
  {
    debugPrint("new message ${newMessage.indetifierNumber}");

    List<Conversation> conversations = await getConversations();

    Conversation conversation = await getConversation(contraryUser, 
      conversationsData: conversations, deleteFromConversations: true);

    conversation.messagesStack.insert(0, newMessage);
    conversations.insert(0, conversation);  //Add to top

    SharedPreferences storage = await SharedPreferences.getInstance();
    String conversationsEncoded = jsonEncode
    ( 
      conversations.map( (conversation) => 
        conversation.toJson()).toList() 
    );

    //String conversationsEncoded = jsonEncode(conversations);
    await storage.setString("conversations${this.Username}", conversationsEncoded);
  }

  void changeMessageStatusAtMemory(String contraryUsername, int? identifierNumber, String status) async
  {
    List<Conversation> conversations = await getConversations();
    Conversation conversation = await getConversation(User(contraryUsername), 
      conversationsData: conversations, deleteFromConversations: false);
    
    for(var message in conversation.messagesStack)
    {
      debugPrint("${message.indetifierNumber?? -1}");
      if(message.indetifierNumber==identifierNumber)
      {
        if(status=="server")
          message.doesMessageReachedServer=true;

        else
          message.doesMessageReachedReceiver=true;
      
        debugPrint(message.content);
        break;
      }
    }

    SharedPreferences storage = await SharedPreferences.getInstance();
    String conversationsEncoded = jsonEncode
    ( 
      conversations.map( (conversation) => 
        conversation.toJson()).toList() 
    );

    await storage.setString("conversations${this.Username}", conversationsEncoded);
  }

  void sendMessageSocket(String? toUsername, Message message)
  {
    this.notificationController?.sendMessageToUser(toUsername, message);
  }

  //Set all information and services for current user
  Future<bool> setUserData(String? username, String? password) async
  {
    var response = await client.get(Uri.parse("$serverURL/getUser/$username/$password"), ); //define timeout
    if(response.statusCode==200)
    {
      var jsonData=jsonDecode(response.body);
      if(jsonData["Username"]!=null)
      {
        setFromJson(jsonData);
        notificationController = SocketController(this);
        notificationController!.initWebSocketConnection();
        await this.setStorageUserPicturePath();

        return true;
      }
    }

    return false;
  }

  Future<bool> updateUserData() async //solo actualizar cuando sea necesario, optimizar proximamente
  {
    bool result = await setUserData(this.Username, this.Password);
    return result;
  }

  Future<bool> updateName(String? newName) async //MOSTRAR ERRORES
  {
    final url=Uri.parse("$serverURL/updateName/${this.Username}/${this.Password}/${newName}");
    final response=await client.put(url);
    if(response.statusCode==200)
    {
      this.Name=newName;
      return true;
    }
    return false;
  }

  Future<bool> updateUserPicture(File? newUserPicture) async //MOSTRAR ERRORES
  {
    final url=Uri.parse("$serverURL/postUserPicture/${this.Username}/${this.Password}");
    var request = new http.MultipartRequest("POST", url);

    if(newUserPicture!=null)
    {
      var stream = new http.ByteStream(DelegatingStream.typed(newUserPicture.openRead()));
      var length = await newUserPicture.length();
      var multipartFile = new http.MultipartFile('UserPicture', stream, length,filename: "UserPicture");
      request.files.add(multipartFile);
    }

    request.send().
    then((response) 
    {
      if (response.statusCode == 200)
      { 
        return true;
      }
    });
    return false;
  }

  Future<List<User>> searchUsers(String searched) async
  {
    final url=Uri.parse("$serverURL/getUsersWhichContainString/${searched}");
    final response=await client.get(url);
    if(response.statusCode==200)
    {
      List<User> result=<User>[];

      List<dynamic> jsonList = json.decode(response.body);
      for(var jsonUser in jsonList)
      {
        User user = User();
        user.setFromJson(jsonUser);
        result.add(user);
      }
      
      return result;
    }

    return <User>[];
  }

  Future<bool> postFriendRequest(String? receiverUsername) async //MOSTRAR ERRORES
  {
    final url=Uri.parse("$serverURL/postFriendRequest/${this.Username}/${this.Password}/${receiverUsername}");
    var response = await client.post(url);

    if(response.statusCode==200)
      return true;

    return false;
  }

  Future<bool> rejectFriendRequest(String? rejectedUsername) async //MOSTRAR ERRORES
  {
    this.Requests!.removeWhere((user) => user.Username==rejectedUsername); //cancel delay

    final url=Uri.parse("$serverURL/rejectFriendRequest/${this.Username}/${this.Password}/${rejectedUsername}");
    var response = await client.post(url);

    if(response.statusCode==200) 
      return true;

    return false;
  }

  Future<bool> acceptFriendRequest(String? acceptUsername) async //MOSTRAR ERRORES
  {
    User newFriend=this.Requests!.where((user) => user.Username==acceptUsername).toList()[0];
    this.Friends!.add(newFriend); //cancel delay
    this.Requests!.removeWhere((user) => user.Username==acceptUsername); //cancel delay

    final url=Uri.parse("$serverURL/acceptFriendRequest/${this.Username}/${this.Password}/${acceptUsername}");
    var response = await client.post(url);

    if(response.statusCode==200) 
      return true;
      
    return false;
  }

  Future<bool> deleteFriend(String? deleteUsername) async //MOSTRAR ERRORES
  {
    this.Friends!.removeWhere((user) => user.Username==deleteUsername); //cancel delay

    final url=Uri.parse("$serverURL/deleteFriend/${this.Username}/${this.Password}/${deleteUsername}");
    var response = await client.post(url);

    if(response.statusCode==200) 
      return true;
      
    return false;
  }
}