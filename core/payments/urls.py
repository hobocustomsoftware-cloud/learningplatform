# payments/urls.py
from django.urls import path
from .views import ( StripeCheckoutView,  TelecomPaymentView, StripeWebhookView, 
                    telecom_webhook, TelecomPaymentCallbackView, KPayPaymentCallbackView, AyaPayPaymentCallbackView,
                    CBPayPaymentCallbackView
                    )

urlpatterns = [
    path('stripe/checkout/', StripeCheckoutView.as_view(), name='stripe-checkout'),
    # path('paypal/checkout/', PayPalCheckoutView.as_view(), name='paypal-checkout'),
    path('telecom/pay/', TelecomPaymentView.as_view(), name='telecom-pay'),

    path('stripe/webhook/', StripeWebhookView.as_view(), name='stripe-webhook'),
    path('telecom/webhook/<str:provider>/', telecom_webhook, name='telecom-webhook'),

    path('telecom/webhook/', TelecomPaymentCallbackView.as_view()),
    path('kpay/webhook/', KPayPaymentCallbackView.as_view()),
    path('ayapay/webhook/', AyaPayPaymentCallbackView.as_view()),
    path('cbpay/webhook/', CBPayPaymentCallbackView.as_view()),

]
