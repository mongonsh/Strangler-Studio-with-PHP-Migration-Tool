#!/usr/bin/env python3
"""
Property-based test for API response completeness.

Feature: strangler-studio, Property 3: API response completeness

This test validates that for any Student Request object returned by the
New API Service (either from /requests list or /requests/{id}), the JSON
response contains all required fields: id, student_name, school, status,
created_at, priority, and notes.

**Validates: Requirements 3.4**
"""

import sys
import os

# Add parent directory to path to import app module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from hypothesis import given, settings, strategies as st
from fastapi.testclient import TestClient
from app.main import app
from app.data.seed_data import get_seed_data

# Initialize test client with startup/shutdown events
client = TestClient(app)

# Manually trigger startup to load seed data
with client:
    pass

# Get all valid IDs from seed data
seed_data = get_seed_data()
valid_ids = [request.id for request in seed_data]

# Define required fields according to Requirements 3.4
REQUIRED_FIELDS = [
    "id",
    "student_name",
    "school",
    "status",
    "created_at",
    "priority",
    "notes"
]


def verify_response_completeness(response_data: dict, source: str) -> None:
    """
    Verify that a response object contains all required fields.
    
    Args:
        response_data: The JSON response data to verify
        source: Description of where the data came from (for error messages)
    
    Raises:
        AssertionError: If any required field is missing
    """
    for field in REQUIRED_FIELDS:
        assert field in response_data, \
            f"Response from {source} missing required field '{field}'. " \
            f"Present fields: {list(response_data.keys())}"


@given(st.sampled_from(valid_ids))
@settings(max_examples=100)
def test_property_single_request_completeness(request_id: int):
    """
    Property 3a: API response completeness for single request endpoint
    
    For any valid Student Request ID, when fetching /requests/{id},
    the returned JSON object should contain all required fields:
    id, student_name, school, status, created_at, priority, and notes.
    """
    # Make GET request to /requests/{id}
    response = client.get(f"/requests/{request_id}")
    
    # Verify successful response
    assert response.status_code == 200, \
        f"Expected status 200 for ID {request_id}, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Property: The response must contain all required fields
    verify_response_completeness(data, f"/requests/{request_id}")


@settings(max_examples=100)
@given(st.just(None))  # Run 100 times with no variation
def test_property_list_requests_completeness(_):
    """
    Property 3b: API response completeness for list endpoint
    
    When fetching all Student Requests from /requests, each object
    in the returned array should contain all required fields:
    id, student_name, school, status, created_at, priority, and notes.
    """
    # Make GET request to /requests
    response = client.get("/requests")
    
    # Verify successful response
    assert response.status_code == 200, \
        f"Expected status 200, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Verify it's a list
    assert isinstance(data, list), \
        f"Expected list response, got {type(data)}"
    
    # Verify we have data
    assert len(data) > 0, \
        "Expected non-empty list of Student Requests"
    
    # Property: Each object in the list must contain all required fields
    for idx, request_obj in enumerate(data):
        verify_response_completeness(
            request_obj,
            f"/requests (item {idx}, id={request_obj.get('id', 'unknown')})"
        )


if __name__ == "__main__":
    print("=" * 70)
    print("Property-Based Test: API Response Completeness")
    print("=" * 70)
    print(f"\nRequired fields: {', '.join(REQUIRED_FIELDS)}")
    print(f"Testing with {len(valid_ids)} Student Requests from seed data")
    print(f"Running 100 iterations with Hypothesis...\n")
    
    failed = False
    
    # Test single request endpoint
    print("Testing /requests/{id} endpoint...")
    try:
        test_property_single_request_completeness()
        print("✓ Single request endpoint: All responses complete")
    except AssertionError as e:
        print(f"✗ Single request endpoint FAILED: {e}")
        failed = True
    except Exception as e:
        print(f"✗ Single request endpoint ERROR: {e}")
        import traceback
        traceback.print_exc()
        failed = True
    
    # Test list endpoint
    print("\nTesting /requests endpoint...")
    try:
        test_property_list_requests_completeness()
        print("✓ List endpoint: All responses complete")
    except AssertionError as e:
        print(f"✗ List endpoint FAILED: {e}")
        failed = True
    except Exception as e:
        print(f"✗ List endpoint ERROR: {e}")
        import traceback
        traceback.print_exc()
        failed = True
    
    # Final summary
    print("\n" + "=" * 70)
    if not failed:
        print("✓ PROPERTY TEST PASSED")
        print("=" * 70)
        print("\nProperty 3 holds: API responses are complete")
        print("All Student Request objects contain all required fields!")
    else:
        print("✗ PROPERTY TEST FAILED")
        print("=" * 70)
        sys.exit(1)
