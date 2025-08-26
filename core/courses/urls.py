# courses/urls.py
from rest_framework import routers
from .views import CategoryViewSet, CourseViewSet, SectionViewSet, LessonViewSet

router = routers.DefaultRouter()
router.register(r'categories', CategoryViewSet)
router.register(r'courses', CourseViewSet)
router.register(r'sections', SectionViewSet)
router.register(r'lessons', LessonViewSet)

urlpatterns = router.urls
