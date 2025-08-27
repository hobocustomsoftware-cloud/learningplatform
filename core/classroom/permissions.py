# core/classroom/permissions.py
from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsInstructorOrAdmin(BasePermission):
    def has_permission(self, request, view):
        # if request.method in SAFE_METHODS:
        #     return request.user and request.user.is_authenticated
        # # create/update/delete = instructor or admin only
        # return (
        #     request.user and request.user.is_authenticated and
        #     getattr(request.user, "role", "") in ("instructor", "admin")
        # )
        u = request.user
        role = getattr(u, "role", "student")
        return role in ("instructor", "admin")

class CanJoinLiveClass(BasePermission):
    """
    action=join အတွက်: student/instructor/admin သာ OK.
    student ဖြစ်ရင် 해당 live class ရဲ့ course ကို enrolled ဖြစ်ဖို့လို.
    """
    def has_object_permission(self, request, view, obj):  # type: ignore[override]
        if not (request.user and request.user.is_authenticated):
            return False
        role = getattr(request.user, "role", "")
        if role in ("instructor", "admin"):
            return True
        # student → 해당 course ကို enrolled ဖြစ်မှ join ရ
        return obj.course.enrollments.filter(student=request.user).exists()
