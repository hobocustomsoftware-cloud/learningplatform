# quizzes/urls.py
from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import QuizViewSet, QuestionViewSet, AttemptViewSet, CertificateViewSet

router = DefaultRouter()
router.register(r'quizzes', QuizViewSet, basename='quiz')
router.register(r'questions', QuestionViewSet, basename='question')
router.register(r'certificates', CertificateViewSet, basename='certificate')

attempt_list = AttemptViewSet.as_view({'post':'create'})
attempt_detail = AttemptViewSet.as_view({'get':'retrieve'})
attempt_submit = AttemptViewSet.as_view({'post':'submit'})

urlpatterns = [
    path('', include(router.urls)),
    path('attempts/', attempt_list, name='attempt-create'),
    path('attempts/<int:pk>/', attempt_detail, name='attempt-detail'),
    path('attempts/<int:pk>/submit/', attempt_submit, name='attempt-submit'),
]
