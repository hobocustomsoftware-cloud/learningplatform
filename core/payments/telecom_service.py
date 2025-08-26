# payments/telecom_service.py
from payments.models import Payment

def create_telecom_payment(user, amount, provider):
    # provider: kpay / aya / cb / bank
    # API request simulation
    payment = Payment.objects.create(
        user=user,
        amount=amount,
        provider=provider,
        status='pending'
    )
    # return telecom payment url or QR code
    return f"https://{provider}.example.com/pay?payment_id={payment.id}" # type: ignore

def handle_telecom_webhook(provider, data):
    # Example: data contains payment_id & status
    payment_id = data.get('payment_id')
    status = data.get('status')  # success / fail
    payment = Payment.objects.get(id=payment_id)
    payment.status = 'completed' if status=='success' else 'failed'
    payment.save()
