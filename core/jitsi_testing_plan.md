# Jitsi Meet Integration Testing Plan

## Overview

This document outlines the testing procedures for verifying the role-based access control implementation in the Jitsi Meet integration. The testing will ensure that:

1. Admin users have full host privileges
2. Instructor users have full host privileges
3. Student users have limited participant privileges
4. Security features work as expected

## Test Environment Setup

### Required Accounts

1. **Admin Account**
   - Role: admin
   - Permissions: Full access to all courses and live classes

2. **Instructor Account**
   - Role: instructor
   - Permissions: Access to courses they teach

3. **Student Account**
   - Role: student
   - Permissions: Access only to enrolled courses

### Required Data

1. **Course with Live Class**
   - Course with at least one live class
   - Admin/Instructor assigned to course
   - Student enrolled in course

## Test Cases

### Test Case 1: Admin Starting a Live Class

**Objective**: Verify that admin users can start live classes as hosts

**Preconditions**:
- Admin user account exists
- Course with live class exists
- Admin is assigned to the course

**Steps**:
1. Log in as admin user
2. Obtain JWT authentication token
3. Call `/api/classroom/live-classes/{id}/start/` endpoint
4. Verify response contains:
   - Valid room name
   - JWT token for Jitsi
   - `is_moderator: true`
   - Feature flags:
     - `lobby-mode.enabled: false`
     - `recording.enabled: true`

**Expected Result**: 
- HTTP 200 OK response
- Admin has full host privileges

### Test Case 2: Instructor Starting a Live Class

**Objective**: Verify that instructor users can start live classes as hosts

**Preconditions**:
- Instructor user account exists
- Course with live class exists
- Instructor is assigned to the course

**Steps**:
1. Log in as instructor user
2. Obtain JWT authentication token
3. Call `/api/classroom/live-classes/{id}/start/` endpoint
4. Verify response contains:
   - Valid room name
   - JWT token for Jitsi
   - `is_moderator: true`
   - Feature flags:
     - `lobby-mode.enabled: false`
     - `recording.enabled: true`

**Expected Result**: 
- HTTP 200 OK response
- Instructor has full host privileges

### Test Case 3: Student Joining a Live Class (Enrolled)

**Objective**: Verify that enrolled students can join live classes as participants

**Preconditions**:
- Student user account exists
- Course with live class exists
- Student is enrolled in the course

**Steps**:
1. Log in as student user
2. Obtain JWT authentication token
3. Call `/api/classroom/live-classes/{id}/join/` endpoint
4. Verify response contains:
   - Valid room name
   - JWT token for Jitsi
   - `is_moderator: false`
   - Feature flags:
     - `lobby-mode.enabled: true`
     - `recording.enabled: false`

**Expected Result**: 
- HTTP 200 OK response
- Student has participant privileges with lobby mode enabled

### Test Case 4: Student Joining a Live Class (Not Enrolled)

**Objective**: Verify that non-enrolled students cannot join live classes

**Preconditions**:
- Student user account exists
- Course with live class exists
- Student is NOT enrolled in the course

**Steps**:
1. Log in as student user
2. Obtain JWT authentication token
3. Call `/api/classroom/live-classes/{id}/join/` endpoint

**Expected Result**: 
- HTTP 403 Forbidden response
- Error message: "You do not have permission to perform this action."

### Test Case 5: Student Starting a Live Class

**Objective**: Verify that students cannot start live classes

**Preconditions**:
- Student user account exists
- Course with live class exists
- Student is enrolled in the course

**Steps**:
1. Log in as student user
2. Obtain JWT authentication token
3. Call `/api/classroom/live-classes/{id}/start/` endpoint

**Expected Result**: 
- HTTP 403 Forbidden response
- Error message: "You do not have permission to perform this action."

### Test Case 6: Anonymous User Access

**Objective**: Verify that anonymous users cannot access live class endpoints

**Preconditions**:
- Course with live class exists

**Steps**:
1. Call `/api/classroom/live-classes/{id}/start/` endpoint without authentication
2. Call `/api/classroom/live-classes/{id}/join/` endpoint without authentication

**Expected Result**: 
- HTTP 401 Unauthorized response for both endpoints
- Error message: "Authentication credentials were not provided."

### Test Case 7: Invalid Live Class ID

**Objective**: Verify that invalid live class IDs are handled properly

**Preconditions**:
- Admin, instructor, and student accounts exist

**Steps**:
1. Log in as admin user
2. Call `/api/classroom/live-classes/999999/start/` (invalid ID)
3. Log in as student user
4. Call `/api/classroom/live-classes/999999/join/` (invalid ID)

**Expected Result**: 
- HTTP 404 Not Found response for both endpoints
- Error message: "Not found."

## Security Testing

### Test Case 8: JWT Token Expiration

**Objective**: Verify that expired JWT tokens are rejected

**Preconditions**:
- Admin user account exists
- Expired JWT token

**Steps**:
1. Use expired JWT token
2. Call `/api/classroom/live-classes/{id}/start/` endpoint
3. Call `/api/classroom/live-classes/{id}/join/` endpoint

**Expected Result**: 
- HTTP 401 Unauthorized response for both endpoints
- Error message: "Token has expired."

### Test Case 9: Room Name Uniqueness

**Objective**: Verify that room names are unique and not guessable

**Preconditions**:
- Multiple live classes exist

**Steps**:
1. Create multiple live classes
2. Check room names in database
3. Verify room names follow pattern: `{course_id}-{live_class_id}-{random_string}`

**Expected Result**: 
- All room names are unique
- Room names contain random components
- No predictable patterns in room names

### Test Case 10: Feature Flag Enforcement

**Objective**: Verify that feature flags are properly enforced in Jitsi

**Preconditions**:
- Live class with different user roles

**Steps**:
1. Join meeting as student with lobby mode enabled
2. Verify student cannot bypass lobby
3. Join meeting as instructor/admin
4. Verify instructor/admin can disable lobby
5. Verify recording permissions are enforced

**Expected Result**: 
- Students wait in lobby until admitted
- Instructors can admit students from lobby
- Only hosts can record meetings

## Flutter Integration Testing

### Test Case 11: Flutter App Integration

**Objective**: Verify that Flutter app can properly integrate with the API

**Preconditions**:
- Flutter app with Jitsi Meet plugin
- All user accounts exist
- Course with live class exists

**Steps**:
1. Log in to Flutter app as admin
2. Start live class through app
3. Verify Jitsi meeting starts with host privileges
4. Log in to Flutter app as student
5. Join live class through app
6. Verify Jitsi meeting joins with participant privileges
7. Test lobby functionality
8. Test recording functionality

**Expected Result**: 
- Flutter app successfully integrates with API
- Correct permissions applied based on user role
- Jitsi Meet functions as expected for each role

## Test Data Cleanup

After testing, ensure all test data is properly cleaned up:
- Delete test live classes
- Remove test enrollments
- Reset any modified user accounts

## Test Results Documentation

Record all test results including:
- Test case ID and description
- User role used for testing
- Actual vs expected results
- Screenshots if applicable
- Any issues or bugs discovered

## Automated Testing

Consider implementing automated tests for:
- API endpoint responses
- Role-based access control
- JWT token validation
- Feature flag enforcement

## Conclusion

This testing plan ensures comprehensive coverage of the Jitsi Meet integration with role-based access control. All user roles are tested for both positive and negative scenarios to ensure security and proper functionality.