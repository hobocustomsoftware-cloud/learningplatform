# classroom/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ClassroomConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.class_id = self.scope['url_route']['kwargs']['class_id']
        self.room_group_name = f'class_{self.class_id}'

        await self.channel_layer.group_add( # type: ignore
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code): # type: ignore
        await self.channel_layer.group_discard( # type: ignore
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data): # type: ignore
        data = json.loads(text_data)
        # Forward the signaling data to all participants
        await self.channel_layer.group_send( # type: ignore
            self.room_group_name,
            {
                'type': 'signal_message',
                'message': data
            }
        )

    async def signal_message(self, event):
        message = event['message']
        await self.send(text_data=json.dumps(message))
