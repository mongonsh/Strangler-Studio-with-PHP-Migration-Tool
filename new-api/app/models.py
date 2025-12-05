from pydantic import BaseModel, Field
from datetime import datetime
from enum import Enum


class StatusEnum(str, Enum):
    """Halloween-themed status values for Student Requests"""
    POSSESSED = "Possessed"
    BANISHED = "Banished"
    SUMMONED = "Summoned"
    PENDING = "Pending"


class PriorityEnum(str, Enum):
    """Priority levels for Student Requests"""
    CRITICAL = "Critical"
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"


class StudentRequest(BaseModel):
    """
    Represents a request submitted by a student.
    Conforms to the OpenAPI contract specification.
    """
    id: int = Field(..., ge=1, description="Unique identifier for the Student Request")
    student_name: str = Field(..., min_length=1, max_length=200, description="Full name of the student")
    school: str = Field(..., min_length=1, max_length=200, description="Name of the educational institution")
    status: StatusEnum = Field(..., description="Current state of the request (Halloween-themed)")
    created_at: datetime = Field(..., description="ISO 8601 timestamp of when the request was created")
    priority: PriorityEnum = Field(..., description="Urgency level of the request")
    notes: str = Field(default="", max_length=1000, description="Additional information or comments about the request")

    class Config:
        json_schema_extra = {
            "example": {
                "id": 1,
                "student_name": "Victor Frankenstein",
                "school": "Miskatonic University",
                "status": "Possessed",
                "created_at": "2024-10-31T23:59:59Z",
                "priority": "Critical",
                "notes": "Urgent reanimation assistance required"
            }
        }
