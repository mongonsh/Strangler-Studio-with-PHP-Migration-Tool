# Testing Standards

## Overview

This document defines testing requirements and patterns for the Strangler Studio project. Comprehensive testing ensures correctness, prevents regressions, and provides confidence in the migration from legacy to modern architecture.

## Testing Philosophy

We employ a dual testing approach:
- **Unit tests** verify specific examples, edge cases, and integration points
- **Property-based tests** verify universal properties across all inputs

Both types of tests are complementary and essential for comprehensive coverage.

## Coverage Requirements

### Minimum Coverage Targets

- **API Service (Python)**: 80% code coverage minimum
- **Legacy PHP App**: 60% coverage minimum (focus on business logic)
- **Critical paths**: 100% coverage required

### Coverage Tools

**Python:**
```bash
pytest --cov=app --cov-report=html --cov-report=term
```

**PHP:**
```bash
phpunit --coverage-html coverage/
```

## Unit Testing Standards

### Test Structure

Follow the Arrange-Act-Assert (AAA) pattern:

```python
def test_get_request_by_id():
    # Arrange
    request_id = 1
    
    # Act
    result = get_request_by_id(request_id)
    
    # Assert
    assert result.id == request_id
    assert result.student_name is not None
```

### Test Naming

- Use descriptive names that explain what is being tested
- Format: `test_<function>_<scenario>_<expected_result>`
- Examples:
  - `test_get_request_returns_correct_object`
  - `test_get_request_with_invalid_id_returns_404`
  - `test_api_client_falls_back_on_failure`

### What to Unit Test

**Required:**
- All public API endpoints
- Business logic functions
- Data validation
- Error handling paths
- Edge cases (empty inputs, boundary values, null values)
- Integration points between components

**Not Required:**
- Simple getters/setters
- Framework boilerplate
- Third-party library code

### Test Organization

**Python:**
- Place tests in `tests/` directory
- Mirror source structure: `app/models.py` → `tests/test_models.py`
- Use pytest fixtures for common setup

**PHP:**
- Place tests alongside source files or in `tests/` directory
- Use PHPUnit for test execution

### Mocking Guidelines

- Mock external dependencies (HTTP calls, databases, file system)
- Do NOT mock the code you're testing
- Use dependency injection to make mocking easier
- Keep mocks simple and focused

## Property-Based Testing Standards

### Overview

Property-based testing verifies that universal properties hold across all inputs. We use **Hypothesis** for Python and **bash-based property testing** for integration tests.

### Configuration

- **Minimum iterations**: 100 per property test
- **Deterministic seed**: Use fixed seed for reproducibility
- **Timeout**: 60 seconds per property test

### Property Test Structure

Each property test must:
1. Generate random inputs within valid domain
2. Execute the operation
3. Assert the property holds
4. Be tagged with design document reference

### Tagging Format

Every property-based test MUST include a comment tag:

```python
# Feature: strangler-studio, Property 2: API endpoint ID lookup correctness
# Validates: Requirements 3.3
```

Format: `# Feature: {feature_name}, Property {number}: {property_text}`

### Property Test Examples

**Property 1: Gateway Routing Correctness**
```bash
# Feature: strangler-studio, Property 1: Gateway routing correctness
# Validates: Requirements 1.1, 2.1, 3.1

for i in {1..100}; do
    # Generate random path
    if [ $((RANDOM % 2)) -eq 0 ]; then
        path="/api/requests"
        expected_backend="new-api"
    else
        path="/requests"
        expected_backend="legacy-php"
    fi
    
    # Test routing
    response=$(curl -s -w "%{http_code}" "http://localhost$path")
    # Assert correct backend handled request
done
```

**Property 2: API ID Lookup Correctness**
```python
# Feature: strangler-studio, Property 2: API endpoint ID lookup correctness
# Validates: Requirements 3.3

from hypothesis import given, strategies as st

@given(st.integers(min_value=1, max_value=7))
def test_api_returns_matching_id(request_id):
    """For any valid ID, returned object should have matching ID field."""
    response = client.get(f"/requests/{request_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == request_id
```

### Common Property Patterns

**1. Invariants**
Properties that remain constant despite transformations:
```python
# Length invariant
assert len(filter_requests(requests)) <= len(requests)
```

**2. Round Trip Properties**
Combining operation with its inverse returns to original:
```python
# Serialization round trip
assert deserialize(serialize(obj)) == obj
```

**3. Idempotence**
Doing operation twice equals doing it once:
```python
# Idempotent operation
assert normalize(normalize(data)) == normalize(data)
```

**4. Metamorphic Properties**
Relationships between inputs and outputs:
```python
# Filtering reduces or maintains size
assert len(filter_data(data)) <= len(data)
```

**5. Model-Based Testing**
Compare optimized implementation to simple reference:
```python
# Compare to reference implementation
assert fast_sort(data) == simple_sort(data)
```

### Generator Guidelines

Write smart generators that constrain to valid input space:

```python
from hypothesis import strategies as st

# Good: Constrained to valid domain
valid_ids = st.integers(min_value=1, max_value=7)

# Good: Composite strategy
student_request = st.builds(
    StudentRequest,
    id=st.integers(min_value=1),
    student_name=st.text(min_size=1, max_size=100),
    school=st.text(min_size=1, max_size=100),
    status=st.sampled_from(["Possessed", "Banished", "Summoned", "Pending"]),
    priority=st.sampled_from(["Critical", "High", "Medium", "Low"])
)
```

