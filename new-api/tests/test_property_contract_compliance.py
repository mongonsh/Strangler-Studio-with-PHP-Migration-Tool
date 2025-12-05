#!/usr/bin/env python3
"""
Property-based test for OpenAPI contract compliance.

Feature: strangler-studio, Property 4: OpenAPI contract compliance

This test validates that for any response from the New API Service endpoints,
the response body conforms to the corresponding schema defined in the OpenAPI
Contract specification.

**Validates: Requirements 3.5**
"""

import sys
import os
import yaml
import json

# Add parent directory to path to import app module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from hypothesis import given, settings, strategies as st
from fastapi.testclient import TestClient
from openapi_spec_validator import validate_spec
from openapi_spec_validator.validation.exceptions import OpenAPIValidationError
from app.main import app
from app.data.seed_data import get_seed_data

# Initialize test client
client = TestClient(app)

# Manually trigger startup to load seed data
with client:
    pass

# Load OpenAPI specification
OPENAPI_SPEC_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', '..', 'contracts', 'openapi.yaml')
)

with open(OPENAPI_SPEC_PATH, 'r') as f:
    openapi_spec = yaml.safe_load(f)

# Get all valid IDs from seed data
seed_data = get_seed_data()
valid_ids = [request.id for request in seed_data]


def validate_against_schema(data, schema, path=""):
    """
    Validate data against an OpenAPI schema definition.
    
    Args:
        data: The data to validate
        schema: The OpenAPI schema definition
        path: Current path in the data structure (for error messages)
    
    Raises:
        AssertionError: If validation fails
    """
    schema_type = schema.get('type')
    
    # Handle $ref references
    if '$ref' in schema:
        ref_path = schema['$ref']
        if ref_path.startswith('#/components/schemas/'):
            schema_name = ref_path.split('/')[-1]
            referenced_schema = openapi_spec['components']['schemas'][schema_name]
            validate_against_schema(data, referenced_schema, path)
            return
    
    # Validate type
    if schema_type == 'object':
        assert isinstance(data, dict), \
            f"At {path}: Expected object, got {type(data).__name__}"
        
        # Check required fields
        required_fields = schema.get('required', [])
        for field in required_fields:
            assert field in data, \
                f"At {path}: Missing required field '{field}'"
        
        # Validate properties
        properties = schema.get('properties', {})
        for field_name, field_value in data.items():
            if field_name in properties:
                field_schema = properties[field_name]
                validate_against_schema(
                    field_value,
                    field_schema,
                    f"{path}.{field_name}" if path else field_name
                )
    
    elif schema_type == 'array':
        assert isinstance(data, list), \
            f"At {path}: Expected array, got {type(data).__name__}"
        
        # Validate items
        items_schema = schema.get('items', {})
        for idx, item in enumerate(data):
            validate_against_schema(
                item,
                items_schema,
                f"{path}[{idx}]"
            )
    
    elif schema_type == 'string':
        assert isinstance(data, str), \
            f"At {path}: Expected string, got {type(data).__name__}"
        
        # Check enum values
        if 'enum' in schema:
            assert data in schema['enum'], \
                f"At {path}: Value '{data}' not in allowed enum values {schema['enum']}"
        
        # Check format
        if 'format' in schema:
            format_type = schema['format']
            if format_type == 'date-time':
                # Basic ISO 8601 validation
                assert 'T' in data or 't' in data, \
                    f"At {path}: Expected ISO 8601 date-time format, got '{data}'"
        
        # Check length constraints
        if 'minLength' in schema:
            assert len(data) >= schema['minLength'], \
                f"At {path}: String length {len(data)} < minimum {schema['minLength']}"
        
        if 'maxLength' in schema:
            assert len(data) <= schema['maxLength'], \
                f"At {path}: String length {len(data)} > maximum {schema['maxLength']}"
    
    elif schema_type == 'integer':
        assert isinstance(data, int) and not isinstance(data, bool), \
            f"At {path}: Expected integer, got {type(data).__name__}"
        
        # Check minimum
        if 'minimum' in schema:
            assert data >= schema['minimum'], \
                f"At {path}: Value {data} < minimum {schema['minimum']}"
    
    elif schema_type == 'number':
        assert isinstance(data, (int, float)) and not isinstance(data, bool), \
            f"At {path}: Expected number, got {type(data).__name__}"
    
    elif schema_type == 'boolean':
        assert isinstance(data, bool), \
            f"At {path}: Expected boolean, got {type(data).__name__}"


def validate_response_against_openapi(endpoint_path, method, status_code, response_data):
    """
    Validate a response against the OpenAPI specification.
    
    Args:
        endpoint_path: The API endpoint path (e.g., '/requests')
        method: HTTP method (e.g., 'get')
        status_code: HTTP status code (e.g., 200)
        response_data: The response data to validate
    
    Raises:
        AssertionError: If validation fails
    """
    # Get the path specification
    path_spec = openapi_spec['paths'].get(endpoint_path)
    assert path_spec is not None, \
        f"Endpoint {endpoint_path} not found in OpenAPI spec"
    
    # Get the method specification
    method_spec = path_spec.get(method.lower())
    assert method_spec is not None, \
        f"Method {method} not found for endpoint {endpoint_path} in OpenAPI spec"
    
    # Get the response specification
    responses = method_spec.get('responses', {})
    response_spec = responses.get(str(status_code))
    assert response_spec is not None, \
        f"Status code {status_code} not defined for {method} {endpoint_path} in OpenAPI spec"
    
    # Get the schema for the response
    content = response_spec.get('content', {})
    json_content = content.get('application/json')
    
    if json_content is None:
        # No schema defined, nothing to validate
        return
    
    schema = json_content.get('schema')
    if schema is None:
        # No schema defined, nothing to validate
        return
    
    # Validate the response data against the schema
    validate_against_schema(response_data, schema, "response")


