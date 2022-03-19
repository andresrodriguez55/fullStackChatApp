from django.dispatch import receiver
from djongo import models
from django.utils import timezone

from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response

class User(models.Model):
    Username=models.CharField(primary_key=True, max_length=30)
    Password = models.CharField(max_length=30, null=False)
    Email=models.CharField(max_length=80, null=False)
    Name = models.CharField(max_length=25, null=True)
    ProfilePicture=models.TextField(null=True)

    Requests = models.ManyToManyField("self", through="RequestFriendship", symmetrical= False, related_name="RequestToUser") #cambiar a foreign key
    Friends = models.ManyToManyField("self", through="Friendship", symmetrical = True, related_name="FriendUser") 
    Messages = models.ManyToManyField("Message", symmetrical = False, related_name = "MessageUser") #cambiar a foreign key

    def getRequestsUsers(self):
        return self.Requests.all()
        
    def getFriendsUsers(self):
        return self.Friends.all()

    def getMessages(self):
        return self.Messages.all()

class RequestFriendship(models.Model):
    ID = models.AutoField(primary_key=True) #This is an auto-incrementing primary key.
    Receiver = models.ForeignKey("User", on_delete = models.CASCADE, null=False, related_name="toRequestUser")
    Sender = models.ForeignKey("User", on_delete = models.CASCADE, null=False, related_name="ofRequestUser")

    class Meta:
        unique_together = (("Receiver", "Sender"),)

class Friendship(models.Model):
    ID = models.AutoField(primary_key=True) #This is an auto-incrementing primary key.
    Person1 = models.ForeignKey("User", on_delete = models.CASCADE, null=False, related_name="ofFriendUser")
    Person2 = models.ForeignKey("User", on_delete = models.CASCADE, null=False, related_name="toFriendUser")


class Message(models.Model): # many-to-many intermediate table
    ID = models.AutoField(primary_key=True) #This is an auto-incrementing primary key.
    Sender = models.OneToOneField(User, on_delete = models.CASCADE, null=False, related_name="ofMessageUser")
    Receiver = models.OneToOneField(User, on_delete = models.CASCADE, null=False, related_name="toMessageUser")
    IdentifierNumber = models.IntegerField() #unique for all user
    Content=models.CharField(null=False, max_length=4096,) #Like Telegram limit
    CONTENT_TYPE_CHOICES = ( 
        ("Text", "Text"), 
        ("Image", "Image"), 
        ("Audio", "Audio"), 
        ("Video", "Video") 
    )
    Type = models.CharField(null=False, choices=CONTENT_TYPE_CHOICES, max_length=5, default="Text")
    Date = models.DateTimeField(null=False, default=timezone.now()) #default server timezone -> Europe/London
    
"""
class MessageDelivery(models.Model):
    ID = models.ForeignKey("Message", primary_key=True, on_delete = models.CASCADE)
    Sender = models.ForeignKey(User, on_delete = models.CASCADE, null=False, related_name="ofMessageUser")
    Receiver = models.ForeignKey(User, on_delete = models.CASCADE, null=False, related_name="toMessageUser")

    
class Group(models.Model):
    ID = models.AutoField(primary_key=True) #This is an auto-incrementing primary key.
    CreateDate = models.DateField()
    GrupPicture=models.ImageField()

    #messages
    #adminUser
    #users
"""