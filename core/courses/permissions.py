# courses/permissions.py
from rest_framework import permissions

class IsInstructorOrReadOnly(permissions.BasePermission):
    """
    Only instructors can create/update courses.
    """

    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_authenticated and request.user.role == 'instructor'

    def has_object_permission(self, request, view, obj):
        # Instructors can edit only their own courses
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.instructor == request.user
