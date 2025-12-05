# Implementation Plan

- [x] 1. Set up project structure and Docker configuration
  - Create root directory structure with gateway/, legacy-php/, new-api/, contracts/, scripts/, tests/
  - Write docker-compose.yml with gateway, legacy-php, and new-api services
  - Configure Docker networking for inter-service communication
  - _Requirements: 7.1, 7.2_

- [x] 2. Implement OpenAPI contract specification
  - Create contracts/openapi.yaml with OpenAPI 3.0+ structure
  - Define StudentRequest schema with all required fields (id, student_name, school, status, created_at, priority, notes)
  - Define GET /requests endpoint specification
  - Define GET /requests/{id} endpoint specification
  - Include response schemas and error responses (404, 422, 500)
  - _Requirements: 4.1, 4.2, 3.4_

- [x] 3. Create validation and generation scripts
  - Write scripts/validate_openapi.sh to validate OpenAPI YAML syntax
  - Write scripts/generate_client.sh to generate typed client from OpenAPI contract
  - Make scripts executable and add error handling
  - _Requirements: 9.1, 4.3_

- [x] 4. Implement New API Service with FastAPI
  - Create new-api/app/main.py with FastAPI application setup
  - Create new-api/app/models.py with Pydantic StudentRequest model
  - Create new-api/app/data/seed_data.py with 5-7 deterministic Halloween-themed Student Requests
  - Implement GET /requests endpoint returning list of all Student Requests
  - Implement GET /requests/{id} endpoint returning single Student Request or 404
  - Configure CORS middleware
  - Add /health endpoint for health checks
  - Create new-api/Dockerfile with Python 3.9+ and uvicorn
  - Create new-api/requirements.txt with fastapi, uvicorn, pydantic dependencies
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.6_

- [x] 4.1 Write property test for API ID lookup correctness
  - **Property 2: API endpoint ID lookup correctness**
  - Generate random valid IDs from seed data and verify returned object has matching ID
  - Use Hypothesis library with minimum 100 iterations
  - **Validates: Requirements 3.3**

- [x] 4.2 Write property test for API response completeness
  - **Property 3: API response completeness**
  - Fetch all Student Requests and verify each contains all required fields
  - Use Hypothesis library with minimum 100 iterations
  - **Validates: Requirements 3.4**

- [x] 4.3 Write property test for OpenAPI contract compliance
  - **Property 4: OpenAPI contract compliance**
  - Make requests to all API endpoints and validate responses against OpenAPI schema
  - Use openapi-spec-validator library with minimum 100 iterations
  - **Validates: Requirements 3.5**

- [x] 5. Configure nginx gateway
  - Create gateway/nginx.conf with upstream definitions for legacy-php and new-api
  - Configure location /api/ to proxy to new-api service (strip /api prefix)
  - Configure location / to proxy to legacy-php service
  - Set appropriate proxy headers and timeouts
  - Create gateway/Dockerfile with nginx image
  - _Requirements: 1.1, 2.1, 3.1, 7.3, 7.4_

- [x] 5.1 Write property test for gateway routing correctness
  - **Property 1: Gateway routing correctness**
  - Generate random paths with and without /api/ prefix
  - Verify requests are routed to correct backend service
  - Use bash-based property testing with minimum 100 iterations
  - **Validates: Requirements 1.1, 2.1, 3.1**

- [x] 6. Implement Legacy PHP App structure
  - Create legacy-php/public/index.php as front controller with routing
  - Create legacy-php/src/Controllers/HomeController.php for landing page
  - Create legacy-php/src/Controllers/RequestsController.php for requests list
  - Create legacy-php/src/Services/ApiClient.php for HTTP calls to New API Service
  - Create legacy-php/src/Views/layout.php as base HTML template
  - Create legacy-php/Dockerfile with PHP 8.x and Apache
  - Configure Apache to route all requests through index.php
  - _Requirements: 1.2, 2.1, 2.2, 2.3, 2.4_

- [x] 7. Implement legacy PHP API client and feature flag logic
  - Implement ApiClient::fetchRequests() to make HTTP GET to New API Service
  - Add error handling and fallback to stub data on API failure
  - Create stub data array in RequestsController with 3-5 legacy-format Student Requests
  - Implement feature flag logic: check $_GET['use_new'] parameter
  - When use_new=1: call ApiClient::fetchRequests()
  - When use_new=0 or absent: use stub data
  - _Requirements: 2.2, 2.3, 2.4_

