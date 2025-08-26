from django.urls import path
from .views import EnrollView, EnrollByCourseIdView

urlpatterns = [
    path('enroll/', EnrollView.as_view(), name='enroll'),                          # legacy (body)
    path('enroll/<int:course_id>/', EnrollByCourseIdView.as_view(), name='enroll-by-id'),  # ✅ new (recommended)
]