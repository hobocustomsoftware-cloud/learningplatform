# payments/stripe_service.py
import stripe
from django.conf import settings
from payments.models import Payment

stripe.api_key = settings.STRIPE_SECRET_KEY

def create_checkout_session(user, course):
    amount_cents = int(course.price * 100)  # dollars → cents
    session = stripe.checkout.Session.create(
        payment_method_types=['card'],
        line_items=[{
            'price_data': {
                'currency': 'usd',
                'product_data': {
                    'name': course.title,
                },
                'unit_amount': amount_cents,
            },
            'quantity': 1,
        }],
        mode='payment',
        success_url='https://yourfrontend.com/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url='https://yourfrontend.com/cancel',
        metadata={
            'user_id': user.id,
            'course_id': course.id,
        }
    )

    Payment.objects.create(
        user=user,
        course=course,
        amount=course.price,
        provider='stripe',
        provider_payment_id=session.id,
        status='pending'
    )

    return session.url

def handle_webhook(event):
    # Example minimal webhook handling
    if event['type'] == 'checkout.session.completed':
        session = event['data']['object']
        payment = Payment.objects.get(provider_payment_id=session['id'])
        payment.status = 'completed'
        payment.save()
