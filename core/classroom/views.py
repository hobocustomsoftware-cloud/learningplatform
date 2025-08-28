# core/classroom/views.py
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import viewsets, permissions, status
from django.conf import settings
from .models import LiveClass
from .serializers import LiveClassSerializer
from utils.agora import build_agora_token  # ✅ uses (channel_name, uid, is_host)

def _is_host_user(user) -> bool:
    try:
        role = getattr(user, "role", None)
        role = (str(role).strip().lower() if role is not None else "")
    except Exception:
        role = ""
    if role in ("admin", "instructor"):
        return True
    if getattr(user, "is_staff", False) or getattr(user, "is_superuser", False):
        return True
    try:
        if user.groups.filter(name__in=["admin", "instructor"]).exists():
            return True
    except Exception:
        pass
    return False

class LiveClassViewSet(viewsets.ModelViewSet):
    queryset = LiveClass.objects.all()
    serializer_class = LiveClassSerializer
    permission_classes = [permissions.IsAuthenticated]

    def _make_agora_payload(self, *, live: LiveClass, user, is_host: bool):
        channel = live.channel_name  # your model property
        uid = user.id or 0

        # ✅ NEW: match utils/agora.py signature (no kwargs)
        token = build_agora_token(channel, uid, is_host)

        return {
            "provider": "agora",
            "app_id": settings.AGORA_APP_ID,  # frontend needs it
            "channel": channel,
            "token": token,
            "uid": uid,
            "is_host": is_host,
        }

    @action(detail=True, methods=['post'])
    def start(self, request, pk=None):
        live = self.get_object()
        if not _is_host_user(request.user):
            return Response({"detail": "Only host can start."},
                            status=status.HTTP_403_FORBIDDEN)
        if not live.is_live:
            live.is_live = True
            live.save(update_fields=["is_live"])
        payload = self._make_agora_payload(live=live, user=request.user, is_host=True)
        return Response(payload, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        live = self.get_object()
        is_host = _is_host_user(request.user)  # host/student ပြန်သတ်မှတ်
        payload = self._make_agora_payload(live=live, user=request.user, is_host=is_host)
        return Response(payload, status=status.HTTP_200_OK)
