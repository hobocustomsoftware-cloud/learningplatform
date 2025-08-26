# enrollments/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from django.shortcuts import get_object_or_404
from .models import Enrollment
from courses.models import Course

class EnrollView(APIView):
    """
    Legacy: POST body {"course_id": 1} (သို့) {"course":1} နှစ်မျိုးစလုံးလက်ခံ
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        # (optional) role gate
        if getattr(user, "role", "student") != "student":
            return Response({"detail": "Only students can enroll."},
                            status=status.HTTP_403_FORBIDDEN)

        cid = request.data.get("course_id") or request.data.get("course")
        if not cid:
            return Response({"course_id": ["This field is required."]},
                            status=status.HTTP_400_BAD_REQUEST)

        course = get_object_or_404(Course, pk=cid)

        obj, created = Enrollment.objects.get_or_create(student=user, course=course)
        if created:
            return Response(
                {"id": obj.id, "course": course.id, "student": user.id}, # type: ignore
                status=status.HTTP_201_CREATED
            )
        return Response(  # idempotent
            {"detail": "Already enrolled", "id": obj.id, "course": course.id, "student": user.id}, # type: ignore
            status=status.HTTP_200_OK
        )

class EnrollByCourseIdView(APIView):
    """
    ✅ Recommended: POST /api/enrollments/enroll/<course_id>/
    Body မလို → frontend မှာ 400 မဖြစ်နှောက် (idempotent)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, course_id: int):
        user = request.user
        if getattr(user, "role", "student") != "student":
            return Response({"detail": "Only students can enroll."},
                            status=status.HTTP_403_FORBIDDEN)

        course = get_object_or_404(Course, pk=course_id)
        obj, created = Enrollment.objects.get_or_create(student=user, course=course)
        if created:
            return Response(
                {"id": obj.id, "course": course.id, "student": user.id}, # type: ignore
                status=status.HTTP_201_CREATED
            )
        return Response(
            {"detail": "Already enrolled", "id": obj.id, "course": course.id, "student": user.id}, # type: ignore
            status=status.HTTP_200_OK
        )
