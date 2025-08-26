# classroom/utils.py
import jwt
import datetime
from django.conf import settings

def generate_jitsi_token(user, room_name, is_moderator=False):
    """
    Generate a JWT token for Jitsi meetings with appropriate permissions based on user role.
    
    Args:
        user: The user object for whom the token is generated
        room_name: The name of the Jitsi room
        is_moderator: Boolean indicating if the user is a moderator (instructor/admin)
        
    Returns:
        str: JWT token string
    """
    # Get Jitsi configuration from settings
    jitsi_app_id = getattr(settings, 'JITSI_APP_ID', None)
    jitsi_app_secret = getattr(settings, 'JITSI_APP_SECRET', None)
    
    if not jitsi_app_id or not jitsi_app_secret:
        raise ValueError("JITSI_APP_ID and JITSI_APP_SECRET must be set in settings")
    
    # Set token expiration (1 hour)
    exp = datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    
    # Create payload with user context and room information
    payload = {
        "iss": jitsi_app_id,
        "sub": "jitsi",
        "aud": "jitsi",
        "exp": exp.timestamp(),
        "room": room_name,
        "context": {
            "user": {
                "id": str(user.id),
                "name": user.get_full_name() or user.username,
                "email": user.email,
                "role": "moderator" if is_moderator else "participant"
            },
            "features": {
                "lobby": not is_moderator,  # Lobby enabled for participants only
                "recording": is_moderator,  # Recording enabled for moderators only
                "prejoin": True  # Pre-join page enabled for all
            }
        }
    }
    
    # Generate JWT token with HS256 algorithm
    token = jwt.encode(payload, jitsi_app_secret, algorithm='HS256')
    return token