### Handling Failures

When a property test fails:

1. **Reproduce**: Hypothesis provides a minimal failing example
2. **Triage**: Determine if it's a bug, test issue, or spec problem
3. **Fix**: Update code, test, or specification as appropriate
4. **Verify**: Re-run with same seed to confirm fix

Example failure output:
```
Falsifying example: test_api_returns_matching_id(request_id=999)
AssertionError: Expected 200, got 404
```

## Contract Testing Standards

### OpenAPI Validation

All API responses must validate against the OpenAPI contract:

```python
from openapi_spec_validator import validate_spec
from openapi_spec_validator.validation.exceptions import OpenAPIValidationError

def test_openapi_contract_valid():
    """Validate OpenAPI spec is syntactically correct."""
    with open("contracts/openapi.yaml") as f:
        spec = yaml.safe_load(f)
    validate_spec(spec)  # Raises exception if invalid
```

### Response Schema Validation

```python
def test_response_matches_schema():
    """Verify API response matches OpenAPI schema."""
    response = client.get("/requests")
    assert response.status_code == 200
    
    # Validate against schema
    validate_response(response.json(), schema="StudentRequestList")
```

## Golden Testing Standards

### Purpose

Golden tests ensure migration correctness by comparing legacy and new implementations.

### Allowed Differences

Document explicitly what differences are acceptable:

```python
ALLOWED_DIFFERENCES = {
    "date_format": "ISO 8601 vs Y-m-d H:i:s",
    "field_casing": "snake_case vs camelCase",
    "status_labels": "Active → Summoned, Pending → Pending"
}
```

### Normalization

Normalize data before comparison:

```python
def normalize_date(date_str):
    """Convert any date format to ISO 8601."""
    return datetime.fromisoformat(date_str).isoformat()

def normalize_status(status):
    """Map themed status to semantic equivalent."""
    mapping = {
        "Active": "Summoned",
        "Inactive": "Banished",
        "Pending": "Pending"
    }
    return mapping.get(status, status)
```

### Assertion

```python
def test_legacy_new_equivalence():
    """Verify legacy and new data are semantically equivalent."""
    legacy_data = fetch_legacy_data()
    new_data = fetch_new_data()
    
    # Normalize
    legacy_normalized = normalize(legacy_data)
    new_normalized = normalize(new_data)
    
    # Assert equivalence
    assert legacy_normalized == new_normalized
```

## Integration Testing Standards

### Smoke Tests

Verify critical user paths work end-to-end:

```bash
# Test: Landing page loads
response=$(curl -s -w "%{http_code}" http://localhost/)
assert_equals "$response" "200"
assert_contains "$response" "Strangler Studio"

# Test: API returns data
response=$(curl -s http://localhost/api/requests)
assert_valid_json "$response"
assert_array_length "$response" 5
```

### Test Data

- Use deterministic seed data for reproducibility
- Include edge cases in seed data (empty strings, special characters)
- Keep test data realistic but anonymized

## Test Execution

### Running Tests

**All tests:**
```bash
./scripts/test_all.sh
```

**Unit tests only:**
```bash
pytest tests/
```

**Property tests only:**
```bash
pytest tests/test_property_*.py
```

**Specific test:**
```bash
pytest tests/test_requests.py::test_get_request_by_id
```

### Continuous Integration

All tests must pass before merging:
- Pre-commit hook runs linting and fast tests
- CI pipeline runs full test suite
- Coverage report generated and checked against minimums

## Test Maintenance

### When to Update Tests

- When requirements change
- When bugs are found (add regression test)
- When refactoring (tests should still pass)
- When adding new features

### Test Debt

- Fix flaky tests immediately
- Remove obsolete tests
- Keep test code as clean as production code
- Refactor tests when they become hard to understand

## Performance Testing

### Response Time Targets

- API endpoints: < 100ms (p95)
- Gateway routing: < 10ms overhead
- Page load: < 1 second

### Load Testing

Use tools like Apache Bench or wrk:

```bash
# Test API endpoint
ab -n 1000 -c 10 http://localhost/api/requests

# Verify p95 < 100ms
```

## Debugging Failed Tests

### Steps

1. Read the error message carefully
2. Check test assumptions are still valid
3. Run test in isolation
4. Add debug logging
5. Use debugger (pdb for Python, xdebug for PHP)
6. Check for environmental issues (ports, services)

### Common Issues

- **Flaky tests**: Add retries or fix race conditions
- **Timeout**: Increase timeout or optimize code
- **Assertion failure**: Check if spec changed or bug exists
- **Setup failure**: Verify test fixtures and dependencies

## Best Practices

- Write tests first (TDD) when possible
- Keep tests fast (< 1 second per test)
- Make tests independent (no shared state)
- Use descriptive assertions with helpful messages
- Test behavior, not implementation
- Avoid testing framework internals
- Keep test code DRY but prefer clarity over cleverness

## Resources

- [Hypothesis Documentation](https://hypothesis.readthedocs.io/)
- [pytest Documentation](https://docs.pytest.org/)
- [Property-Based Testing Patterns](https://fsharpforfunandprofit.com/posts/property-based-testing/)
- [OpenAPI Validation](https://github.com/p1c2u/openapi-spec-validator)
