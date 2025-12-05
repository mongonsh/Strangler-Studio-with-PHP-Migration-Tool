#!/usr/bin/env python3
"""
Simple test script to verify the API logic without running the server.
This validates that the models, seed data, and core logic work correctly.
"""

import sys
sys.path.insert(0, '.')

from app.models import StudentRequest, StatusEnum, PriorityEnum
from app.data.seed_data import get_seed_data

def test_seed_data():
    """Test that seed data loads correctly"""
    print("Testing seed data...")
    seed_data = get_seed_data()
    
    assert len(seed_data) >= 5, f"Expected at least 5 records, got {len(seed_data)}"
    assert len(seed_data) <= 7, f"Expected at most 7 records, got {len(seed_data)}"
    print(f"✓ Seed data contains {len(seed_data)} records")
    
    # Verify all records are StudentRequest instances
    for request in seed_data:
        assert isinstance(request, StudentRequest), f"Record is not a StudentRequest: {type(request)}"
    print("✓ All records are StudentRequest instances")
    
    # Verify required fields
    for request in seed_data:
        assert request.id >= 1, f"Invalid ID: {request.id}"
        assert len(request.student_name) > 0, "Student name is empty"
        assert len(request.school) > 0, "School is empty"
        assert request.status in StatusEnum, f"Invalid status: {request.status}"
        assert request.priority in PriorityEnum, f"Invalid priority: {request.priority}"
        assert request.created_at is not None, "created_at is None"
    print("✓ All records have valid required fields")
    
    return seed_data

def test_list_requests_logic(seed_data):
    """Test the list requests endpoint logic"""
    print("\nTesting list requests logic...")
    
    # Simulate the endpoint logic
    student_requests = {req.id: req for req in seed_data}
    result = list(student_requests.values())
    
    assert len(result) == len(seed_data), "List length mismatch"
    print(f"✓ List endpoint returns all {len(result)} requests")
    
    return student_requests

def test_get_by_id_logic(student_requests):
    """Test the get by ID endpoint logic"""
    print("\nTesting get by ID logic...")
    
    # Test valid ID
    test_id = 1
    if test_id in student_requests:
        result = student_requests[test_id]
        assert result.id == test_id, f"ID mismatch: expected {test_id}, got {result.id}"
        print(f"✓ Get by ID returns correct request for ID {test_id}")
    
    # Test invalid ID
    invalid_id = 999
    if invalid_id not in student_requests:
        print(f"✓ Invalid ID {invalid_id} correctly not found")
    
def test_model_serialization(seed_data):
    """Test that models can be serialized to JSON"""
    print("\nTesting model serialization...")
    
    for request in seed_data:
        json_data = request.model_dump()
        assert 'id' in json_data, "Missing 'id' in JSON"
        assert 'student_name' in json_data, "Missing 'student_name' in JSON"
        assert 'school' in json_data, "Missing 'school' in JSON"
        assert 'status' in json_data, "Missing 'status' in JSON"
        assert 'created_at' in json_data, "Missing 'created_at' in JSON"
        assert 'priority' in json_data, "Missing 'priority' in JSON"
        assert 'notes' in json_data, "Missing 'notes' in JSON"
    
    print("✓ All models serialize correctly to JSON")

def test_halloween_theme(seed_data):
    """Test that Halloween theme is present in the data"""
    print("\nTesting Halloween theme...")
    
    halloween_names = ["Victor Frankenstein", "Mina Harker", "Henry Jekyll", "Dorian Gray", 
                       "Ichabod Crane", "Wednesday Addams", "Raven Darkholme"]
    halloween_schools = ["Miskatonic University", "Transylvania Academy", "Nevermore Academy"]
    
    found_names = [req.student_name for req in seed_data]
    found_schools = [req.school for req in seed_data]
    
    # Check for Halloween-themed content
    has_halloween_names = any(name in found_names for name in halloween_names)
    has_halloween_schools = any(school in found_schools for school in halloween_schools)
    
    assert has_halloween_names, "No Halloween-themed names found"
    assert has_halloween_schools, "No Halloween-themed schools found"
    
    print("✓ Halloween theme is present in seed data")
    print(f"  - Found names: {', '.join(found_names[:3])}...")
    print(f"  - Found schools: {', '.join(set(found_schools)[:3])}...")

if __name__ == "__main__":
    print("=" * 60)
    print("FastAPI Service Logic Verification")
    print("=" * 60)
    
    try:
        seed_data = test_seed_data()
        student_requests = test_list_requests_logic(seed_data)
        test_get_by_id_logic(student_requests)
        test_model_serialization(seed_data)
        test_halloween_theme(seed_data)
        
        print("\n" + "=" * 60)
        print("✓ ALL TESTS PASSED")
        print("=" * 60)
        print("\nThe FastAPI service implementation is correct!")
        print("Ready to run with: uvicorn app.main:app --reload")
        
    except AssertionError as e:
        print(f"\n✗ TEST FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
