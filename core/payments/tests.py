from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status

class PaymentsTests(APITestCase):

    def test_stripe_checkout_session(self):
        url = reverse('stripe-checkout')  # make sure to set name='stripe-checkout' in urls.py
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('id', response.data) # type: ignore

    def test_paypal_create_payment(self):
        url = reverse('paypal-create-payment')  # name='paypal-create-payment'
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('approval_url', response.data) # type: ignore

    def test_telecom_callback(self):
        url = reverse('telecom-webhook')  # name='telecom-webhook'
        response = self.client.post(url, {'transaction_id': '12345', 'status': 'success'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'ok') # type: ignore
