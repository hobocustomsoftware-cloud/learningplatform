# core/classroom/serializers.py
from rest_framework import serializers
from .models import LiveClass

class LiveClassSerializer(serializers.ModelSerializer):
    channel = serializers.SerializerMethodField()

    class Meta: # type: ignore
        model = LiveClass
        fields = [
            'id', 'course', 'title', 'started_at', 'ended_at', 'is_live',
            'channel',  # ✅ frontend ကို channel string ပြ
        ]

    def get_channel(self, obj: LiveClass) -> str:
        return obj.channel_name
