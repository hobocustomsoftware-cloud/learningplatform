from rest_framework.routers import DefaultRouter
from .views import LiveClassViewSet

router = DefaultRouter()
router.register(r'live-classes', LiveClassViewSet, basename='liveclass')

urlpatterns = router.urls
