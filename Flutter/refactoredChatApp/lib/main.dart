import 'package:chatapp/models/Client.dart';
import 'package:chatapp/models/Memory/Message.dart';
import 'package:chatapp/models/User/User.dart';
import 'package:chatapp/screens/MainScreen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Screens/StartScreen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MessageAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: 'Stay in Communication!',
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}