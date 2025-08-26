# Jitsi Meet Integration Enhancement Plan

## Current State Analysis

The current implementation has a basic Jitsi integration in the LiveClassViewSet but lacks several important features:

1. No room name generation in the LiveClass model
2. No JWT token generation for secure meetings
3. No proper role-based access control for meeting hosts/participants
4. No lobby mode implementation for student participants
5. No meeting recording functionality

## Proposed Enhancements

### 1. LiveClass Model Enhancement

Add a `room_name` field to the LiveClass model with automatic generation:

```python
# classroom/models.py
import uuid
from django.db import models
from django.conf import settings
from courses.models import Course

User = settings.AUTH_USER_MODEL

class LiveClass(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='live_classes')
    instructor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='live_classes')
    title = models.CharField(max_length=255)
    room_name = models.CharField(max_length=255, unique=True, blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    is_live = models.BooleanField(default=False)
    
    def save(self, *args, **kwargs):
        if not self.room_name:
            # Generate unique room name
            self.room_name = f"{self.course.id}-{self.id}-{uuid.uuid4().hex[:8]}"
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.title
```

### 2. JWT Token Generation for Secure Meetings

Add JWT token generation for secure Jitsi meetings:

```python
# classroom/utils.py
import jwt
import time
from django.conf import settings

def generate_jitsi_token(user, room_name, is_moderator=False):
    """
    Generate JWT token for Jitsi Meet
    """
    # Jitsi app ID and secret should be in settings
    app_id = getattr(settings, 'JITSI_APP_ID', 'your_app_id')
    app_secret = getattr(settings, 'JITSI_APP_SECRET', 'your_app_secret')
    
    payload = {
        "aud": app_id,
        "iss": app_id,
        "sub": "localhost",  # Your domain
        "exp": int(time.time()) + 3600,  # Token expires in 1 hour
        "room": room_name,
        "moderator": is_moderator,
        "context": {
            "user": {
                "name": user.get_full_name() or user.username,
                "email": user.email,
                "id": str(user.id),
                "moderator": is_moderator
            }
        }
    }
    
    token = jwt.encode(payload, app_secret, algorithm='HS256')
    return token
```

### 3. Enhanced Role-Based Access Control

Update the LiveClassViewSet with proper role-based access:

```python
# classroom/views.py
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
            return [IsInstructorOrAdmin()]
        if self.action in ["join"]:
            return [permissions.IsAuthenticated(), CanJoinLiveClass()]
        # list/retrieve က enroll filtering ကို view/filterset ထဲမှာ စီမံထားနိုင်
        return [permissions.IsAuthenticated()]

    @decorators.action(detail=True, methods=["post"])
    def join(self, request, pk=None):
        live = self.get_object()
        user = request.user
        
        # Check user role
        is_moderator = getattr(user, "role", "") in ("instructor", "admin")
        
        # Generate JWT token
        token = generate_jitsi_token(user, live.room_name, is_moderator)
        
        # join payload ပြန်ပေး (room, subject, feature flags …)
        data = {
            "room": live.room_name,
            "subject": live.title,
            "jitsi_server_url": "https://meet.jit.si",
            "jitsi_domain": "meet.jit.si",
            "token": token,  # Add JWT token
            "feature_flags": {
                "lobby-mode.enabled": not is_moderator,  # Enable lobby for students
                "prejoinpage.enabled": True,
                "recording.enabled": is_moderator,  # Only moderators can record
            },
            "is_moderator": is_moderator,
        }
        return response.Response(data)

    @decorators.action(detail=True, methods=["post"])
    def start(self, request, pk=None):
        # instructor/admin သာ ခေါ်ရ
        live = self.get_object()
        user = request.user
        
        # Mark as live
        live.is_live = True
        live.save()
        
        # Generate JWT token with moderator privileges
        token = generate_jitsi_token(user, live.room_name, is_moderator=True)
        
        data = {
            "room": live.room_name,
            "subject": live.title,
            "jitsi_server_url": "https://meet.jit.si",
            "jitsi_domain": "meet.jit.si",
            "token": token,  # Add JWT token
            "feature_flags": {
                "lobby-mode.enabled": True,  # Enable lobby mode
                "prejoinpage.enabled": True,
                "recording.enabled": True,  # Host can record
            },
            "is_moderator": True,  # host
        }
        return response.Response(data, status=status.HTTP_200_OK)
```

### 4. Environment Configuration

Add Jitsi configuration to .env file:

```env
# .env
JITSI_APP_ID=your_jitsi_app_id
JITSI_APP_SECRET=your_jitsi_app_secret
JITSI_SERVER_URL=https://meet.jit.si
```

And to settings.py:

```python
# core/settings.py
JITSI_APP_ID = os.getenv('JITSI_APP_ID')
JITSI_APP_SECRET = os.getenv('JITSI_APP_SECRET')
JITSI_SERVER_URL = os.getenv('JITSI_SERVER_URL', 'https://meet.jit.si')
```

### 5. Dependencies

Add required dependencies to requirements.txt:

```txt
# requirements.txt
PyJWT==2.8.0
cryptography==42.0.5
```

## Implementation Steps

1. Update LiveClass model with room_name field and generation logic
2. Create utils.py with JWT token generation function
3. Update LiveClassViewSet with enhanced join/start endpoints
4. Update .env and settings.py with Jitsi configuration
5. Add required dependencies to requirements.txt
6. Update serializers if needed
7. Test with different user roles

## Security Considerations

1. JWT tokens should expire after a reasonable time
2. Only authorized users should be able to generate tokens
3. Lobby mode should be enabled for student participants
4. Recording should only be available to moderators
5. Room names should be unique and not guessable

## Flutter Integration

The API will return all necessary information for Flutter integration:
- Room name
- JWT token
- Feature flags
- Moderator status
- Jitsi server URL

This will allow the Flutter app to properly configure the Jitsi Meet SDK with the correct permissions based on user roles.