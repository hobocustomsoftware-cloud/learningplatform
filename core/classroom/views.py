# classroom/views.py
from django.utils import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import LiveClass
from .serializers import LiveClassSerializer
from .permissions import IsInstructorOrAdmin
from utils.agora import build_agora_token



class LiveClassViewSet(viewsets.ModelViewSet):
    """
    /api/classroom/live-classes/           GET  -> list
                                           POST -> create (instructor/admin only)
    /api/classroom/live-classes/{id}/start/ POST -> host token (instructor/admin only)
    /api/classroom/live-classes/{id}/join/  POST -> audience or host token (any logged-in)
    """
    queryset = LiveClass.objects.all().order_by("-id")
    serializer_class = LiveClassSerializer
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.action in ("create", "start"):
            return [IsAuthenticated(), IsInstructorOrAdmin()]
        return [IsAuthenticated()]

    def create(self, request, *args, **kwargs):
        """
        Body:
        {
          "course": 1,
          "title": "Lesson A",
          "started_at": "2025-08-26T10:00:00Z",   # optional
          "ended_at":   "2025-08-26T11:00:00Z"    # optional
        }
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        obj = serializer.save()
        headers = self.get_success_headers(serializer.data)
        return Response(
            LiveClassSerializer(obj).data,
            status=status.HTTP_201_CREATED,
            headers=headers,
        )

    @action(detail=True, methods=["post"])
    def start(self, request, pk=None):
        """
        Host-only: mark is_live True (if needed) and return host token.
        """
        lc: LiveClass = self.get_object()

        # ensure started_at & is_live
        changed = False
        if not lc.started_at:
            lc.started_at = timezone.now()
            changed = True
        if not lc.is_live:
            lc.is_live = True
            changed = True
        if changed:
            lc.save(update_fields=["started_at", "is_live"])

        uid = request.user.pk & 0xFFFFFFFF  # Agora uid must be <= 2^32-1
        channel = lc.channel_name()

        token = build_agora_token(channel=channel, uid=uid, is_host=True)

        payload = {
            "engine": "agora",
            "is_host": True,
            "channel": channel,
            "uid": uid,
            "rtc_token": token,
            "app_id": getattr(request.settings if hasattr(request, "settings") else None, "AGORA_APP_ID", None) or
                      __import__("django.conf").conf.settings.AGORA_APP_ID,
            # Optional meta (frontend အတွက်)
            "class_id": lc.id,
            "course_id": lc.course_id,
            "title": lc.title,
        }
        return Response(payload)

    @action(detail=True, methods=["post"])
    def join(self, request, pk=None):
        """
        Any logged-in user joins as:
          - host if role in {instructor, admin}
          - audience if role == student
        """
        lc: LiveClass = self.get_object()
        role = getattr(request.user, "role", "student")
        is_host = role in ("instructor", "admin")

        # class လက်ရှိរស់မယ်ဆိုရင် is_live True; မဟုတ်ရင် host join ပေးရင်သာစဖြစ်စေလိုလို့
        if is_host and not lc.is_live:
            lc.is_live = True
            if not lc.started_at:
                lc.started_at = timezone.now()
            lc.save(update_fields=["is_live", "started_at"])

        uid = request.user.pk & 0xFFFFFFFF
        channel = lc.channel_name()
        token = build_agora_token(channel=channel, uid=uid, is_host=is_host)

        payload = {
            "engine": "agora",
            "is_host": is_host,
            "channel": channel,
            "uid": uid,
            "rtc_token": token,
            "app_id": __import__("django.conf").conf.settings.AGORA_APP_ID,
            "class_id": lc.id,
            "course_id": lc.course_id,
            "title": lc.title,
        }
        return Response(payload)
