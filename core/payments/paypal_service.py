# import paypalrestsdk
# from django.conf import settings
# from payments.models import Payment

# paypalrestsdk.configure({
#     "mode": settings.PAYPAL_MODE,
#     "client_id": settings.PAYPAL_CLIENT_ID,
#     "client_secret": settings.PAYPAL_CLIENT_SECRET
# })

# def create_paypal_payment(user, course, return_url, cancel_url):
#     payment = paypalrestsdk.Payment({
#         "intent": "sale",
#         "payer": {"payment_method": "paypal"},
#         "redirect_urls": {"return_url": return_url, "cancel_url": cancel_url},
#         "transactions": [{
#             "item_list": {"items":[{"name":course.title,"sku":str(course.id),"price":str(course.price),"currency":"USD","quantity":1}]},
#             "amount":{"total":str(course.price),"currency":"USD"},
#             "description": f"Payment for {course.title}"
#         }]
#     })

#     if payment.create():
#         Payment.objects.create(
#             user=user,
#             course=course,
#             amount=course.price,
#             provider='paypal',
#             provider_payment_id=payment.id,
#             status='pending'
#         )
#         for link in payment.links:
#             if link.rel == "approval_url":
#                 return str(link.href)
#     else:
#         return None
