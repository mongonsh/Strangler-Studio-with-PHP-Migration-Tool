# Code Quality Standards

## Overview

This document defines code quality standards for the Strangler Studio project. All code contributions must adhere to these standards to ensure consistency, maintainability, and readability.

## PHP Code Standards

### Style Guide

- Follow PSR-12 coding standard
- Use PHP CS Fixer for automatic formatting
- 4 spaces for indentation (no tabs)
- Opening braces on same line for functions and classes
- Maximum line length: 120 characters

### PHP CS Fixer Configuration

Run PHP CS Fixer before committing:

```bash
php-cs-fixer fix --rules=@PSR12
```

### Naming Conventions

- Classes: PascalCase (e.g., `RequestsController`, `ApiClient`)
- Methods: camelCase (e.g., `fetchRequests()`, `renderView()`)
- Variables: snake_case (e.g., `$student_name`, `$use_new`)
- Constants: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

### Best Practices

- Always use type declarations for function parameters and return types
- Use strict types: `declare(strict_types=1);` at the top of each file
- Escape all output with `htmlspecialchars()` to prevent XSS
- Use meaningful variable names that describe their purpose
- Keep functions small and focused (max 50 lines)
- Avoid deep nesting (max 3 levels)

### Error Handling

- Use exceptions for error handling, not error codes
- Catch specific exceptions, not generic `Exception`
- Log errors before displaying user-friendly messages
- Never expose stack traces to end users

## Python Code Standards

### Style Guide

- Follow PEP 8 style guide
- Use Black for automatic formatting
- 4 spaces for indentation (no tabs)
- Maximum line length: 88 characters (Black default)

### Black Configuration

Run Black before committing:

```bash
black .
```

### Naming Conventions

- Classes: PascalCase (e.g., `StudentRequest`, `ApiRouter`)
- Functions: snake_case (e.g., `get_requests()`, `fetch_by_id()`)
- Variables: snake_case (e.g., `student_name`, `created_at`)
- Constants: UPPER_SNAKE_CASE (e.g., `API_VERSION`, `MAX_RETRIES`)
- Private methods: prefix with underscore (e.g., `_validate_data()`)

### Type Hints

- Always use type hints for function parameters and return types
- Use Pydantic models for data validation
- Use `Optional[T]` for nullable types
- Use `List[T]`, `Dict[K, V]` for collections

Example:
```python
def get_request_by_id(request_id: int) -> Optional[StudentRequest]:
    """Fetch a student request by ID."""
    pass
```

### Best Practices

- Use list comprehensions for simple transformations
- Use f-strings for string formatting
- Keep functions small and focused (max 50 lines)
- Use descriptive variable names
- Avoid mutable default arguments
- Use context managers (`with` statements) for resource management

### Error Handling

- Use specific exception types
- Raise HTTPException for API errors with appropriate status codes
- Log exceptions with full context
- Provide meaningful error messages

## General Standards

### Documentation

- All public functions must have docstrings
- Use clear, concise comments for complex logic
- Keep comments up-to-date with code changes
- Document "why" not "what" (code should be self-documenting)

### Code Review Checklist

Before submitting code:
- [ ] Code follows language-specific style guide
- [ ] All functions have appropriate type hints/declarations
- [ ] No hardcoded values (use constants or configuration)
- [ ] Error handling is appropriate
- [ ] Security considerations addressed (XSS, injection, etc.)
- [ ] Code is DRY (Don't Repeat Yourself)
- [ ] Tests are included and passing
- [ ] Documentation is updated

### Git Commit Standards

- Use clear, descriptive commit messages
- Start with verb in present tense (e.g., "Add", "Fix", "Update")
- Reference issue/task numbers when applicable
- Keep commits focused on single changes

Example:
```
Add API client for fetching student requests

- Implement ApiClient class with fetchRequests method
- Add error handling and fallback to stub data
- Update RequestsController to use ApiClient
- Refs: Task 7
```

## Linting and Formatting

### Pre-commit Checks

All code must pass linting before commit:

**PHP:**
```bash
php-cs-fixer fix --dry-run --diff
```

**Python:**
```bash
black --check .
flake8 .
mypy .
```

### IDE Configuration

Recommended IDE settings:
- Enable format on save
- Enable linting
- Show whitespace characters
- Trim trailing whitespace on save
- Insert final newline

## Performance Considerations

- Avoid N+1 queries
- Use appropriate data structures (dict for lookups, list for iteration)
- Cache expensive computations when appropriate
- Profile before optimizing
- Optimize for readability first, performance second

## Security Standards

- Never commit secrets or credentials
- Use environment variables for configuration
- Validate all user input
- Escape all output
- Use parameterized queries (when applicable)
- Keep dependencies up-to-date
- Follow principle of least privilege

## Maintenance

These standards are living documents. Suggest improvements through pull requests or team discussions.
