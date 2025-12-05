#!/usr/bin/env python3
"""
Property-based test for API ID lookup correctness.

Feature: strangler-studio, Property 2: API endpoint ID lookup correctness

This test validates that for any valid Student Request ID in the seed data,
when a GET request is made to /requests/{id}, the returned JSON object
has an 'id' field matching the requested ID.

**Validates: Requirements 3.3**
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
# (TestClient doesn't automatically trigger startup events in some versions)
with client:
    pass

# Get all valid IDs from seed data
seed_data = get_seed_data()
valid_ids = [request.id for request in seed_data]


@given(st.sampled_from(valid_ids))
@settings(max_examples=100)
def test_property_api_id_lookup_correctness(request_id: int):
    """
    Property 2: API endpoint ID lookup correctness
    
    For any valid Student Request ID in the seed data, when a GET request
    is made to /requests/{id}, the returned JSON object should have an
    'id' field matching the requested ID.
    
    This property ensures that the API correctly retrieves and returns
    the requested Student Request without mixing up IDs.
    """
    # Make GET request to /requests/{id}
    response = client.get(f"/requests/{request_id}")
    
    # Verify successful response
    assert response.status_code == 200, \
        f"Expected status 200 for ID {request_id}, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Property: The returned object's ID must match the requested ID
    assert "id" in data, \
        f"Response for ID {request_id} missing 'id' field"
    
    assert data["id"] == request_id, \
        f"ID mismatch: requested {request_id}, got {data['id']}"


if __name__ == "__main__":
    print("=" * 70)
    print("Property-Based Test: API ID Lookup Correctness")
    print("=" * 70)
    print(f"\nTesting with {len(valid_ids)} valid IDs from seed data: {valid_ids}")
    print(f"Running 100 iterations with Hypothesis...\n")
    
    try:
        test_property_api_id_lookup_correctness()
        print("\n" + "=" * 70)
        print("✓ PROPERTY TEST PASSED")
        print("=" * 70)
        print("\nProperty 2 holds: API endpoint ID lookup is correct")
        print("All 100 iterations passed successfully!")
        
    except AssertionError as e:
        print(f"\n✗ PROPERTY TEST FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
