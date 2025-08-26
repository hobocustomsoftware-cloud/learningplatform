# core/classroom/views.py
from django.utils import timezone
from rest_framework import viewsets, status, permissions, decorators, response
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.viewsets import ModelViewSet

from enrollments.models import Enrollment
from .models import LiveClass
from .serializers import LiveClassSerializer
from .permissions import IsInstructorOrAdmin, CanJoinLiveClass
from .utils import generate_jitsi_token

class LiveClassViewSet(viewsets.ModelViewSet):
    queryset = LiveClass.objects.all()
    serializer_class = LiveClassSerializer

    def get_permissions(self):
        if self.action in ["create", "start"]:
            return [IsAuthenticated(),IsInstructorOrAdmin()]
        if self.action in ["join", "list", "retrieve"]:
            return [IsAuthenticated(), CanJoinLiveClass()]
        # list/retrieve က enroll filtering ကို view/filterset ထဲမှာ စီမံထားနိုင်
        return [IsAuthenticated()]

    @decorators.action(detail=True, methods=["post"])
    def join(self, request, pk=None):
        live = self.get_object()
        
        # Determine if user is a moderator (instructor/admin)
        user_role = getattr(request.user, "role", "")
        is_moderator = user_role in ("instructor", "admin")
        
        # Generate JWT token for the user
        try:
            token = generate_jitsi_token(request.user, live.room_name, is_moderator=is_moderator)
        except ValueError as e:
            return response.Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        # Create feature flags based on user role
        feature_flags = {
            "lobby-mode.enabled": not is_moderator,  # Lobby enabled for participants only
            "prejoinpage.enabled": True,             # Pre-join page enabled for all
            "recording.enabled": is_moderator,       # Recording enabled for moderators only
        }
        
        # join payload ပြန်ပေး (room, subject, feature flags …)
        data = {
            "room": live.room_name,
            "subject": live.title,
            "jitsi_server_url": "https://meet.jit.si",
            "jitsi_domain": "meet.jit.si",
            "token": token,
            "feature_flags": feature_flags,
            "is_moderator": is_moderator,
        }
        return response.Response(data)

    @decorators.action(detail=True, methods=["post"])
    def start(self, request, pk=None):
        # instructor/admin သာ ခေါ်ရ
        live = self.get_object()
        
        # Mark the live class as live and set started_at if not already set
        if not live.is_live:
            live.is_live = True
            if not live.started_at:
                live.started_at = timezone.now()
            live.save()
        
        # Generate JWT token for the moderator (instructor/admin)
        try:
            token = generate_jitsi_token(request.user, live.room_name, is_moderator=True)
        except ValueError as e:
            return response.Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        # Create feature flags for moderators
        feature_flags = {
            "lobby-mode.enabled": False,        # Lobby disabled for moderators
            "prejoinpage.enabled": True,        # Pre-join page enabled for all
            "recording.enabled": True,          # Recording enabled for moderators
        }
        
        # join payload ပြန်ပေး (room, subject, feature flags …)
        data = {
            "room": live.room_name,
            "subject": live.title,
            "jitsi_server_url": "https://meet.jit.si",
            "jitsi_domain": "meet.jit.si",
            "token": token,
            "feature_flags": feature_flags,
            "is_moderator": True,   # host
        }
        return response.Response(data, status=status.HTTP_200_OK)