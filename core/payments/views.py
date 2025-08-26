from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from courses.models import Course
from .stripe_service import create_checkout_session
# from .paypal_service import create_paypal_payment
from .telecom_service import create_telecom_payment
import stripe
from django.conf import settings
from django.http import HttpResponse
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from payments.models import Payment

from rest_framework.decorators import api_view
from rest_framework.response import Response
from payments.models import Payment
# import paypalrestsdk


stripe.api_key = settings.STRIPE_SECRET_KEY



class StripeCheckoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        course_id = request.data.get('course_id')
        course = Course.objects.get(id=course_id)
        url = create_checkout_session(request.user, course)
        return Response({"checkout_url": url})

# class PayPalCheckoutView(APIView):
#     permission_classes = [permissions.IsAuthenticated]

#     def post(self, request):
#         course_id = request.data.get('course_id')
#         course = Course.objects.get(id=course_id)
#         return_url = request.data.get('return_url')
#         cancel_url = request.data.get('cancel_url')
#         url = create_paypal_payment(request.user, course, return_url, cancel_url)
#         return Response({"checkout_url": url})

class TelecomPaymentView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        amount = request.data.get('amount')
        provider = request.data.get('provider')  # kpay / aya / cb / bank
        url = create_telecom_payment(request.user, amount, provider)
        return Response({"payment_url": url})




class StripeWebhookView(APIView):
    permission_classes = [AllowAny]  # Stripe calls it externally

    def post(self, request):
        payload = request.body
        sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
        event = None

        try:
            event = stripe.Webhook.construct_event(
                payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
            )
        except ValueError:
            return HttpResponse(status=400)
        except stripe.error.SignatureVerificationError: # type: ignore
            return HttpResponse(status=400)

        # Handle the checkout.session.completed event
        if event['type'] == 'checkout.session.completed':
            session = event['data']['object']
            payment = Payment.objects.get(provider_payment_id=session['id'])
            payment.status = 'completed'
            payment.save()

        return HttpResponse(status=200)




@api_view(['POST'])
def telecom_webhook(request, provider):
    """
    provider: kpay / aya / cb / bank
    """
    data = request.data
    payment_id = data.get('payment_id')
    status = data.get('status')  # success / fail

    try:
        payment = Payment.objects.get(id=payment_id, provider=provider)
        payment.status = 'completed' if status=='success' else 'failed'
        payment.save()
        # Optionally: trigger course enrollment
    except Payment.DoesNotExist:
        return Response({"error": "Payment not found"}, status=404)

    return Response({"message": "Webhook processed"})





# paypalrestsdk.configure({
#     "mode": settings.PAYPAL_MODE,
#     "client_id": settings.PAYPAL_CLIENT_ID,
#     "client_secret": settings.PAYPAL_SECRET
# })

# class PayPalCreatePaymentView(APIView):
#     def post(self, request):
#         payment = paypalrestsdk.Payment({
#             "intent": "sale",
#             "payer": {"payment_method": "paypal"},
#             "redirect_urls": {
#                 "return_url": "https://abcd-1234.trycloudflare.com/payments/paypal/success/",
#                 "cancel_url": "https://abcd-1234.trycloudflare.com/payments/paypal/cancel/",
#             },
#             "transactions": [{
#                 "item_list": {"items": [{"name": "Course Payment", "price": "100.00", "currency": "MMK", "quantity": 1}]},
#                 "amount": {"total": "100.00", "currency": "MMK"},
#                 "description": "Payment for course"
#             }]
#         })
#         if payment.create():
#             approval_url = next(link.href for link in payment.links if link.rel == "approval_url")
#             return Response({"approval_url": approval_url})
#         else:
#             return Response({"error": payment.error}, status=400)



class TelecomPaymentCallbackView(APIView):
    def post(self, request):
        # Mock telecom callback
        data = request.data
        print("Telecom callback received:", data)
        # Verify authenticity if API provides token/signature
        return Response({"status": "ok"})

class KPayPaymentCallbackView(APIView):
    def post(self, request):
        print("KPay callback:", request.data)
        return Response({"status": "ok"})

class AyaPayPaymentCallbackView(APIView):
    def post(self, request):
        print("AyaPay callback:", request.data)
        return Response({"status": "ok"})

class CBPayPaymentCallbackView(APIView):
    def post(self, request):
        print("CBPay callback:", request.data)
        return Response({"status": "ok"})
