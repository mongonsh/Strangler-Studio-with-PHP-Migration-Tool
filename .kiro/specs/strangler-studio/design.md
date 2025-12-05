# Design Document

## Overview

Strangler Studio is a demonstration application implementing the Strangler Fig pattern to migrate a legacy PHP monolith to a modern microservices architecture. The system uses an nginx gateway as a single entry point, routing requests to either the legacy PHP application or a new FastAPI service based on URL paths. The architecture is contract-first, with an OpenAPI specification serving as the source of truth for API design. The application features a premium Halloween-themed UI with cinematic design elements, demonstrating a real-world migration scenario for a "Student Requests" feature.

The core demonstration shows how developers can:
- Route traffic through a gateway to maintain a single URL
- Gradually migrate features using feature flags
- Ensure correctness through contract-based testing
- Automate validation and generation workflows with Kiro hooks

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Browser                       │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Gateway (nginx)                           │
│                  Single Entry Point                          │
│                                                              │
│  Routes:                                                     │
│    /          → Legacy PHP App                              │
│    /requests  → Legacy PHP App                              │
│    /api/*     → New API Service                             │
└──────────────┬─────────────────────────┬────────────────────┘
               │                         │
               ▼                         ▼
┌──────────────────────────┐  ┌─────────────────────────────┐
│   Legacy PHP App         │  │   New API Service           │
│   (PHP 8.x MVC)          │  │   (FastAPI/Python)          │
│                          │  │                             │
│  - Server-rendered HTML  │  │  - REST JSON endpoints      │
│  - Feature flag logic    │  │  - OpenAPI compliant        │
│  - Calls new API when    │  │  - Deterministic seed data  │
│    use_new=1             │  │                             │
└──────────────────────────┘  └─────────────────────────────┘
               │                         │
               └────────┬────────────────┘
                        │
                        ▼
              ┌──────────────────────┐
              │  OpenAPI Contract    │
              │  (Source of Truth)   │
              │                      │
              │  - Endpoint specs    │
              │  - Schema validation │
              │  - Client generation │
              └──────────────────────┘
```

### Technology Stack

- **Gateway**: nginx (reverse proxy, routing)
- **Legacy PHP App**: PHP 8.x with minimal MVC structure, no framework
- **New API Service**: FastAPI (Python 3.9+)
- **Contract**: OpenAPI 3.0+ specification (YAML)
- **Frontend Styling**: Tailwind CSS with custom Halloween theme
- **Testing**: pytest for API tests, bash scripts for integration
- **Client Generation**: openapi-generator or similar tool
- **Containerization**: Docker + Docker Compose

### Routing Strategy

The Gateway implements path-based routing:

1. **Root path (`/`)**: Routes to Legacy PHP App for landing page
2. **Legacy paths (`/requests`, `/requests/:id`)**: Routes to Legacy PHP App
3. **API paths (`/api/*`)**: Strips `/api` prefix and routes to New API Service

The Legacy PHP App implements feature flag logic:
- When `use_new=1`: Makes HTTP request to New API Service at `http://new-api:8000/requests`
- When `use_new=0` or absent: Uses legacy stub data

## Components and Interfaces

### Gateway Component (nginx)

**Responsibilities:**
- Accept all incoming HTTP requests on port 80
- Route requests based on URL path patterns
- Proxy requests to appropriate backend services
- Handle connection pooling and timeouts

**Configuration:**
```nginx
upstream legacy_php {
    server legacy-php:80;
}

upstream new_api {
    server new-api:8000;
}

server {
    listen 80;
    
    location /api/ {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://new_api;
    }
    
    location / {
        proxy_pass http://legacy_php;
    }
}
```

### Legacy PHP App Component

**Responsibilities:**
- Serve server-rendered HTML pages
- Implement feature flag logic for gradual migration
- Make HTTP requests to New API Service when `use_new=1`
- Provide fallback stub data when `use_new=0`
- Apply premium Halloween-themed styling

**Directory Structure:**
```
legacy-php/
├── public/
│   └── index.php (front controller)
├── src/
│   ├── Controllers/
│   │   ├── HomeController.php
│   │   └── RequestsController.php
│   ├── Views/
│   │   ├── layout.php
│   │   ├── home.php
│   │   └── requests.php
│   └── Services/
│       └── ApiClient.php
├── styles/
│   └── halloween.css
└── Dockerfile
```

**Key Interfaces:**

`HomeController::index()`: Renders landing page
- Input: None
- Output: HTML string with hero section, component cards, CTA button

`RequestsController::index()`: Renders requests list page
- Input: `$_GET['use_new']` (optional, defaults to '0')
- Output: HTML string with requests table, toggle UI, data source indicator

`ApiClient::fetchRequests()`: Fetches data from New API Service
- Input: None
- Output: Array of Student Request objects or null on failure

### New API Service Component

**Responsibilities:**
- Expose REST endpoints conforming to OpenAPI Contract
- Return deterministic seed data for Student Requests
- Validate request/response schemas
- Provide CORS headers for cross-origin requests
- Generate OpenAPI documentation UI

**Directory Structure:**
```
new-api/
├── app/
│   ├── main.py (FastAPI application)
│   ├── models.py (Pydantic models)
│   ├── routers/
│   │   └── requests.py
│   └── data/
│       └── seed_data.py
├── tests/
│   ├── test_requests.py
│   └── test_contract.py
├── requirements.txt
└── Dockerfile
```

**Key Interfaces:**

`GET /requests`: List all Student Requests
- Input: None
- Output: JSON array of StudentRequest objects
- Status: 200 OK

`GET /requests/{id}`: Get single Student Request
- Input: Path parameter `id` (integer)
- Output: JSON StudentRequest object
- Status: 200 OK if found, 404 if not found

**StudentRequest Model:**
```python
{
    "id": integer,
    "student_name": string,
    "school": string,
    "status": string (enum: "Possessed", "Banished", "Summoned", "Pending"),
    "created_at": string (ISO 8601 datetime),
    "priority": string (enum: "Critical", "High", "Medium", "Low"),
    "notes": string
}
```

### OpenAPI Contract Component

**Responsibilities:**
- Define all API endpoints, methods, parameters
- Specify request/response schemas with validation rules
- Serve as input for client code generation
- Enable automated contract testing

**Structure:**
```yaml
openapi: 3.0.3
info:
  title: Strangler Studio API
  version: 1.0.0
paths:
  /requests:
    get:
      summary: List all Student Requests
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/StudentRequest'
  /requests/{id}:
    get:
      summary: Get Student Request by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StudentRequest'
        '404':
          description: Request not found
components:
  schemas:
    StudentRequest:
      type: object
      required:
        - id
        - student_name
        - school
        - status
        - created_at
        - priority
      properties:
        id:
          type: integer
        student_name:
          type: string
        school:
          type: string
        status:
          type: string
          enum: [Possessed, Banished, Summoned, Pending]
        created_at:
          type: string
          format: date-time
        priority:
          type: string
          enum: [Critical, High, Medium, Low]
        notes:
          type: string
```

## Data Models

### StudentRequest

Represents a request submitted by a student.

**Fields:**
- `id` (integer, required): Unique identifier
- `student_name` (string, required): Full name of the student
- `school` (string, required): Name of the educational institution
- `status` (enum, required): Current state of the request
  - Values: "Possessed", "Banished", "Summoned", "Pending"
- `created_at` (datetime, required): ISO 8601 timestamp of creation
- `priority` (enum, required): Urgency level
  - Values: "Critical", "High", "Medium", "Low"
- `notes` (string, optional): Additional information or comments

**Seed Data:**
The system includes 5-7 deterministic Student Request records with Halloween-themed content:
- Student names: "Victor Frankenstein", "Mina Harker", "Henry Jekyll", etc.
- Schools: "Miskatonic University", "Transylvania Academy", etc.
- Varied statuses and priorities for visual demonstration

### Legacy Data Format

The legacy stub data uses a similar structure but may have minor formatting differences:
- Date format might be different (e.g., "Y-m-d H:i:s" vs ISO 8601)
- Field names might use snake_case vs camelCase
- Status values might be generic ("Active", "Pending") vs themed

Golden tests validate that these differences are acceptable and data semantics are preserved.

## C
orrectness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Gateway routing correctness

*For any* HTTP request to the gateway, if the path starts with `/api/`, the request should be routed to the New API Service; otherwise, the request should be routed to the Legacy PHP App.

**Validates: Requirements 1.1, 2.1, 3.1**

### Property 2: API endpoint ID lookup correctness

*For any* valid Student Request ID in the seed data, when a GET request is made to `/requests/{id}`, the returned JSON object should have an `id` field matching the requested ID.

**Validates: Requirements 3.3**

### Property 3: API response completeness

*For any* Student Request object returned by the New API Service (either from `/requests` list or `/requests/{id}`), the JSON response should contain all required fields: `id`, `student_name`, `school`, `status`, `created_at`, `priority`, and optionally `notes`.

**Validates: Requirements 3.4**

### Property 4: OpenAPI contract compliance

*For any* response from the New API Service endpoints, the response body should validate successfully against the corresponding schema defined in the OpenAPI Contract specification.

**Validates: Requirements 3.5**

### Property 5: Legacy-to-new data semantic equivalence

*For any* Student Request, when comparing the data returned from the legacy stub data (use_new=0) versus the new API (use_new=1), the semantic content (student name, school, status meaning, priority level) should be equivalent, allowing only for known formatting differences (date format, field name casing, status label theming).

**Validates: Requirements 5.5**

## Error Handling

### Gateway Errors

**Backend Unavailable:**
- When a backend service (Legacy PHP App or New API Service) is unreachable
- Gateway returns 502 Bad Gateway
- Error page displays "Service temporarily unavailable"

**Timeout:**
- When a backend service takes longer than 30 seconds to respond
- Gateway returns 504 Gateway Timeout
- Connection is closed gracefully

### Legacy PHP App Errors

**API Call Failure:**
- When `use_new=1` but New API Service is unreachable
- Fallback to legacy stub data automatically
- Display warning banner: "Using fallback data - API unavailable"
- Log error for debugging

**Invalid Request:**
- When request parameters are malformed
- Return 400 Bad Request with error message
- Display user-friendly error page

### New API Service Errors

**Request Not Found:**
- When GET `/requests/{id}` with non-existent ID
- Return 404 Not Found
- Response body: `{"detail": "Request not found"}`

**Validation Error:**
- When request doesn't match OpenAPI schema
- Return 422 Unprocessable Entity
- Response body includes validation error details

**Internal Error:**
- When unexpected exception occurs
- Return 500 Internal Server Error
- Log full stack trace
- Response body: `{"detail": "Internal server error"}`

### Script Errors

**Validation Failure:**
- When OpenAPI contract has syntax errors
- Script exits with code 1
- Output shows specific validation errors with line numbers

**Generation Failure:**
- When client generation fails
- Script exits with code 1
- Output shows generator error messages

**Test Failure:**
- When any test fails
- Script exits with code 1
- Output shows failed test details and assertions

## Testing Strategy

*A property is a characteristic or behavior that should hold true across all valid executions of a system. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

The testing strategy employs a dual approach combining unit tests and property-based tests to ensure comprehensive coverage:

### Unit Testing Approach

Unit tests verify specific examples, edge cases, and integration points:

**Smoke Tests:**
- Verify critical user paths return successful responses
- Test: GET `/` returns 200 with expected title
- Test: GET `/requests?use_new=1` returns 200 with API data
- Test: GET `/api/requests` returns 200 with valid JSON array
- Test: GET `/api/requests/1` returns 200 with valid JSON object

**Integration Tests:**
- Verify feature flag behavior switches data sources correctly
- Test: `use_new=1` makes HTTP call to API service
- Test: `use_new=0` uses stub data without external calls
- Test: Missing `use_new` parameter defaults to legacy behavior

**Edge Case Tests:**
- Test: GET `/api/requests/999` (non-existent ID) returns 404
- Test: API service unavailable triggers fallback in legacy app
- Test: Malformed requests return appropriate error codes

**UI Content Tests:**
- Verify landing page contains required elements (hero, cards, CTA)
- Verify requests page contains toggle UI and data source indicator
- Verify Halloween-themed styling is applied (CSS properties)

### Property-Based Testing Approach

Property-based tests verify universal properties across all inputs using the **Hypothesis** library for Python (for API tests) and **bash-based property testing** for integration tests.

**Configuration:**
- Each property-based test runs a minimum of 100 iterations
- Tests use deterministic seed data for reproducibility
- Each test is tagged with a comment referencing the design document property

**Property Test 1: Gateway Routing**
- **Tag:** `# Feature: strangler-studio, Property 1: Gateway routing correctness`
- **Strategy:** Generate random paths (with and without `/api/` prefix)
- **Assertion:** Verify requests are routed to correct backend service
- **Validates:** Requirements 1.1, 2.1, 3.1

**Property Test 2: API ID Lookup**
- **Tag:** `# Feature: strangler-studio, Property 2: API endpoint ID lookup correctness`
- **Strategy:** Generate random valid IDs from seed data
- **Assertion:** Verify returned object has matching ID field
- **Validates:** Requirements 3.3

**Property Test 3: Response Completeness**
- **Tag:** `# Feature: strangler-studio, Property 3: API response completeness`
- **Strategy:** Fetch all Student Requests from both endpoints
- **Assertion:** Verify each object contains all required fields
- **Validates:** Requirements 3.4

**Property Test 4: Contract Compliance**
- **Tag:** `# Feature: strangler-studio, Property 4: OpenAPI contract compliance`
- **Strategy:** Make requests to all API endpoints, collect responses
- **Assertion:** Validate each response against OpenAPI schema using openapi-spec-validator
- **Validates:** Requirements 3.5

**Property Test 5: Data Semantic Equivalence**
- **Tag:** `# Feature: strangler-studio, Property 5: Legacy-to-new data semantic equivalence`
- **Strategy:** Fetch data from both legacy and new paths, normalize formats
- **Assertion:** Verify semantic content matches after normalization (allowing date format, casing, status label differences)
- **Validates:** Requirements 5.5

### Contract Testing

Contract testing ensures the New API Service conforms to the OpenAPI specification:

**Tools:**
- `openapi-spec-validator`: Validates OpenAPI YAML syntax and structure
- `schemathesis`: Generates test cases from OpenAPI spec and validates responses
- Custom validation scripts for specific business rules

**Process:**
1. Validate OpenAPI file is syntactically correct
2. Generate test cases from OpenAPI spec
3. Execute requests against running API service
4. Validate responses match schema definitions
5. Report any discrepancies

### Golden Testing

Golden tests ensure migration correctness by comparing legacy and new implementations:

**Approach:**
- Capture output from legacy path (`use_new=0`)
- Capture output from new path (`use_new=1`)
- Normalize known formatting differences:
  - Date formats: Convert both to ISO 8601 for comparison
  - Field names: Normalize casing (snake_case vs camelCase)
  - Status labels: Map themed labels to semantic equivalents
- Assert semantic equivalence after normalization

**Allowed Differences:**
- Date format (legacy: "2024-10-31 23:59:59", new: "2024-10-31T23:59:59Z")
- Status labels (legacy: "Active", new: "Summoned")
- Field name casing (legacy: "student_name", new: "studentName" if applicable)

**Disallowed Differences:**
- Missing or extra data records
- Different student names, schools, or priority levels
- Incorrect status semantic meaning

### Test Automation

All tests are automated through scripts and Kiro hooks:

**Scripts:**
- `scripts/test_all.sh`: Runs all test suites (smoke, contract, golden, property)
- `scripts/validate_openapi.sh`: Validates OpenAPI contract file
- `scripts/test_contract.sh`: Runs contract validation tests
- `scripts/test_golden.sh`: Runs golden tests

**Kiro Hooks:**
- On OpenAPI file change: Run validation and regenerate client
- On code file change: Run relevant test suite
- Pre-commit: Run all tests and validations

### Test Requirements Summary

- Unit tests verify specific examples and edge cases
- Property-based tests verify universal properties across 100+ iterations
- Contract tests ensure API conforms to OpenAPI specification
- Golden tests ensure legacy and new implementations are semantically equivalent
- All property-based tests are tagged with format: `# Feature: strangler-studio, Property {number}: {property_text}`
- Each correctness property is implemented by a single property-based test
- Tests are placed close to implementation to catch errors early

## UI Design System

### Visual Design Principles

The Halloween theme is premium and cinematic, avoiding generic or cheap aesthetics. The design evokes a modern horror film aesthetic with sophisticated visual effects.

### Color Palette

**Primary Colors:**
- Background: `#0a0a0a` (deep black) with `#1a1a1a` (charcoal) for elevated surfaces
- Surface: `#1a1a1a` with subtle grain texture overlay

**Accent Colors:**
- Pumpkin Orange: `#ff6b35` (primary accent, CTAs, highlights)
- Ghostly Cyan: `#4ecdc4` (secondary accent, links, info)
- Blood Red: `#c1121f` (rare highlight, errors, critical status)
- Bone White: `#f8f9fa` (text, high contrast elements)

**Semantic Colors:**
- Success/Summoned: `#4ecdc4` (cyan)
- Warning/Possessed: `#ff6b35` (orange)
- Error/Banished: `#c1121f` (red)
- Neutral/Pending: `#6c757d` (gray)

### Typography

**Font Families:**
- Headings: `'Cinzel', serif` - elegant, slightly gothic
- Body: `'Inter', sans-serif` - modern, highly readable
- Monospace: `'Fira Code', monospace` - for code snippets

**Type Scale:**
- Hero Title: 4rem (64px), font-weight 700
- Section Heading: 2.5rem (40px), font-weight 600
- Card Title: 1.5rem (24px), font-weight 600
- Body: 1rem (16px), font-weight 400
- Small: 0.875rem (14px), font-weight 400

### Visual Effects

**Glassmorphism:**
```css
background: rgba(26, 26, 26, 0.7);
backdrop-filter: blur(10px);
border: 1px solid rgba(255, 255, 255, 0.1);
```

**Glow Effects:**
```css
box-shadow: 0 0 20px rgba(255, 107, 53, 0.3),
            0 0 40px rgba(255, 107, 53, 0.1);
```

**Gradient Borders:**
```css
border-image: linear-gradient(135deg, #ff6b35, #4ecdc4) 1;
animation: gradient-shift 3s ease infinite;
```

**Grain Texture:**
- SVG noise filter overlay at 5% opacity
- Subtle vignette effect on page edges

### Component Specifications

**Hero Section:**
- Full viewport height
- Centered content with subtle parallax on scroll
- Animated gradient background
- Glowing title with text-shadow
- Subtitle with fade-in animation

**Component Cards:**
- Glassmorphism background
- Hover: Lift effect (translateY(-8px)) with increased glow
- Animated gradient border
- Icon with glow effect
- Smooth transitions (300ms ease)

**Feature Flag Toggle (Witch Switch):**
- Custom styled checkbox
- Witch hat icon that moves on toggle
- Glowing trail effect during transition
- Labels: "Legacy Curse" (off) / "Modern Magic" (on)

**Status Badges:**
- Pill-shaped with rounded corners
- Background color based on status
- Subtle glow matching status color
- Icon prefix (skull, star, flame, hourglass)

**Data Table:**
- Glassmorphism rows
- Hover: Subtle highlight with glow
- Alternating row opacity for readability
- Sticky header with blur effect

**Buttons:**
- Primary: Orange gradient with glow
- Secondary: Outlined with hover fill
- Hover: Increased glow and slight scale (1.05)
- Active: Pressed effect (scale 0.98)

### Responsive Design

**Breakpoints:**
- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

**Mobile Adaptations:**
- Hero title: 2.5rem
- Single column layout for cards
- Simplified animations (reduced motion)
- Touch-friendly button sizes (min 44px)

### Animation Guidelines

**Timing:**
- Fast: 150ms (micro-interactions)
- Medium: 300ms (hover states, toggles)
- Slow: 600ms (page transitions, reveals)

**Easing:**
- Standard: `cubic-bezier(0.4, 0.0, 0.2, 1)`
- Decelerate: `cubic-bezier(0.0, 0.0, 0.2, 1)`
- Accelerate: `cubic-bezier(0.4, 0.0, 1, 1)`

**Effects:**
- Fade in: opacity 0 → 1
- Slide up: translateY(20px) → 0
- Glow pulse: box-shadow intensity oscillation
- Gradient shift: background-position animation

### Accessibility

- WCAG 2.1 AA compliance minimum
- Color contrast ratio ≥ 4.5:1 for body text
- Color contrast ratio ≥ 3:1 for large text
- Focus indicators with high contrast outline
- Reduced motion support via `prefers-reduced-motion`
- Semantic HTML with proper heading hierarchy
- ARIA labels for interactive elements

## Deployment Architecture

### Docker Compose Configuration

The application uses Docker Compose to orchestrate three services:

**Services:**
1. `gateway` (nginx)
   - Port: 80 (exposed to host)
   - Depends on: legacy-php, new-api
   - Volume: ./gateway/nginx.conf

2. `legacy-php` (PHP 8.x with Apache)
   - Internal port: 80
   - Volume: ./legacy-php
   - Environment: API_BASE_URL=http://new-api:8000

3. `new-api` (FastAPI with uvicorn)
   - Internal port: 8000
   - Volume: ./new-api
   - Command: uvicorn app.main:app --host 0.0.0.0 --port 8000

**Network:**
- All services on same Docker network for internal communication
- Only gateway port 80 exposed to host

### Environment Variables

**Legacy PHP App:**
- `API_BASE_URL`: Base URL for New API Service (default: http://new-api:8000)
- `ENVIRONMENT`: dev/staging/prod (default: dev)

**New API Service:**
- `ENVIRONMENT`: dev/staging/prod (default: dev)
- `LOG_LEVEL`: debug/info/warning/error (default: info)

### Startup Sequence

1. Docker Compose starts all services in parallel
2. New API Service loads seed data on startup
3. Legacy PHP App waits for API service health check
4. Gateway starts and begins accepting requests
5. Health check endpoint `/health` returns 200 when all services ready

### Development Workflow

1. Clone repository
2. Run `docker-compose up --build`
3. Access application at `http://localhost`
4. Make code changes (volumes auto-sync)
5. Refresh browser to see changes (PHP) or restart container (API)

### Production Considerations

- Use environment-specific docker-compose files
- Enable nginx caching for static assets
- Configure proper logging and monitoring
- Use secrets management for sensitive configuration
- Implement rate limiting at gateway level
- Enable HTTPS with SSL certificates
- Configure health checks and restart policies

## Automation and Workflows

### Script Specifications

**scripts/validate_openapi.sh:**
- Validates OpenAPI YAML syntax
- Checks OpenAPI 3.0+ compliance
- Verifies all required fields present
- Exit code 0 on success, 1 on failure
- Output: Validation errors with line numbers

**scripts/generate_client.sh:**
- Reads contracts/openapi.yaml
- Generates typed client using openapi-generator
- Output directory: generated/client
- Language: TypeScript or Python (configurable)
- Exit code 0 on success, 1 on failure

**scripts/test_all.sh:**
- Runs smoke tests
- Runs contract validation tests
- Runs golden tests
- Runs property-based tests
- Aggregates results
- Exit code 0 if all pass, 1 if any fail

**scripts/demo.sh:**
- Starts Docker Compose services
- Waits for health checks
- Executes demo scenario:
  1. Curl GET / (show landing page)
  2. Curl GET /requests?use_new=0 (show legacy)
  3. Curl GET /requests?use_new=1 (show new API)
  4. Curl GET /api/requests (show API directly)
- Outputs formatted results
- Stops services on completion

### Kiro Hooks Configuration

**Hook 1: OpenAPI Validation**
- Trigger: On file save of contracts/openapi.yaml
- Action: Execute scripts/validate_openapi.sh
- On success: Execute scripts/generate_client.sh
- On failure: Display error notification

**Hook 2: Test Execution**
- Trigger: On file save of *.py, *.php files
- Action: Execute scripts/test_all.sh
- On failure: Display test results in panel

**Hook 3: Pre-commit Validation**
- Trigger: On git commit
- Action: Execute scripts/validate_openapi.sh && scripts/test_all.sh
- On failure: Block commit with error message

### Kiro Specs Usage

The `.kiro/specs/strangler-studio/` directory contains:
- `requirements.md`: User stories and acceptance criteria
- `design.md`: This document
- `tasks.md`: Implementation task list

These documents drive the implementation process and serve as living documentation.

### Kiro Steering Usage

The `.kiro/steering/` directory contains:
- `code-quality.md`: Code style and quality standards
- `testing-standards.md`: Testing requirements and patterns
- `halloween-theme.md`: UI design guidelines and color palette
- `api-conventions.md`: REST API design conventions

Steering files are automatically included in Kiro context to enforce consistency.

## Implementation Notes

### Technology Choices Rationale

**FastAPI for New API Service:**
- Native OpenAPI support (auto-generates spec)
- Pydantic for data validation
- High performance with async support
- Excellent developer experience

**PHP 8.x for Legacy App:**
- Represents realistic legacy scenario
- No framework to keep it "legacy-style"
- Modern enough for Docker support
- Easy to understand for demonstration

**nginx for Gateway:**
- Industry-standard reverse proxy
- Simple configuration
- High performance
- Excellent Docker support

**Tailwind CSS for Styling:**
- Utility-first approach for rapid development
- Easy to customize for Halloween theme
- Small bundle size with purging
- Excellent documentation

### Development Priorities

1. **Core Architecture First:** Gateway routing and service communication
2. **Contract Definition:** OpenAPI spec as foundation
3. **API Implementation:** New service with seed data
4. **Legacy Integration:** Feature flag and API client
5. **UI Polish:** Halloween theme and visual effects
6. **Testing:** Property-based and contract tests
7. **Automation:** Scripts and hooks
8. **Documentation:** README and demo script

### Quality Standards

- All code must pass linting (PHP CS Fixer, Black for Python)
- Test coverage minimum 80% for API service
- All API endpoints must have OpenAPI documentation
- All user-facing text must be spell-checked
- All commits must pass pre-commit hooks
- Code must be reviewed before merging (in team setting)

### Performance Targets

- Landing page load: < 1 second
- API response time: < 100ms (p95)
- Gateway routing overhead: < 10ms
- Docker Compose startup: < 30 seconds
- Test suite execution: < 60 seconds

### Security Considerations

- No authentication required (demo application)
- Input validation on all API endpoints
- SQL injection not applicable (no database)
- XSS prevention in PHP templates (htmlspecialchars)
- CORS configured for API service
- No sensitive data in seed data
- Docker containers run as non-root users

## Success Metrics

The implementation will be considered successful when:

1. ✅ All Docker services start with `docker-compose up`
2. ✅ Gateway correctly routes requests to appropriate backends
3. ✅ Feature flag toggles between legacy and new implementations
4. ✅ All API responses validate against OpenAPI contract
5. ✅ Golden tests confirm semantic equivalence
6. ✅ All property-based tests pass with 100+ iterations
7. ✅ UI demonstrates premium Halloween theme
8. ✅ Demo script executes successfully
9. ✅ All Kiro hooks function correctly
10. ✅ README provides clear instructions and architecture explanation
