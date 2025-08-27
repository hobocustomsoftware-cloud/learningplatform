# core/classroom/serializers.py
from rest_framework import serializers
from .models import LiveClass

class LiveClassSerializer(serializers.ModelSerializer):
    instructor = serializers.HiddenField(default=serializers.CurrentUserDefault())
    class Meta: # type: ignore
        model = LiveClass
        fields = "__all__"
        read_only_fields = ["id", "is_live"]

    def create(self, validated_data):
        # optional: if room not provided, generate one
        if not validated_data.get("room"):
            c = validated_data.get("course")
            validated_data["room"] = f"lms_course{c.id}_class"  # or append pk later
        return super().create(validated_data)