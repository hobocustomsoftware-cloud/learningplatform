# utils/agora.py
import time
from django.conf import settings
from agora_token_builder import RtcTokenBuilder

# Agora role constants
AGORA_ROLE_HOST = 1        # Publisher
AGORA_ROLE_AUDIENCE = 2    # Subscriber

def build_agora_token(channel: str, uid: int, is_host: bool, ttl_seconds: int = 3600) -> str:
    """
    Generate an RTC token for Agora.
    - channel: unique channel name
    - uid:     int user id (<= 2^32 - 1)
    - is_host: host => Publisher, else Audience
    - ttl:     token lifetime seconds
    """
    if not settings.AGORA_APP_ID or not settings.AGORA_APP_CERT:
        raise RuntimeError("Missing AGORA_APP_ID or AGORA_APP_CERT in settings.")

    role = AGORA_ROLE_HOST if is_host else AGORA_ROLE_AUDIENCE
    expire_ts = int(time.time()) + int(ttl_seconds)

    return RtcTokenBuilder.buildTokenWithUid(
        appId=settings.AGORA_APP_ID,
        appCertificate=settings.AGORA_APP_CERT,
        channelName=channel,
        uid=uid,
        role=role,
        privilegeExpiredTs=expire_ts,
    )
