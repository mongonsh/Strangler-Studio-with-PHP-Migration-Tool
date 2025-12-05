# API Conventions

## Overview

This document defines REST API design conventions for the Strangler Studio project. Following these conventions ensures consistency, predictability, and ease of use for API consumers.

## General Principles

### Contract-First Design

- OpenAPI specification is the source of truth
- All endpoints must be defined in `contracts/openapi.yaml` before implementation
- API responses must validate against the OpenAPI schema
- Use code generation for clients to ensure type safety

### RESTful Design

- Use HTTP methods semantically (GET, POST, PUT, PATCH, DELETE)
- Use nouns for resource names, not verbs
- Use plural nouns for collections (e.g., `/requests`, not `/request`)
- Use nested resources for relationships (e.g., `/users/{id}/requests`)

### Versioning

- Include API version in URL path: `/api/v1/requests`
- Current version: v1
- Maintain backward compatibility within major versions
- Deprecate endpoints gracefully with warnings

## URL Structure

### Resource Naming

**Good:**
```
GET /api/v1/requests
GET /api/v1/requests/{id}
GET /api/v1/users/{userId}/requests
```

**Bad:**
```
GET /api/v1/getRequests          # Don't use verbs
GET /api/v1/request              # Use plural
GET /api/v1/requests-list        # Redundant
```

### Path Parameters

- Use `{id}` for resource identifiers
- Use descriptive names for clarity: `{userId}`, `{requestId}`
- Always validate path parameters

### Query Parameters

- Use for filtering, sorting, pagination
- Use snake_case for parameter names
- Document all query parameters in OpenAPI spec

**Examples:**
```
GET /api/v1/requests?status=pending
GET /api/v1/requests?sort_by=created_at&order=desc
GET /api/v1/requests?page=2&per_page=20
```

## HTTP Methods

### GET - Retrieve Resources

**Purpose:** Retrieve one or more resources

**Characteristics:**
- Safe (no side effects)
- Idempotent (multiple calls produce same result)
- Cacheable

**Examples:**
```
GET /api/v1/requests           # List all requests
GET /api/v1/requests/{id}      # Get single request
```

**Response:**
- 200 OK: Success with response body
- 404 Not Found: Resource doesn't exist
- 400 Bad Request: Invalid parameters

### POST - Create Resources

**Purpose:** Create a new resource

**Characteristics:**
- Not safe (has side effects)
- Not idempotent (multiple calls create multiple resources)
- Not cacheable

**Examples:**
```
POST /api/v1/requests
Content-Type: application/json

{
  "student_name": "Victor Frankenstein",
  "school": "Miskatonic University",
  "status": "Pending",
  "priority": "High"
}
```

**Response:**
- 201 Created: Resource created successfully
  - Include `Location` header with new resource URL
  - Return created resource in response body
- 400 Bad Request: Validation error
- 422 Unprocessable Entity: Semantic validation error

### PUT - Replace Resources

**Purpose:** Replace entire resource

**Characteristics:**
- Not safe (has side effects)
- Idempotent (multiple calls produce same result)
- Not cacheable

**Examples:**
```
PUT /api/v1/requests/{id}
Content-Type: application/json

{
  "id": 1,
  "student_name": "Victor Frankenstein",
  "school": "Miskatonic University",
  "status": "Summoned",
  "priority": "High",
  "notes": "Updated notes"
}
```

**Response:**
- 200 OK: Resource updated successfully
- 404 Not Found: Resource doesn't exist
- 400 Bad Request: Validation error

### PATCH - Partial Update

**Purpose:** Update specific fields of a resource

**Characteristics:**
- Not safe (has side effects)
- Idempotent (multiple calls produce same result)
- Not cacheable

**Examples:**
```
PATCH /api/v1/requests/{id}
Content-Type: application/json

{
  "status": "Summoned"
}
```

**Response:**
- 200 OK: Resource updated successfully
- 404 Not Found: Resource doesn't exist
- 400 Bad Request: Validation error

### DELETE - Remove Resources

**Purpose:** Delete a resource

**Characteristics:**
- Not safe (has side effects)
- Idempotent (multiple calls produce same result)
- Not cacheable

**Examples:**
```
DELETE /api/v1/requests/{id}
```

**Response:**
- 204 No Content: Resource deleted successfully
- 404 Not Found: Resource doesn't exist
- 409 Conflict: Cannot delete due to dependencies

## Status Codes

### Success Codes (2xx)

- **200 OK**: Request succeeded, response body included
- **201 Created**: Resource created successfully
- **204 No Content**: Request succeeded, no response body

### Client Error Codes (4xx)

