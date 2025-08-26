# quizzes/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

from users.permissions import IsInstructor, IsStudent
from .models import Quiz, Question, Choice, Attempt, Certificate
from .serializers import (
    QuizSerializer, QuestionSerializer, AttemptSubmitSerializer,
    AttemptReadSerializer, CertificateSerializer
)
from .services import grade_attempt, generate_certificate_pdf

# Instructor endpoints
class QuizViewSet(viewsets.ModelViewSet):
    queryset = Quiz.objects.all().select_related('course','lesson')
    serializer_class = QuizSerializer
    permission_classes = [IsInstructor]

    def perform_create(self, serializer):
        # ensure quiz ties to instructor's course
        serializer.save()

    @action(detail=True, methods=['post'], permission_classes=[IsInstructor])
    def publish(self, request, pk=None):
        quiz = self.get_object()
        quiz.is_published = True
        quiz.save()
        return Response({'status': 'published'})

class QuestionViewSet(viewsets.ModelViewSet):
    queryset = Question.objects.all().select_related('quiz')
    serializer_class = QuestionSerializer
    permission_classes = [IsInstructor]

# Student endpoints
class AttemptViewSet(viewsets.ViewSet):
    permission_classes = [IsStudent]

    def create(self, request):
        quiz_id = request.data.get('quiz')
        quiz = get_object_or_404(Quiz, id=quiz_id, is_published=True)
        attempt, _ = Attempt.objects.get_or_create(quiz=quiz, student=request.user)
        return Response({'attempt_id': attempt.id}, status=201) # type: ignore

    @action(detail=True, methods=['post'])
    def submit(self, request, pk=None):
        attempt = get_object_or_404(Attempt, id=pk, student=request.user)
        serializer = AttemptSubmitSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        graded = grade_attempt(attempt, serializer.validated_data['answers']) # type: ignore

        # auto-issue certificate if passed
        if graded.passed and not hasattr(graded, 'certificate'):
            cert = Certificate.objects.create(course=graded.quiz.course, student=request.user, attempt=graded)
            generate_certificate_pdf(cert)

        return Response(AttemptReadSerializer(graded).data)

    def retrieve(self, request, pk=None):
        attempt = get_object_or_404(Attempt, id=pk, student=request.user)
        return Response(AttemptReadSerializer(attempt).data)

class CertificateViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = CertificateSerializer
    permission_classes = [IsStudent]

    def get_queryset(self): # type: ignore
        return Certificate.objects.filter(student=self.request.user)
