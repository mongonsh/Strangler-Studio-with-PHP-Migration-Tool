from datetime import datetime
from app.models import StudentRequest, StatusEnum, PriorityEnum


def get_seed_data() -> list[StudentRequest]:
    """
    Returns deterministic Halloween-themed Student Request seed data.
    This data is used to populate the API with consistent, demo-ready content.
    """
    return [
        StudentRequest(
            id=1,
            student_name="Victor Frankenstein",
            school="Miskatonic University",
            status=StatusEnum.POSSESSED,
            created_at=datetime(2024, 10, 31, 23, 59, 59),
            priority=PriorityEnum.CRITICAL,
            notes="Urgent reanimation assistance required for final thesis project"
        ),
        StudentRequest(
            id=2,
            student_name="Mina Harker",
            school="Transylvania Academy",
            status=StatusEnum.SUMMONED,
            created_at=datetime(2024, 10, 30, 18, 30, 0),
            priority=PriorityEnum.HIGH,
            notes="Vampire literature research - need access to restricted archives"
        ),
        StudentRequest(
            id=3,
            student_name="Henry Jekyll",
            school="London Medical College",
            status=StatusEnum.PENDING,
            created_at=datetime(2024, 10, 29, 14, 15, 30),
            priority=PriorityEnum.MEDIUM,
            notes="Chemistry lab equipment request for transformation experiments"
        ),
        StudentRequest(
            id=4,
            student_name="Dorian Gray",
            school="Oxford Academy of Arts",
            status=StatusEnum.BANISHED,
            created_at=datetime(2024, 10, 28, 9, 45, 0),
            priority=PriorityEnum.LOW,
            notes="Portrait restoration services - urgent but confidential"
        ),
        StudentRequest(
            id=5,
            student_name="Ichabod Crane",
            school="Sleepy Hollow Institute",
            status=StatusEnum.POSSESSED,
            created_at=datetime(2024, 10, 27, 22, 0, 0),
            priority=PriorityEnum.HIGH,
            notes="Requesting transfer due to headless horseman incidents"
        ),
        StudentRequest(
            id=6,
            student_name="Wednesday Addams",
            school="Nevermore Academy",
            status=StatusEnum.SUMMONED,
            created_at=datetime(2024, 10, 26, 13, 13, 13),
            priority=PriorityEnum.MEDIUM,
            notes="Advanced torture techniques seminar enrollment"
        ),
        StudentRequest(
            id=7,
            student_name="Raven Darkholme",
            school="Xavier's School for Gifted Youngsters",
            status=StatusEnum.PENDING,
            created_at=datetime(2024, 10, 25, 16, 20, 0),
            priority=PriorityEnum.CRITICAL,
            notes="Shape-shifting ethics course - mandatory for graduation"
        ),
    ]