- **400 Bad Request**: Invalid request syntax or parameters
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Authenticated but not authorized
- **404 Not Found**: Resource doesn't exist
- **422 Unprocessable Entity**: Validation error
- **429 Too Many Requests**: Rate limit exceeded

### Server Error Codes (5xx)

- **500 Internal Server Error**: Unexpected server error
- **502 Bad Gateway**: Upstream service error
- **503 Service Unavailable**: Service temporarily unavailable
- **504 Gateway Timeout**: Upstream service timeout

## Request Format

### Content Type

- Use `application/json` for request and response bodies
- Set `Content-Type: application/json` header
- Accept `Accept: application/json` header

### Request Body Structure

**Good:**
```json
{
  "student_name": "Victor Frankenstein",
  "school": "Miskatonic University",
  "status": "Pending",
  "priority": "High",
  "notes": "Urgent request"
}
```

**Bad:**
```json
{
  "data": {
    "attributes": {
      "student_name": "Victor Frankenstein"
    }
  }
}
```

### Field Naming

- Use snake_case for JSON field names
- Be consistent across all endpoints
- Use descriptive names

**Examples:**
```json
{
  "student_name": "Victor Frankenstein",  // Good
  "created_at": "2024-10-31T23:59:59Z",   // Good
  "studentName": "Victor Frankenstein",   // Bad (camelCase)
  "CreatedAt": "2024-10-31T23:59:59Z"     // Bad (PascalCase)
}
```

## Response Format

### Success Response Structure

**Single Resource:**
```json
{
  "id": 1,
  "student_name": "Victor Frankenstein",
  "school": "Miskatonic University",
  "status": "Summoned",
  "created_at": "2024-10-31T23:59:59Z",
  "priority": "High",
  "notes": "Urgent request"
}
```

**Collection:**
```json
[
  {
    "id": 1,
    "student_name": "Victor Frankenstein",
    "school": "Miskatonic University",
    "status": "Summoned",
    "created_at": "2024-10-31T23:59:59Z",
    "priority": "High"
  },
  {
    "id": 2,
    "student_name": "Mina Harker",
    "school": "Transylvania Academy",
    "status": "Pending",
    "created_at": "2024-10-30T12:00:00Z",
    "priority": "Medium"
  }
]
```

### Error Response Structure

All error responses follow consistent format:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Request with ID 999 not found",
    "details": {
      "resource": "request",
      "id": 999
    }
  }
}
```

**Error Response Fields:**
- `error.code`: Machine-readable error code (UPPER_SNAKE_CASE)
- `error.message`: Human-readable error message
- `error.details`: Optional additional context

### Validation Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "fields": [
        {
          "field": "student_name",
          "message": "Field is required"
        },
        {
          "field": "priority",
          "message": "Must be one of: Critical, High, Medium, Low"
        }
      ]
    }
  }
}
```

## Data Types

### Dates and Times

- Use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`
- Always use UTC timezone
- Include timezone indicator (`Z` or `+00:00`)

**Examples:**
```json
{
  "created_at": "2024-10-31T23:59:59Z",
  "updated_at": "2024-11-01T12:30:00Z"
}
```

### Enumerations

- Define allowed values in OpenAPI schema
- Use consistent casing (PascalCase for display values)
- Document all possible values

**Example:**
```yaml
status:
  type: string
  enum:
    - Possessed
    - Banished
    - Summoned
    - Pending
```

### Identifiers

- Use integers for database-backed IDs
- Use UUIDs for distributed systems
- Always validate ID format

### Booleans

- Use `true` and `false` (lowercase)
- Never use `1`/`0` or `"true"`/`"false"` strings

### Null Values

- Omit optional fields if null (preferred)
- Or explicitly set to `null` if semantically important
- Document nullable fields in OpenAPI schema

## Pagination

### Query Parameters

```
GET /api/v1/requests?page=2&per_page=20
```

**Parameters:**
- `page`: Page number (1-indexed)
- `per_page`: Items per page (default: 20, max: 100)

### Response Format

```json
{
  "data": [
    { "id": 21, "student_name": "..." },
    { "id": 22, "student_name": "..." }
  ],
  "pagination": {
    "page": 2,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 95
  }
}
```

## Filtering

### Query Parameters

```
GET /api/v1/requests?status=Pending&priority=High
```

**Guidelines:**
- Use field names as parameter names
- Support multiple values with comma separation
- Document all filterable fields

**Examples:**
```
GET /api/v1/requests?status=Pending,Summoned
GET /api/v1/requests?created_after=2024-10-01
GET /api/v1/requests?school=Miskatonic%20University
```

## Sorting

### Query Parameters

```
GET /api/v1/requests?sort_by=created_at&order=desc
```

**Parameters:**
- `sort_by`: Field name to sort by
- `order`: `asc` or `desc` (default: `asc`)

**Examples:**
```
GET /api/v1/requests?sort_by=priority&order=desc
GET /api/v1/requests?sort_by=student_name&order=asc
```

## CORS Configuration

### Headers

```python
# FastAPI CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://localhost:80"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Preflight Requests

