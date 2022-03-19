from bottle_websocket import websocket
from django.urls import path
from . import consumers

websocket_urlpatterns = [
    path("ws/socket-server/", consumers.ChatConsumer.as_asgi())
]