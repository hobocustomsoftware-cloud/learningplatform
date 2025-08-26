# quizzes/serializers.py
from rest_framework import serializers
from .models import Quiz, Question, Choice, Attempt, AttemptAnswer, Certificate

class ChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Choice
        fields = ['id','text','is_correct']
        extra_kwargs = {'is_correct': {'write_only': True}}  # hide correct flag from students

class QuestionSerializer(serializers.ModelSerializer):
    choices = ChoiceSerializer(many=True)
    class Meta:
        model = Question
        fields = ['id','text','type','points','order','choices']

    def create(self, validated_data):
        choices_data = validated_data.pop('choices', [])
        q = Question.objects.create(**validated_data)
        for c in choices_data:
            Choice.objects.create(question=q, **c)
        return q

    def update(self, instance, validated_data):
        choices_data = validated_data.pop('choices', [])
        for attr, val in validated_data.items():
            setattr(instance, attr, val)
        instance.save()
        if choices_data:
            instance.choices.all().delete()
            for c in choices_data:
                Choice.objects.create(question=instance, **c)
        return instance

class QuizSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, required=False)
    class Meta:
        model = Quiz
        fields = ['id','course','lesson','title','description','time_limit','passing_score','is_published','questions']

    def create(self, validated_data):
        questions = validated_data.pop('questions', [])
        quiz = Quiz.objects.create(**validated_data)
        for order, qd in enumerate(questions, start=1):
            qd['order'] = qd.get('order', order)
            QuestionSerializer().create({**qd, 'quiz': quiz})
        return quiz

class AttemptAnswerWriteSerializer(serializers.Serializer):
    question = serializers.IntegerField()
    selected_choice_ids = serializers.ListField(child=serializers.IntegerField(), required=False)
    short_text = serializers.CharField(allow_blank=True, required=False)

class AttemptSubmitSerializer(serializers.Serializer):
    answers = AttemptAnswerWriteSerializer(many=True)

class AttemptReadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attempt
        fields = ['id','score','percent','passed','started_at','submitted_at']

class CertificateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Certificate
        fields = ['id','course','student','issued_at','file']
