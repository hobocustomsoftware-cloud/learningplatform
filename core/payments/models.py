# from django.db import models
# from django.conf import settings
# from courses.models import Course

# User = settings.AUTH_USER_MODEL

# class Payment(models.Model):
#     PAYMENT_STATUS = (
#         ('pending', 'Pending'),
#         ('completed', 'Completed'),
#         ('failed', 'Failed'),
#     )

#     PAYMENT_PROVIDERS = (
#     ('stripe', 'Stripe'),
#     ('paypal', 'PayPal'),
#     ('kpay', 'KPay'),
#     ('ayapay', 'AyaPay'),
#     ('cbpay', 'CBPay'),
#     ('bank', 'Online Banking'),
# )

#     user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
#     course = models.ForeignKey(Course, on_delete=models.CASCADE, null=True, blank=True)
#     amount = models.FloatField()
#     currency = models.CharField(max_length=10, default='USD')
#     provider = models.CharField(max_length=50)  # stripe / paypal / kpay / aya / cb / bank
#     provider_payment_id = models.CharField(max_length=255, blank=True, null=True)
#     status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
#     created_at = models.DateTimeField(auto_now_add=True)
#     updated_at = models.DateTimeField(auto_now=True)


from django.db import models
from django.conf import settings
from courses.models import Course

User = settings.AUTH_USER_MODEL

PAYMENT_STATUS = (
    ('pending', 'Pending'),
    ('completed', 'Completed'),
    ('failed', 'Failed'),
)

PAYMENT_PROVIDERS = (
    ('stripe', 'Stripe'),
    ('paypal', 'PayPal'),
    ('kpay', 'KPay'),
    ('ayapay', 'AyaPay'),
    ('cbpay', 'CBPay'),
    ('bank', 'Online Banking'),
)

class Payment(models.Model):
    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='payments')
    provider = models.CharField(max_length=20, choices=PAYMENT_PROVIDERS)
    provider_payment_id = models.CharField(max_length=255, blank=True, null=True)
    amount = models.PositiveIntegerField()
    currency = models.CharField(max_length=10, default='MMK')
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.student} - {self.course} - {self.provider} - {self.status}"
