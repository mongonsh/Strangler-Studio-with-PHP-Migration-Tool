# Requirements Document

## Introduction

Strangler Studio is a production-quality demonstration application that showcases how to migrate a legacy PHP application to a modern service architecture without downtime. The system uses the Strangler Fig pattern with an nginx gateway, contract-first API design via OpenAPI, and automated validation workflows. The application features a premium Halloween-themed UI that is cinematic, polished, and memorable, demonstrating the migration of a "Student Requests" feature from legacy PHP to a modern FastAPI service.

## Glossary

- **Gateway**: The nginx reverse proxy that routes traffic to either the Legacy PHP App or the New API Service based on URL path
- **Legacy PHP App**: The existing server-rendered PHP application using MVC architecture that serves HTML pages
- **New API Service**: The modern FastAPI service that exposes contract-first REST endpoints
- **OpenAPI Contract**: The source-of-truth YAML specification file that defines API endpoints, request/response schemas, and validation rules
- **Feature Flag**: A query parameter (`use_new`) that toggles between legacy and new API-driven code paths
- **Strangler Fig Pattern**: An architectural pattern for gradually replacing legacy systems by routing new functionality through modern services
- **Contract Validation**: Automated testing that verifies API responses conform to the OpenAPI specification
- **Golden Test**: A test that compares legacy output format against new output format and asserts only allowed differences
- **Smoke Test**: Basic integration tests that verify critical user paths return successful responses
- **Generated Client**: Type-safe client code automatically generated from the OpenAPI specification
- **Student Request**: A data entity representing a request from a student, containing fields like id, student_name, school, status, created_at, priority, and notes

## Requirements

### Requirement 1

**User Story:** As a developer inheriting a legacy PHP monolith, I want to view a Halloween-themed landing page that explains the migration approach, so that I understand the Strangler Fig pattern and the system architecture.

#### Acceptance Criteria

1. WHEN a user navigates to the root path `/` THEN the Gateway SHALL route the request to the Legacy PHP App
2. WHEN the Legacy PHP App receives a request to `/` THEN the system SHALL return an HTTP 200 response with a server-rendered HTML page
3. WHEN the landing page renders THEN the system SHALL display a hero section containing the "Strangler Studio" title and tagline
4. WHEN the landing page renders THEN the system SHALL display three architectural component cards explaining Gateway, Contracts, and Feature Flags
5. WHEN the landing page renders THEN the system SHALL include a call-to-action button labeled "Run the Ritual" that links to `/requests?use_new=1`

### Requirement 2

**User Story:** As a developer demonstrating the migration, I want to view a list of Student Requests with the ability to toggle between legacy and new API implementations, so that I can prove the Strangler Fig pattern works without downtime.

#### Acceptance Criteria

1. WHEN a user navigates to `/requests` THEN the Gateway SHALL route the request to the Legacy PHP App
2. WHEN the Legacy PHP App receives a request to `/requests` with query parameter `use_new=1` THEN the system SHALL fetch data from the New API Service via HTTP request to `/api/requests`
3. WHEN the Legacy PHP App receives a request to `/requests` with query parameter `use_new=0` THEN the system SHALL use legacy stub data without calling the New API Service
4. WHEN the Legacy PHP App receives a request to `/requests` without the `use_new` parameter THEN the system SHALL default to `use_new=0` behavior
5. WHEN the requests page renders THEN the system SHALL display a toggle UI element that allows switching between `use_new=1` and `use_new=0` modes
6. WHEN the requests page renders with `use_new=1` THEN the system SHALL display a visual indicator showing "served by new API"
7. WHEN the requests page renders with `use_new=0` THEN the system SHALL display a visual indicator showing "legacy path"
8. WHEN the requests page renders THEN the system SHALL display Student Requests in a table or list format with status badges

### Requirement 3

**User Story:** As a developer building the new service, I want the New API Service to expose REST endpoints defined by an OpenAPI contract, so that the API behavior is predictable and type-safe.

#### Acceptance Criteria

1. WHEN a client sends a GET request to `/api/requests` THEN the Gateway SHALL route the request to the New API Service
2. WHEN the New API Service receives a GET request to `/requests` THEN the system SHALL return an HTTP 200 response with a JSON array of Student Request objects
3. WHEN the New API Service receives a GET request to `/requests/{id}` THEN the system SHALL return an HTTP 200 response with a single Student Request JSON object matching the specified id
4. WHEN the New API Service returns a Student Request object THEN the response SHALL include fields: id, student_name, school, status, created_at, priority, and notes
5. WHEN the New API Service processes any request THEN the response format SHALL conform to the OpenAPI Contract specification
6. WHEN the New API Service starts THEN the system SHALL load deterministic seed data for Student Requests

### Requirement 4

**User Story:** As a developer ensuring API correctness, I want an OpenAPI specification file as the source of truth, so that I can generate clients and validate responses automatically.

#### Acceptance Criteria

1. WHEN the OpenAPI Contract file is parsed THEN the system SHALL validate it as syntactically correct YAML conforming to OpenAPI 3.0 or higher specification
2. WHEN the OpenAPI Contract defines an endpoint THEN the New API Service SHALL implement that endpoint with matching path, method, parameters, and response schema
3. WHEN a code generation script executes THEN the system SHALL produce a typed client library from the OpenAPI Contract
4. WHEN the generated client is used THEN the system SHALL provide type-safe method calls matching the OpenAPI Contract endpoints
5. WHEN the OpenAPI Contract is modified THEN the validation script SHALL detect the change and trigger regeneration

