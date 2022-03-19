import 'package:chatapp/models/Backend/REST_API.dart';
import 'package:chatapp/models/Backend/SocketTransporter.dart';

class Backend
{
  late REST_API rest_api;
  late SocketTransporter socketTransporter; //used for real time operations

  Backend()
  {
    this.rest_api = new REST_API();
    this.socketTransporter = new SocketTransporter();
  }
}