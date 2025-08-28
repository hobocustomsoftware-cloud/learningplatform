# utils/agora.py
from datetime import datetime, timedelta
from django.conf import settings

# Try multiple import paths so it works across variants/forks
RtcTokenBuilder = None
RtcRole = None # type: ignore
_import_errors = []

try:
    # Official package layout (agora-token-builder)
    from agora_token_builder import RtcTokenBuilder, RtcRole # type: ignore
except Exception as e:
    _import_errors.append(e)
    try:
        # Some forks expose a submodule
        from agora_token_builder.RtcTokenBuilder import RtcTokenBuilder  # type: ignore
        # Fallback role enum if not provided by fork
        class RtcRole:  # type: ignore
            PUBLISHER = 1
            SUBSCRIBER = 2
    except Exception as e2:
        _import_errors.append(e2)

if RtcTokenBuilder is None:
    raise ImportError(
        "Cannot import RtcTokenBuilder. Make sure 'agora-token-builder' is installed.\n"
        "  pip install --upgrade agora-token-builder\n"
        f"Import attempts failed: {_import_errors}"
    )

def _build_with_uid(app_id: str, app_cert: str, channel: str, uid: int, role: int, expire_ts: int) -> str:
    """
    Call the correct builder method name depending on the installed package.
    """
    # Official API (camelCase)
    if hasattr(RtcTokenBuilder, "buildTokenWithUid"):
        return RtcTokenBuilder.buildTokenWithUid(app_id, app_cert, channel, uid, role, expire_ts) # type: ignore

    # Some forks use snake_case with positional args
    if hasattr(RtcTokenBuilder, "build_token_with_uid"):
        try:
            return RtcTokenBuilder.build_token_with_uid(app_id, app_cert, channel, uid, role, expire_ts)  # type: ignore
        except TypeError:
            # Some require named args
            return RtcTokenBuilder.build_token_with_uid(  # type: ignore
                app_id=app_id,
                app_certificate=app_cert,
                channel_name=channel,
                uid=uid,
                role=role,
                privilege_expired_ts=expire_ts,
            )

    raise AttributeError(
        "RtcTokenBuilder has neither 'buildTokenWithUid' nor 'build_token_with_uid'. "
        "Check your 'agora-token-builder' package version."
    )

def build_agora_token(channel_name: str, uid: int, is_host: bool) -> str:
    """
    Unified token builder your views can call.
    - channel_name: str
    - uid: int
    - is_host: True => PUBLISHER(1), False => SUBSCRIBER(2)
    """
    app_id = getattr(settings, "AGORA_APP_ID", None)
    app_cert = getattr(settings, "AGORA_APP_CERTIFICATE", None)
    if not app_id or not app_cert:
        raise RuntimeError("AGORA_APP_ID / AGORA_APP_CERTIFICATE must be set in settings.py")

    expire_seconds = int(getattr(settings, "AGORA_TOKEN_EXP_SECONDS", 3600))
    role = getattr(RtcRole, "PUBLISHER", 1) if is_host else getattr(RtcRole, "SUBSCRIBER", 2)

    privilege_expired_ts = int((datetime.utcnow() + timedelta(seconds=expire_seconds)).timestamp())
    return _build_with_uid(app_id, app_cert, channel_name, uid, role, privilege_expired_ts)
