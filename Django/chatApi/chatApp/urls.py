from django.urls import re_path, path
from chatApp import views

urlpatterns=[
    path("socketPruebas", views.lobby),

    path('getUser/<str:Username>/<str:Password>', views.getUser),
    path('updateName/<str:Username>/<str:Password>/<str:Name>', views.updateName),
    path('postProfilePicture/<str:Username>/<str:Password>', views.postProfilePicture),
    path('postFriendRequest/<str:SenderUsername>/<str:SenderPassword>/<str:ReceiverUsername>', views.postFriendRequest),
    path('rejectFriendRequest/<str:Username>/<str:Password>/<str:RejectUsername>', views.rejectFriendRequest),
    path('acceptFriendRequest/<str:Username>/<str:Password>/<str:AcceptUsername>', views.acceptFriendRequest),
    path('deleteFriend/<str:Username>/<str:Password>/<str:DeleteUsername>', views.deleteFriend),
    path('getUsersWhichContainString/<str:Username>', views.getUsersWhichContainString),
    #url(r'^user/([0-9]+)$')
]