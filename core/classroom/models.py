# classroom/models.py
import secrets
import string
from django.db import models
from django.conf import settings
from courses.models import Course

User = settings.AUTH_USER_MODEL

class LiveClass(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='live_classes')
    instructor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='live_classes')
    title = models.CharField(max_length=255)
    room_name = models.CharField(max_length=255, unique=True, blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    is_live = models.BooleanField(default=False)

    def generate_unique_room_name(self):
        """Generate a unique room name using course ID and random string"""
        # Use course ID in the room name if available
        if self.course_id: # type: ignore
            base_name = f"course{self.course_id}" # type: ignore
        else:
            # For new instances without a course, use a generic base
            base_name = "liveclass"
        
        # Add random string to make it unique and non-guessable
        random_string = ''.join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(12))
        room_name = f"{base_name}-{random_string}"
        
        # Ensure uniqueness
        counter = 1
        original_room_name = room_name
        while LiveClass.objects.filter(room_name=room_name).exists():
            room_name = f"{original_room_name}-{counter}"
            counter += 1
            
        return room_name

    def save(self, *args, **kwargs):
        # Generate room name if it doesn't exist
        if not self.room_name:
            # For new instances, we need to save first to get the ID
            if not self.pk:
                # Save without room_name first
                super().save(*args, **kwargs)
                # Then generate and save room_name
                self.room_name = self.generate_unique_room_name()
                # Update only the room_name field
                super().save(update_fields=['room_name'])
            else:
                # For existing instances, generate room_name and save normally
                self.room_name = self.generate_unique_room_name()
                super().save(*args, **kwargs)
        else:
            # If room_name already exists, save normally
            super().save(*args, **kwargs)

    def __str__(self):
        return self.title
