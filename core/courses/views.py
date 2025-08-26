# courses/views.py
from rest_framework import viewsets, permissions
from .models import Category, Course, Section, Lesson 
from .serializers import CategorySerializer, CourseSerializer, SectionSerializer,  LessonSerializer
from django.db.models import Prefetch

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]

# class CourseViewSet(viewsets.ModelViewSet):
#     queryset = Course.objects.all()
#     serializer_class = CourseSerializer
#     permission_classes = [permissions.AllowAny]

#     def perform_create(self, serializer):
#         serializer.save(instructor=self.request.user)


class CourseViewSet(viewsets.ModelViewSet):
    serializer_class = CourseSerializer
    queryset = (
        Course.objects.all()
        .prefetch_related(
            Prefetch(
                'sections',                             # ✅ NOT 'section'
                queryset=Section.objects.order_by('order').prefetch_related(
                    Prefetch('lessons', queryset=Lesson.objects.order_by('order'))  # ✅
                ),
            )
        )
    )
    

    # ✅ List & Retrieve → Public, остальные → Auth required
    def get_permissions(self):
        if self.action in ["list", "retrieve"]:
            return [permissions.AllowAny()]
        return super().get_permissions()

    # (ရွေးချယ်) simple search/filter (q, price_min/max)
    def get_queryset(self):
        qs = super().get_queryset()
        q = self.request.query_params.get("q")
        if q:
            qs = qs.filter(title__icontains=q)
        pmin = self.request.query_params.get("price_min")
        pmax = self.request.query_params.get("price_max")
        if pmin:
            qs = qs.filter(price__gte=pmin)
        if pmax:
            qs = qs.filter(price__lte=pmax)
        return qs.order_by("-created_at")





class SectionViewSet(viewsets.ModelViewSet):
    queryset = Section.objects.all()
    serializer_class = SectionSerializer
    permission_classes = [permissions.AllowAny]

class LessonViewSet(viewsets.ModelViewSet):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
    permission_classes = [permissions.AllowAny]
