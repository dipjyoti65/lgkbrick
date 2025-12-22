# Project Structure & Architecture Patterns

## Laravel Directory Structure

### Core Application (`app/`)
```
app/
├── Http/
│   ├── Controllers/Api/     # API controllers for each domain
│   ├── Middleware/          # Custom middleware (CheckRole, etc.)
│   ├── Requests/           # Form request validation classes
│   ├── Resources/          # API resource transformers
│   └── Responses/          # Standardized API response classes
├── Models/                 # Eloquent models with relationships
├── Services/              # Business logic layer
├── Repositories/          # Data access layer (currently empty)
└── Exceptions/           # Custom exception classes
```

## Architecture Patterns

### Service Layer Pattern
- **Services** contain business logic and validation
- Controllers delegate to services for complex operations
- Example: `RequisitionService` handles order creation with price validation

### API Resource Pattern
- **Resources** provide consistent JSON response formatting
- All API responses use resource classes for transformation
- Example: `RequisitionResource` standardizes requisition data output

### Repository Pattern (Prepared)
- Repository folder exists for future data access abstraction
- Currently using Eloquent directly in services

### Role-Based Access Control
- **Middleware**: `CheckRole` validates user permissions
- **Routes**: Grouped by role with middleware protection
- **Models**: User model has role and department relationships

## Key Conventions

### API Structure
- All API routes prefixed with `/api/`
- RESTful resource controllers for CRUD operations
- Consistent response format using `BaseApiResponse`

### Model Relationships
- **User** → Role, Department (belongs to)
- **Requisition** → User, BrickType (belongs to)
- **DeliveryChallan** → Requisition (belongs to)
- **Payment** → DeliveryChallan (belongs to)

### Status Management
- Models use const values for status enums
- Status transition validation in model methods
- Immutability enforcement for submitted records

### Testing Structure
```
tests/
├── Feature/               # Integration tests for API endpoints
├── Unit/                 # Unit tests for models, services, resources
└── TestCase.php          # Base test class with common setup
```

### Database Conventions
- Migration files follow Laravel naming conventions
- Foreign key constraints and indexes properly defined
- Seeders provide default data for roles, departments, and sample records

## File Naming Patterns
- **Controllers**: `{Domain}Controller.php` (e.g., `RequisitionController.php`)
- **Services**: `{Domain}Service.php` (e.g., `RequisitionService.php`)
- **Resources**: `{Domain}Resource.php` and `{Domain}Collection.php`
- **Models**: Singular names matching table names
- **Tests**: `{Class}Test.php` for unit tests, `{Feature}Test.php` for feature tests