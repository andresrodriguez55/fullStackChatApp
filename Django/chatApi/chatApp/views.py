import base64
import os
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http.response import JsonResponse
from django.core.exceptions import BadRequest

from chatApp.models import *
from chatApp.serializers import *

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

def lobby(request):
    return render(request, "loby.html")

def returnListWithRequiredUserInformation(returnDataDict, category):
    result=[]
    for username in returnDataDict.get(category):
        user=User.objects.get(Username=username)
        serializedUser=SearchedUserSerializer(user).data
        result.append(serializedUser)
        
    return result

@csrf_exempt
def getUser(request, Username=None, Password=None):
    if request.method=="GET":
        try:
            user=User.objects.get(Username=Username, Password=Password)
        except User.DoesNotExist:
            raise BadRequest("Invalid...")

        data = UserSerializer(user).data

        return JsonResponse(data, safe=False)

    else:
        return JsonResponse('Failed to get user data...', safe=False)

@csrf_exempt
def getUsersWhichContainString(request, Username):
    if request.method=="GET":
        try:
            users=User.objects.filter(Username__icontains=Username)
        except User.DoesNotExist:
            return JsonResponse({}, safe=False)

        returnData=[]
        for user in users:
            serializedUser=SearchedUserSerializer(user).data
            returnData.append(serializedUser)

        return JsonResponse(returnData, safe=False)

    else:
        return JsonResponse('Failed to get searched users data...', safe=False)

@csrf_exempt
def updateName(request, Username, Password, Name):
    if request.method=="PUT":
        userToUpdate=User.objects.filter(Username=Username, Password=Password).first()
        if userToUpdate is None:
            print("aaa")
            return JsonResponse('Failed to update name...', safe=False)

        userToUpdate.Name=Name
        userToUpdate.save()
        return JsonResponse('Name updated succesfully!', safe=False)

    else:
        return JsonResponse('Failed to update name...', safe=False)

@csrf_exempt
def postProfilePicture(request, Username, Password):
    if request.method=="POST":
        try:
            userToUpdate=User.objects.get(Username=Username, Password=Password)
        except User.DoesNotExist:
            return JsonResponse('Failed to post user picture...', safe=False)

        imageFile=request.FILES.get("ProfilePicture", None)
        if imageFile is not None:
            imageFile = base64.b64encode(imageFile.read()).decode('ascii')
        
        userToUpdate.ProfilePicture=imageFile
        userToUpdate.save()
        return JsonResponse('User picture posted succesfully!', safe=False)

    else:
        return  JsonResponse('Failed to post user picture...', safe=False)

@csrf_exempt
def postFriendRequest(request, SenderUsername, SenderPassword, ReceiverUsername): #notify via socket if a channel exist
    if request.method=="POST":
        try:
            sender=User.objects.get(Username=SenderUsername, Password=SenderPassword)
            receiver=User.objects.get(Username=ReceiverUsername)
        except User.DoesNotExist:
            return JsonResponse('Failed to post friend request...', safe=False)

        receiver.Requests.add(sender)
        receiver.save()
        return JsonResponse('Posted friend request succesfully!', safe=False)

    else:
        return  JsonResponse('Failed to post friend request...', safe=False)

@csrf_exempt
def rejectFriendRequest(request, Username, Password, RejectUsername): #notify via socket if a channel exist
    if request.method=="POST":
        try:
            user=User.objects.get(Username=Username, Password=Password)
            rejectUser=User.objects.get(Username=RejectUsername)
        except User.DoesNotExist:
            return JsonResponse("Failed to reject friend request...", safe=False)
        
        user.Requests.remove(rejectUser)
        user.save()
        return JsonResponse("Friend request rejected succesfully!", safe=False)
    
    else:
        return JsonResponse("Failed to reject friend request...", safe=False)

@csrf_exempt
def acceptFriendRequest(request, Username, Password, AcceptUsername): #notify via socket if a channel exist
    if request.method=="POST":
        try:
            user=User.objects.get(Username=Username, Password=Password)
            acceptUser=User.objects.get(Username=AcceptUsername)
        except User.DoesNotExist:
            return JsonResponse("Failed to accept friend request...", safe=False)

        user.Requests.remove(acceptUser)
        user.Friends.add(acceptUser)
        user.save()
        return JsonResponse("Friend request accepted succesfully!", safe=False)

    else:
        return JsonResponse("Failed to accept friend request...", safe=False)

@csrf_exempt
def deleteFriend(request, Username, Password, DeleteUsername): #notify via socket if a channel exist
    if request.method=="POST":
        try:
            user=User.objects.get(Username=Username, Password=Password)
            deleteUser=User.objects.get(Username=DeleteUsername)
        except User.DoesNotExist:
            return JsonResponse("Failed to delete friend...", safe=False)

        user.Friends.remove(deleteUser)
        user.save()
        return JsonResponse("Friend deleted succesfully!", safe=False)

    else:
        return JsonResponse("Failed to delete friend...", safe=False)
        
"""    elif request.method=='POST':
        user_date=JSONParser().parse(request)
        users_serializer=UserSerializer(data=user_date)
        if users_serializer.is_valid():
            users_serializer.save()
            return JsonResponse('Added succesfully!', safe=False)
        return JsonResponse('Failed to add!', safe=False)"""