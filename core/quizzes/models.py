# quizzes/models.py
from django.db import models
from django.conf import settings
from courses.models import Course, Lesson

User = settings.AUTH_USER_MODEL

QUESTION_TYPES = (
    ('mcq', 'Multiple Choice (single correct)'),
    ('multi', 'Multiple Select (multi correct)'),
    ('tf', 'True/False'),
    ('short', 'Short Answer (manual grade)'),
)

class Quiz(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='quizzes')
    lesson = models.ForeignKey(Lesson, on_delete=models.SET_NULL, null=True, blank=True, related_name='quizzes')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    time_limit = models.PositiveIntegerField(null=True, blank=True)   # seconds
    passing_score = models.PositiveIntegerField(default=60)           # percent
    is_published = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def total_points(self) -> int:
        questions: 'models.QuerySet[Question]' = self.questions.all() # type: ignore
        return sum(q.points for q in self.questions) # type: ignore

    def __str__(self):
        return self.title

class Question(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name='questions')
    text = models.TextField()
    type = models.CharField(max_length=10, choices=QUESTION_TYPES, default='mcq')
    points = models.PositiveIntegerField(default=1)
    order = models.PositiveIntegerField(default=1)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.quiz.title} - Q{self.order}"

class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='choices')
    text = models.CharField(max_length=500)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return self.text[:50]

class Attempt(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name='attempts')
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='quiz_attempts')
    started_at = models.DateTimeField(auto_now_add=True)
    submitted_at = models.DateTimeField(null=True, blank=True)
    score = models.FloatField(default=0.0)     # numeric total
    percent = models.FloatField(default=0.0)   # 0-100
    passed = models.BooleanField(default=False)

    class Meta:
        unique_together = ('quiz', 'student')  # one graded attempt per quiz (simple MVP)

class AttemptAnswer(models.Model):
    attempt = models.ForeignKey(Attempt, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    # for mcq/tf: one choice; for multi: many choices; for short: free text
    selected_choices = models.ManyToManyField(Choice, blank=True)
    short_text = models.TextField(blank=True, null=True)
    is_correct = models.BooleanField(default=False)
    earned_points = models.FloatField(default=0.0)

class Certificate(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='certificates')
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='certificates')
    attempt = models.OneToOneField(Attempt, on_delete=models.CASCADE, related_name='certificate')
    issued_at = models.DateTimeField(auto_now_add=True)
    file = models.FileField(upload_to='certificates/')

    class Meta:
        unique_together = ('course', 'student')
