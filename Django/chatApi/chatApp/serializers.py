from django.dispatch import receiver
from numpy import True_, source
from rest_framework import serializers
from chatApp.models import *

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields=('IdentifierNumber', 'Content', 'Type', 'Receiver', 'Sender', 'Date')

class SearchedUserSerializer(serializers.ModelSerializer):
    class Meta:
        model=User
        fields=('Username', 'Name', 'ProfilePicture')

class UserSerializer(serializers.ModelSerializer):
    Requests = SearchedUserSerializer(source = "getRequestsUsers", many=True)
    Friends = SearchedUserSerializer(source = "getFriendsUsers", many=True)
    Messages = MessageSerializer(source = "getMessages", many=True)

    class Meta:
        model=User
        fields=('Username', 'Password', 'Email', 'Name', 'ProfilePicture', 'Requests', 'Friends', 'Messages')

class FriendshipSerializer(serializers.ModelSerializer):
    class Meta:
        model=Friendship
        fields=('Person1', 'Person2')