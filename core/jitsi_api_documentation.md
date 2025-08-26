# Jitsi Meet API Documentation for Flutter Integration

## Overview

This document provides detailed information about the Jitsi Meet integration API endpoints for Flutter application integration. The API supports role-based access control where:

- **Admin/Instructor**: Can start meetings as hosts with full permissions
- **Student**: Can join meetings as participants with limited permissions

## Base URL

```
http://localhost:8000/api/classroom/
```

## Authentication

All API endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### 1. Start a Live Class (Instructor/Admin only)

**Endpoint**: `POST /live-classes/{id}/start/`

**Description**: Starts a live class session and returns Jitsi meeting configuration for the host.

**Permissions**: 
- User must be authenticated
- User role must be "instructor" or "admin"
- User must be the instructor of the course

**Request**:
```http
POST /api/classroom/live-classes/123/start/
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Response**:
```json
{
  "room": "course123-live456-abc123def",
  "subject": "Introduction to Python Programming",
  "jitsi_server_url": "https://meet.jit.si",
  "jitsi_domain": "meet.jit.si",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "feature_flags": {
    "lobby-mode.enabled": true,
    "prejoinpage.enabled": true,
    "recording.enabled": true
  },
  "is_moderator": true
}
```

**Response Fields**:
- `room`: Unique room name for the Jitsi meeting
- `subject`: Title of the live class
- `jitsi_server_url`: Jitsi server URL
- `jitsi_domain`: Jitsi domain
- `token`: JWT token for secure Jitsi authentication
- `feature_flags`: Configuration flags for Jitsi features
- `is_moderator`: Indicates if the user is a moderator (host)

### 2. Join a Live Class (All enrolled users)

**Endpoint**: `POST /live-classes/{id}/join/`

**Description**: Allows enrolled users to join a live class session and returns Jitsi meeting configuration.

**Permissions**: 
- User must be authenticated
- Students must be enrolled in the course
- Instructors/Admins can join any course they have access to

**Request**:
```http
POST /api/classroom/live-classes/123/join/
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Response (Student)**:
```json
{
  "room": "course123-live456-abc123def",
  "subject": "Introduction to Python Programming",
  "jitsi_server_url": "https://meet.jit.si",
  "jitsi_domain": "meet.jit.si",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "feature_flags": {
    "lobby-mode.enabled": true,
    "prejoinpage.enabled": true,
    "recording.enabled": false
  },
  "is_moderator": false
}
```

**Response (Instructor/Admin)**:
```json
{
  "room": "course123-live456-abc123def",
  "subject": "Introduction to Python Programming",
  "jitsi_server_url": "https://meet.jit.si",
  "jitsi_domain": "meet.jit.si",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "feature_flags": {
    "lobby-mode.enabled": false,
    "prejoinpage.enabled": true,
    "recording.enabled": true
  },
  "is_moderator": true
}
```

## Feature Flags Explanation

| Flag | Description | Student | Instructor/Admin |
|------|-------------|---------|------------------|
| `lobby-mode.enabled` | Enables lobby mode where participants wait for host approval | `true` | `false` |
| `prejoinpage.enabled` | Shows pre-join page before entering meeting | `true` | `true` |
| `recording.enabled` | Allows recording of the meeting | `false` | `true` |

## Flutter Integration Guide

### 1. Install Jitsi Meet Plugin

Add the Jitsi Meet plugin to your Flutter project:

```yaml
dependencies:
  jitsi_meet: ^4.0.0
```

### 2. Join Meeting Function

```dart
import 'package:jitsi_meet/jitsi_meet.dart';

Future<void> joinMeeting(Map<String, dynamic> meetingData) async {
  try {
    // Configure Jitsi options
    var options = JitsiMeetingOptions()
      ..room = meetingData['room']
      ..subject = meetingData['subject']
      ..serverURL = meetingData['jitsi_server_url']
      ..token = meetingData['token']
      ..audioMuted = true
      ..videoMuted = true
      ..featureFlags = {
        'lobby-mode.enabled': meetingData['feature_flags']['lobby-mode.enabled'],
        'prejoinpage.enabled': meetingData['feature_flags']['prejoinpage.enabled'],
        'recording.enabled': meetingData['feature_flags']['recording.enabled'],
      };
    
    // Join the meeting
    await JitsiMeet.joinMeeting(options);
  } catch (error) {
    print("Error joining meeting: $error");
  }
}
```

### 3. Start Meeting Function

```dart
Future<void> startMeeting(Map<String, dynamic> meetingData) async {
  try {
    // Configure Jitsi options for host
    var options = JitsiMeetingOptions()
      ..room = meetingData['room']
      ..subject = meetingData['subject']
      ..serverURL = meetingData['jitsi_server_url']
      ..token = meetingData['token']
      ..audioMuted = false
      ..videoMuted = false
      ..userDisplayName = "Host"
      ..featureFlags = {
        'lobby-mode.enabled': meetingData['feature_flags']['lobby-mode.enabled'],
        'prejoinpage.enabled': meetingData['feature_flags']['prejoinpage.enabled'],
        'recording.enabled': meetingData['feature_flags']['recording.enabled'],
      };
    
    // Start the meeting
    await JitsiMeet.joinMeeting(options);
  } catch (error) {
    print("Error starting meeting: $error");
  }
}
```

## Error Handling

### Common HTTP Status Codes

| Status Code | Description | Solution |
|-------------|-------------|----------|
| 401 | Unauthorized | Check JWT token validity |
| 403 | Forbidden | Check user permissions and course enrollment |
| 404 | Not Found | Verify live class ID exists |
| 400 | Bad Request | Check request parameters |

### Example Error Response

```json
{
  "detail": "You do not have permission to perform this action."
}
```

## Security Considerations

1. **JWT Tokens**: All Jitsi meeting tokens are short-lived (1 hour) for security
2. **Role-Based Access**: Students cannot access instructor-only features
3. **Lobby Mode**: Students must wait in lobby until host admits them
4. **Recording Permissions**: Only instructors/admins can record meetings
5. **Unique Room Names**: Each meeting has a unique, non-guessable room name

## Testing Different User Roles

### Instructor/Admin Testing
1. Create a live class
2. Start the meeting using `/start` endpoint
3. Verify moderator privileges (can record, no lobby)
4. Test admitting participants from lobby

### Student Testing
1. Enroll in a course with a live class
2. Join the meeting using `/join` endpoint
3. Verify participant privileges (cannot record, in lobby)
4. Test waiting for host admission

## Sample Implementation Flow

### For Instructors/Admins:
1. User logs in and gets JWT token
2. Instructor creates a live class via API
3. Instructor calls `/start` endpoint to get meeting configuration
4. Flutter app uses configuration to start Jitsi meeting
5. Instructor has full host privileges

### For Students:
1. User logs in and gets JWT token
2. Student enrolls in course with live class
3. Student calls `/join` endpoint to get meeting configuration
4. Flutter app uses configuration to join Jitsi meeting
5. Student waits in lobby until admitted by host

This implementation ensures a secure, role-based Jitsi Meet experience similar to Udemy's live class functionality.