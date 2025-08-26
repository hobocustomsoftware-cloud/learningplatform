# quizzes/services.py
from django.utils import timezone
from .models import Quiz, Question, Choice, Attempt, AttemptAnswer, Certificate
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from django.conf import settings
from pathlib import Path

def grade_attempt(attempt: Attempt, submitted_answers: list):
    """
    submitted_answers = [{'question': id, 'selected_choice_ids': [...]} or {'question': id, 'short_text': '...'}]
    """
    total_points = attempt.quiz.total_points() or 1
    earned = 0.0

    q_map = {q.id: q for q in attempt.quiz.questions.all()} # type: ignore
    choice_map = {c.id: c for q in q_map.values() for c in q.choices.all()}

    for ans in submitted_answers:
        q = q_map.get(ans['question'])
        if not q:
            continue
        aa = AttemptAnswer.objects.create(attempt=attempt, question=q)
        # grading
        if q.type in ('mcq','tf'):
            chosen_ids = set(ans.get('selected_choice_ids', [])[:1])  # one only
            aa.selected_choices.set([cid for cid in chosen_ids if cid in choice_map])
            correct_ids = {c.id for c in q.choices.filter(is_correct=True)}
            ok = chosen_ids == correct_ids
            aa.is_correct = ok
            aa.earned_points = q.points if ok else 0
        elif q.type == 'multi':
            chosen_ids = set(ans.get('selected_choice_ids', []))
            aa.selected_choices.set([cid for cid in chosen_ids if cid in choice_map])
            correct_ids = {c.id for c in q.choices.filter(is_correct=True)}
            # exact match
            ok = chosen_ids == correct_ids
            aa.is_correct = ok
            aa.earned_points = q.points if ok else 0
        else:  # 'short'
            aa.short_text = ans.get('short_text', '')
            # manual grading -> 0 for now
            aa.is_correct = False
            aa.earned_points = 0
        aa.save()
        earned += aa.earned_points

    attempt.score = earned
    attempt.percent = round(earned * 100.0 / total_points, 2)
    attempt.passed = attempt.percent >= attempt.quiz.passing_score
    attempt.submitted_at = timezone.now()
    attempt.save()
    return attempt

def generate_certificate_pdf(certificate: Certificate):
    media_dir = Path(settings.MEDIA_ROOT) / 'certificates'
    media_dir.mkdir(parents=True, exist_ok=True)
    filename = media_dir / f"cert_{certificate.id}.pdf" # type: ignore

    c = canvas.Canvas(str(filename), pagesize=A4)
    w, h = A4
    c.setFont("Helvetica-Bold", 28)
    c.drawCentredString(w/2, h-150, "Certificate of Completion")
    c.setFont("Helvetica", 16)
    c.drawCentredString(w/2, h-220, f"This certifies that")
    c.setFont("Helvetica-Bold", 22)
    c.drawCentredString(w/2, h-260, certificate.student.get_full_name() or certificate.student.username)
    c.setFont("Helvetica", 16)
    c.drawCentredString(w/2, h-300, f"has successfully completed")
    c.setFont("Helvetica-Bold", 18)
    c.drawCentredString(w/2, h-330, f"{certificate.course.title}")
    c.setFont("Helvetica", 14)
    c.drawCentredString(w/2, h-370, f"Issued on: {certificate.issued_at.strftime('%Y-%m-%d')}")
    c.setFont("Helvetica-Oblique", 12)
    c.drawCentredString(w/2, h-410, "Powered by Your LMS")
    c.showPage()
    c.save()

    # update file field relative path
    certificate.file.name = f"certificates/{filename.name}"
    certificate.save()
    return certificate