@settings(max_examples=100)
@given(st.just(None))  # Run 100 times
def test_property_list_requests_contract_compliance(_):
    """
    Property 4a: OpenAPI contract compliance for /requests endpoint
    
    For any response from GET /requests, the response body should
    validate successfully against the schema defined in the OpenAPI
    Contract specification.
    """
    # Make GET request to /requests
    response = client.get("/requests")
    
    # Verify successful response
    assert response.status_code == 200, \
        f"Expected status 200, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Property: Response must conform to OpenAPI schema
    validate_response_against_openapi(
        endpoint_path='/requests',
        method='get',
        status_code=200,
        response_data=data
    )


@given(st.sampled_from(valid_ids))
@settings(max_examples=100)
def test_property_get_request_by_id_contract_compliance(request_id: int):
    """
    Property 4b: OpenAPI contract compliance for /requests/{id} endpoint
    
    For any valid Student Request ID, when fetching /requests/{id},
    the response body should validate successfully against the schema
    defined in the OpenAPI Contract specification.
    """
    # Make GET request to /requests/{id}
    response = client.get(f"/requests/{request_id}")
    
    # Verify successful response
    assert response.status_code == 200, \
        f"Expected status 200 for ID {request_id}, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Property: Response must conform to OpenAPI schema
    validate_response_against_openapi(
        endpoint_path='/requests/{id}',
        method='get',
        status_code=200,
        response_data=data
    )


@settings(max_examples=100)
@given(st.integers(min_value=1000, max_value=9999))  # IDs that don't exist
def test_property_not_found_contract_compliance(invalid_id: int):
    """
    Property 4c: OpenAPI contract compliance for 404 responses
    
    For any non-existent Student Request ID, when fetching /requests/{id},
    the 404 response should conform to the Error schema defined in the
    OpenAPI Contract specification.
    """
    # Skip if this ID happens to exist in seed data
    if invalid_id in valid_ids:
        return
    
    # Make GET request to /requests/{id} with non-existent ID
    response = client.get(f"/requests/{invalid_id}")
    
    # Verify 404 response
    assert response.status_code == 404, \
        f"Expected status 404 for non-existent ID {invalid_id}, got {response.status_code}"
    
    # Parse JSON response
    data = response.json()
    
    # Property: 404 response must conform to Error schema
    validate_response_against_openapi(
        endpoint_path='/requests/{id}',
        method='get',
        status_code=404,
        response_data=data
    )


if __name__ == "__main__":
    print("=" * 70)
    print("Property-Based Test: OpenAPI Contract Compliance")
    print("=" * 70)
    print(f"\nOpenAPI Spec: {OPENAPI_SPEC_PATH}")
    print(f"Testing with {len(valid_ids)} valid IDs from seed data")
    print(f"Running 100 iterations per property with Hypothesis...\n")
    
    # First, validate the OpenAPI spec itself
    print("Validating OpenAPI specification...")
    try:
        validate_spec(openapi_spec)
        print("✓ OpenAPI specification is valid\n")
    except OpenAPIValidationError as e:
        print(f"✗ OpenAPI specification is invalid: {e}")
        sys.exit(1)
    
    failed = False
    
    # Test list endpoint
    print("Testing GET /requests contract compliance...")
    try:
        test_property_list_requests_contract_compliance()
        print("✓ GET /requests: All responses conform to contract")
    except AssertionError as e:
        print(f"✗ GET /requests FAILED: {e}")
        failed = True
    except Exception as e:
        print(f"✗ GET /requests ERROR: {e}")
        import traceback
        traceback.print_exc()
        failed = True
    
    # Test single request endpoint
    print("\nTesting GET /requests/{id} contract compliance...")
    try:
        test_property_get_request_by_id_contract_compliance()
        print("✓ GET /requests/{id}: All responses conform to contract")
    except AssertionError as e:
        print(f"✗ GET /requests/{{id}} FAILED: {e}")
        failed = True
    except Exception as e:
        print(f"✗ GET /requests/{{id}} ERROR: {e}")
        import traceback
        traceback.print_exc()
        failed = True
    
    # Test 404 responses
    print("\nTesting 404 error response contract compliance...")
    try:
        test_property_not_found_contract_compliance()
        print("✓ 404 responses: All conform to Error schema")
    except AssertionError as e:
        print(f"✗ 404 responses FAILED: {e}")
        failed = True
    except Exception as e:
        print(f"✗ 404 responses ERROR: {e}")
        import traceback
        traceback.print_exc()
        failed = True
    
    # Final summary
    print("\n" + "=" * 70)
    if not failed:
        print("✓ PROPERTY TEST PASSED")
        print("=" * 70)
        print("\nProperty 4 holds: All API responses conform to OpenAPI contract")
        print("All 300+ iterations passed successfully!")
    else:
        print("✗ PROPERTY TEST FAILED")
        print("=" * 70)
        sys.exit(1)