### Requirement 5

**User Story:** As a developer proving migration correctness, I want automated tests that validate the gateway routing, API contracts, and data consistency, so that I can deploy with confidence.

#### Acceptance Criteria

1. WHEN smoke tests execute THEN the system SHALL verify GET `/` returns HTTP 200 and the response body contains the expected page title
2. WHEN smoke tests execute THEN the system SHALL verify GET `/requests?use_new=1` returns HTTP 200 and the response body contains data fields from the New API Service
3. WHEN smoke tests execute THEN the system SHALL verify GET `/api/requests` returns HTTP 200 and a valid JSON array
4. WHEN contract validation tests execute THEN the system SHALL verify all New API Service responses conform to the OpenAPI Contract schema
5. WHEN golden tests execute THEN the system SHALL compare the legacy data format against the new API data format and assert only allowed differences exist
6. WHEN any test fails THEN the system SHALL return a non-zero exit code and output diagnostic information

### Requirement 6

**User Story:** As a developer automating the workflow, I want Kiro hooks that run validation, generation, and tests automatically, so that I catch errors early and maintain consistency.

#### Acceptance Criteria

1. WHEN the OpenAPI Contract file is modified THEN the system SHALL automatically execute the OpenAPI validation script
2. WHEN the OpenAPI validation passes THEN the system SHALL automatically execute the client generation script
3. WHEN code files are modified THEN the system SHALL automatically execute the test suite
4. WHEN a hook execution fails THEN the system SHALL display an error message and prevent the workflow from continuing
5. WHEN all hooks execute successfully THEN the system SHALL allow the workflow to proceed

### Requirement 7

**User Story:** As a developer deploying the application, I want a single Docker Compose command to start all services, so that the demo is reproducible and easy to run.

#### Acceptance Criteria

1. WHEN `docker-compose up` executes THEN the system SHALL start the Gateway, Legacy PHP App, and New API Service containers
2. WHEN all containers are running THEN the Gateway SHALL be accessible on a single entrypoint URL
3. WHEN the Gateway receives a request to `/` THEN the system SHALL route it to the Legacy PHP App container
4. WHEN the Gateway receives a request to `/api/*` THEN the system SHALL route it to the New API Service container
5. WHEN any container fails to start THEN the system SHALL output error logs and exit with a non-zero code

### Requirement 8

**User Story:** As a user experiencing the application, I want a premium Halloween-themed UI with cinematic design, so that the demo is memorable and visually impressive.

#### Acceptance Criteria

1. WHEN any page renders THEN the system SHALL apply a visual design with deep charcoal or inky black background with subtle grain texture
2. WHEN any page renders THEN the system SHALL use accent colors of neon pumpkin orange, ghostly cyan, and blood red as rare highlights
3. WHEN any page renders THEN the system SHALL apply lighting effects including glow, bloom, and soft shadows
4. WHEN any page renders THEN the system SHALL use modern typography with Cinzel font for headings and Inter font for body text
5. WHEN any page renders THEN the system SHALL implement glassmorphism cards with animated gradient borders
6. WHEN a user hovers over interactive elements THEN the system SHALL display microinteractions including hover glow and smooth transitions
7. WHEN the requests page displays status values THEN the system SHALL use Halloween-themed status labels such as "Possessed", "Banished", or "Summoned"
8. WHEN the feature flag toggle renders THEN the system SHALL style it as a witch switch with thematic visual design

### Requirement 9

**User Story:** As a developer running the demo, I want executable scripts that automate validation, generation, testing, and demo workflows, so that I can quickly verify the system works correctly.

#### Acceptance Criteria

1. WHEN `scripts/validate_openapi.sh` executes THEN the system SHALL validate the OpenAPI Contract file and return exit code 0 if valid
2. WHEN `scripts/generate_client.sh` executes THEN the system SHALL generate typed client code from the OpenAPI Contract
3. WHEN `scripts/test_all.sh` executes THEN the system SHALL run smoke tests, contract validation tests, and golden tests
4. WHEN `scripts/demo.sh` executes THEN the system SHALL perform a complete demo workflow with deterministic output
5. WHEN any script encounters an error THEN the system SHALL output diagnostic information and return a non-zero exit code

### Requirement 10

**User Story:** As a developer understanding the project, I want comprehensive documentation in the README, so that I can quickly understand the architecture, run the application, and execute the demo.

#### Acceptance Criteria

1. WHEN the README is viewed THEN the document SHALL contain a one-paragraph pitch explaining the Strangler Studio concept
2. WHEN the README is viewed THEN the document SHALL include an architecture diagram showing Gateway, Legacy PHP App, New API Service, and OpenAPI Contract relationships
3. WHEN the README is viewed THEN the document SHALL provide step-by-step instructions for running the application with exact commands
4. WHEN the README is viewed THEN the document SHALL include a demo steps section with the exact command sequence to demonstrate the migration
5. WHEN the README is viewed THEN the document SHALL contain a "How Kiro was used" section explaining specs, steering, and hooks usage
