# users/permissions.py
from rest_framework import permissions

class IsAdmin(permissions.BasePermission):
    """
    Only admin users can access
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'admin'

class IsInstructor(permissions.BasePermission):
    """
    Only instructor users can access
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'instructor'

class IsStudent(permissions.BasePermission):
    """
    Only student users can access
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'student'

class IsInstructorOrReadOnly(permissions.BasePermission):
    """
    Instructors can create/update, anyone can read
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_authenticated and request.user.role == 'instructor'

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.instructor == request.user
