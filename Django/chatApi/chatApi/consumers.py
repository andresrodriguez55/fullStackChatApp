from email.headerregistry import Group
from channels.generic.websocket import WebsocketConsumer
from asgiref.sync import async_to_sync
from django.http import JsonResponse
from chatApp.models import *
import json 
from django.utils import timezone
from datetime import datetime

class ChatConsumer(WebsocketConsumer):

    #connection of socket
    def connect(self):  
        headerDictionary = dict(self.scope['headers'])
        headerDictionary = { key.decode(): val.decode() for key, val in headerDictionary.items() }
        
        username = headerDictionary.get('username')
        password = headerDictionary.get('password')

        doesUserExists = User.objects.filter(Username=username, Password=password).exists()
        
        if(doesUserExists): #prepare a communiacation channel for user
            self.accept()
            self.send(text_data=json.dumps({"type" : "connection established!", "message" : "You are now connected!"}))
            
            self.group_name = username
            async_to_sync(self.channel_layer.group_add)(self.group_name, self.channel_name)
            
        else:
            self.close()


    #disconnection of socket
    def disconnect(self, code):
        if hasattr(self, 'group_name'): #delete comunication channel if exists
            async_to_sync(self.channel_layer.group_discard)(self.group_name, self.channel_name)

    #notify client
    def sendMessageToClient(self, event):
        print("sending socket to online user..")
        self.send(json.dumps(event["message"]))

    #this function receives messages of users
    def receive(self, text_data=None, bytes_data=None):
        currentUsername = self.group_name #channel names are equal to users names

        jsonData = json.loads(text_data)
        messageIdentifierNumber = jsonData["identifierNumber"]
        messageContent = jsonData["content"]
        messageType = jsonData["type"]
        messageReceiver = jsonData["receiver"]

        onlineUsers = self.channel_layer.__dict__.get('groups')
        if messageReceiver in onlineUsers:
            jsonMessage = {
                "responseType" : "message",
                "content" : messageContent,
                "type" : messageType,
                "dateTime" : timezone.now().strftime("%Y-%m-%d %H:%M:%S"), #server time EUROPE - LONDON
                "contraryUsername" : currentUsername
            }
            async_to_sync(self.channel_layer.group_send)(messageReceiver, {
                'type': 'sendMessageToClient',
                'message': jsonMessage,
            })

            notificationThatTheUserReceivedTheMessage = {
                "responseType" : "messageStatus",
                "username" : messageReceiver, 
                "identifierNumber" : messageIdentifierNumber, 
                "status" : "client"
            }
            async_to_sync(self.channel_layer.group_send)(self.group_name, {
                'type': 'sendMessageToClient',
                'message': notificationThatTheUserReceivedTheMessage,
            })

        else:
            senderUser = User.objects.get(Username = currentUsername)
            receiverUser = User.objects.get(Username = messageReceiver)

            #store message in database
            message = Message.objects.create(
                Content = messageContent, 
                Type = messageType,
                Date = timezone.now(),
                Sender=senderUser, 
                Receiver=receiverUser,   
                IdentifierNumber = messageIdentifierNumber      
            )
            receiverUser.Messages.add(message)
            receiverUser.save()

            self.send(text_data=json.dumps({
                "responseType" : "messageStatus",
                "username" : messageReceiver, 
                "identifierNumber" : messageIdentifierNumber,
                "status" : "server"
            }))