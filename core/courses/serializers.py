# courses/serializers.py
from rest_framework import serializers
from .models import Category, Course, Section, Lesson

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

# class LessonSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Lesson
#         fields = '__all__'



# class LessonLiteSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Lesson
#         fields = ("id","title","duration_seconds","order")

# class CourseSerializer(serializers.ModelSerializer):
#     instructor_name = serializers.CharField(source="instructor.get_full_name", read_only=True)
#     lessons = LessonLiteSerializer(many=True, read_only=True)
#     class Meta:
#         model = Course
#         fields = (
#             "id","title","description","price","thumbnail",
#             "status","created_at","instructor_name","lessons",
#         )





# class SectionSerializer(serializers.ModelSerializer):
#     lessons = LessonSerializer(many=True, read_only=True)
    
#     class Meta:
#         model = Section
#         fields = '__all__'

# class CourseSerializer(serializers.ModelSerializer):
#     sections = SectionSerializer(many=True, read_only=True)
#     instructor = serializers.StringRelatedField(read_only=True)
    
#     class Meta:
#         model = Course
#         fields = '__all__'




class LessonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lesson
        fields = ('id', 'title', 'order')  # swagger ထဲက field အတိုင်း ထပ်ထည့်နိုင်

class SectionSerializer(serializers.ModelSerializer):
    lessons = LessonSerializer(many=True, read_only=True)
    class Meta:
        model = Section
        fields = ('id', 'title', 'order', 'course', 'lessons')

class CourseSerializer(serializers.ModelSerializer):
    sections = SectionSerializer(many=True, read_only=True)
    class Meta:
        model = Course
        fields = ('id', 'instructor', 'title', 'description', 'thumbnail',
                  'price', 'status', 'created_at', 'category', 'sections')