- Support OPTIONS method for preflight
- Return appropriate CORS headers
- Cache preflight responses

## Rate Limiting

### Headers

Include rate limit information in response headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1635724800
```

### Rate Limit Exceeded Response

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "details": {
      "retry_after": 60
    }
  }
}
```

## Caching

### Cache Headers

```
Cache-Control: public, max-age=300
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 01 Nov 2024 12:00:00 GMT
```

### Conditional Requests

Support `If-None-Match` and `If-Modified-Since` headers:

```
GET /api/v1/requests/1
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"

Response: 304 Not Modified
```

## Security

### Authentication

- Use Bearer tokens for authentication
- Include token in `Authorization` header
- Never include credentials in URL

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Input Validation

- Validate all input at API boundary
- Use Pydantic models for automatic validation
- Return 422 for validation errors
- Sanitize input to prevent injection attacks

### Output Encoding

- Properly encode JSON responses
- Set correct Content-Type header
- Escape special characters

## Health Checks

### Endpoint

```
GET /health
```

### Response

```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-10-31T23:59:59Z",
  "checks": {
    "database": "healthy",
    "cache": "healthy"
  }
}
```

## Documentation

### OpenAPI Specification

- Document all endpoints in OpenAPI spec
- Include descriptions for all fields
- Provide examples for request/response
- Document all possible error responses

**Example:**
```yaml
paths:
  /requests/{id}:
    get:
      summary: Get Student Request by ID
      description: Retrieves a single student request by its unique identifier
      parameters:
        - name: id
          in: path
          required: true
          description: Unique identifier of the student request
          schema:
            type: integer
            example: 1
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StudentRequest'
              example:
                id: 1
                student_name: "Victor Frankenstein"
                school: "Miskatonic University"
                status: "Summoned"
                created_at: "2024-10-31T23:59:59Z"
                priority: "High"
        '404':
          description: Request not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
```

### API Documentation UI

- Enable Swagger UI at `/docs`
- Enable ReDoc at `/redoc`
- Keep documentation in sync with implementation

## Testing

### Contract Testing

- Validate all responses against OpenAPI schema
- Use `openapi-spec-validator` for validation
- Run contract tests in CI/CD pipeline

### Example Tests

```python
def test_get_request_matches_schema():
    """Verify response matches OpenAPI schema."""
    response = client.get("/requests/1")
    assert response.status_code == 200
    validate_response(response.json(), schema="StudentRequest")

def test_error_response_format():
    """Verify error responses follow standard format."""
    response = client.get("/requests/999")
    assert response.status_code == 404
    data = response.json()
    assert "error" in data
    assert "code" in data["error"]
    assert "message" in data["error"]
```

## Deprecation

### Process

1. Add deprecation warning to OpenAPI spec
2. Include `Deprecation` header in responses
3. Provide migration guide
4. Maintain deprecated endpoint for at least 6 months
5. Remove in next major version

### Deprecation Header

```
Deprecation: true
Sunset: Wed, 01 May 2025 00:00:00 GMT
Link: <https://docs.example.com/migration>; rel="deprecation"
```

## Best Practices

### Do's

- ✅ Use OpenAPI spec as source of truth
- ✅ Follow RESTful conventions
- ✅ Use appropriate HTTP status codes
- ✅ Provide clear error messages
- ✅ Validate all input
- ✅ Use consistent naming conventions
- ✅ Document all endpoints
- ✅ Version your API
- ✅ Support CORS for web clients
- ✅ Include health check endpoint

### Don'ts

- ❌ Don't use verbs in URLs
- ❌ Don't return HTML from JSON API
- ❌ Don't use custom status codes
- ❌ Don't expose internal errors to clients
- ❌ Don't break backward compatibility
- ❌ Don't use GET for operations with side effects
- ❌ Don't return different structures for same endpoint
- ❌ Don't ignore HTTP standards
- ❌ Don't skip input validation
- ❌ Don't hardcode URLs in responses

## Resources

- [OpenAPI Specification](https://swagger.io/specification/)
- [REST API Tutorial](https://restfulapi.net/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [RFC 7807 - Problem Details](https://tools.ietf.org/html/rfc7807)