- [x] 8. Create premium Halloween-themed CSS
  - Create legacy-php/styles/halloween.css with color palette (deep black #0a0a0a, pumpkin orange #ff6b35, ghostly cyan #4ecdc4, blood red #c1121f)
  - Import Google Fonts: Cinzel for headings, Inter for body
  - Implement glassmorphism card styles with backdrop-filter blur
  - Create glow effect utilities with box-shadow
  - Implement animated gradient border keyframes
  - Add grain texture SVG filter overlay
  - Create responsive breakpoints (mobile < 640px, tablet 640-1024px, desktop > 1024px)
  - Define status badge styles for "Possessed", "Banished", "Summoned", "Pending"
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.7_

- [x] 9. Implement landing page view
  - Create legacy-php/src/Views/home.php with hero section
  - Add "Strangler Studio" title with Cinzel font and glow effect
  - Create three component cards: Gateway, Contracts, Feature Flags with glassmorphism
  - Add "Run the Ritual" CTA button linking to /requests?use_new=1
  - Implement hover microinteractions (glow, scale transform)
  - Add subtle parallax or animation effects
  - Ensure responsive layout for mobile/tablet/desktop
  - _Requirements: 1.3, 1.4, 1.5, 8.6_

- [x] 10. Implement requests list page view
  - Create legacy-php/src/Views/requests.php with table/list layout
  - Display Student Requests with columns: student_name, school, status, priority, created_at
  - Implement status badges with Halloween-themed labels and colors
  - Create witch switch toggle UI for use_new parameter with labels "Legacy Curse" / "Modern Magic"
  - Add visual indicator showing "served by new API" or "legacy path" based on use_new value
  - Apply glassmorphism to table rows with hover effects
  - Ensure responsive layout
  - _Requirements: 2.5, 2.6, 2.7, 2.8, 8.8_

- [x] 11. Create smoke tests
  - Create tests/test_smoke.sh with curl commands
  - Test: GET / returns 200 and contains "Strangler Studio" title
  - Test: GET /requests?use_new=1 returns 200 and contains data from API
  - Test: GET /api/requests returns 200 and valid JSON array
  - Test: GET /api/requests/1 returns 200 and valid JSON object
  - Add assertions for expected content in responses
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 12. Create golden tests for data equivalence
  - Create tests/test_golden.sh to compare legacy vs new data
  - Fetch data from /requests?use_new=0 (legacy)
  - Fetch data from /requests?use_new=1 (new API)
  - Normalize date formats (convert to ISO 8601)
  - Normalize field name casing if needed
  - Map Halloween status labels to semantic equivalents
  - Assert semantic content matches (student names, schools, priorities)
  - _Requirements: 5.5_

- [x] 12.1 Write property test for legacy-to-new data semantic equivalence
  - **Property 5: Legacy-to-new data semantic equivalence**
  - Compare data from legacy stub vs new API for all Student Requests
  - Normalize known formatting differences and verify semantic equivalence
  - Use bash-based property testing with minimum 100 iterations
  - **Validates: Requirements 5.5**
  - **Test Status: PASSED** (100/100 iterations passed)

- [x] 13. Create test orchestration script
  - Create scripts/test_all.sh to run all test suites
  - Execute smoke tests and capture results
  - Execute golden tests and capture results
  - Execute property-based tests and capture results
  - Aggregate results and output summary
  - Exit with code 0 if all pass, 1 if any fail
  - _Requirements: 9.3_

- [x] 14. Create demo script
  - Create scripts/demo.sh with complete demo workflow
  - Start Docker Compose services with docker-compose up -d
  - Wait for health checks to pass
  - Execute demo scenario with curl commands and formatted output:
    1. Show landing page (curl /)
    2. Show legacy requests (curl /requests?use_new=0)
    3. Show new API requests (curl /requests?use_new=1)
    4. Show API directly (curl /api/requests)
  - Display results with clear labels and formatting
  - Stop services with docker-compose down
  - _Requirements: 9.4_

- [x] 15. Configure Kiro hooks
  - Create .kiro/hooks/validate-openapi.json for OpenAPI file changes
  - Trigger: On save of contracts/openapi.yaml
  - Action: Execute scripts/validate_openapi.sh
  - Create .kiro/hooks/generate-client.json to run after validation
  - Create .kiro/hooks/run-tests.json for code file changes
  - Trigger: On save of *.py, *.php files
  - Action: Execute scripts/test_all.sh
  - _Requirements: 6.1, 6.2, 6.3_

- [x] 16. Create Kiro steering documents
  - Create .kiro/steering/code-quality.md with code style standards (PHP CS Fixer, Black for Python)
  - Create .kiro/steering/testing-standards.md with testing requirements (80% coverage, property-based testing patterns)
  - Create .kiro/steering/halloween-theme.md with UI design guidelines (color palette, typography, effects)
  - Create .kiro/steering/api-conventions.md with REST API design conventions (naming, status codes, error formats)
  - _Requirements: 10.5_

- [x] 17. Write comprehensive README
  - Create README.md with one-paragraph pitch explaining Strangler Studio concept
  - Add architecture diagram (ASCII art or Mermaid) showing Gateway, Legacy PHP App, New API Service, OpenAPI Contract
  - Write "How to Run" section with exact docker-compose commands
  - Write "Demo Steps" section with command sequence to demonstrate migration
  - Write "How Kiro was used" section explaining specs, steering, and hooks usage
  - Add project structure overview
  - Include troubleshooting section
  - Add license information (OSI-approved license)
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 18. Add UI content tests
  - Create tests/test_ui_content.sh to verify UI elements
  - Test: Landing page contains hero section, three cards, CTA button
  - Test: Requests page contains toggle UI and data source indicator
  - Test: CSS file contains Halloween color palette values
  - Test: HTML uses Cinzel and Inter fonts
  - _Requirements: 1.3, 1.4, 1.5, 2.5, 2.6, 2.7, 8.4_

- [x] 19. Final checkpoint - Ensure all tests pass
  - Run scripts/test_all.sh and verify all tests pass
  - Run scripts/validate_openapi.sh and verify contract is valid
  - Run scripts/demo.sh and verify demo executes successfully
  - Test docker-compose up and verify all services start
  - Manually test feature flag toggle in browser
  - Verify UI displays premium Halloween theme
  - Ensure all tests pass, ask the user if questions arise

- [x] 20. Create .gitignore and finalize repository
  - Create .gitignore with common exclusions (node_modules, __pycache__, .env, generated/)
  - Do NOT ignore .kiro/ directory (must be committed)
  - Add LICENSE file with OSI-approved license (MIT recommended)
  - Verify all required files are present and committed
  - Test fresh clone and docker-compose up workflow
  - _Requirements: 7.1_
