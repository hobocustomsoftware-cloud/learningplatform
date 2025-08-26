# enrollments/serializers.py
from rest_framework import serializers
from .models import Enrollment

class EnrollmentSerializer(serializers.ModelSerializer):
    course_id = serializers.IntegerField(write_only=True)
    course = serializers.IntegerField(source="course.id", read_only=True)

    class Meta:
        model = Enrollment
        fields = ("id", "student", "course", "course_id", "enrolled_at")
        read_only_fields = ("id", "student", "course", "enrolled_at")

    def create(self, validated_data):
        user = self.context["request"].user
        cid = validated_data.pop("course_id")
        # course instance ထုတ်ထားပြီး create
        from courses.models import Course
        course = Course.objects.get(pk=cid)
        obj, _ = Enrollment.objects.get_orCreate(student=user, course=course) # type: ignore
        return obj
