# LGK Brick Management System - Design Document

## Overview

The LGK Brick Management System is a Laravel-based REST API that implements a role-based workflow for managing brick orders from initial capture through delivery and payment approval. The system follows a clean architecture pattern with clear separation between controllers, services, repositories, and models, ensuring maintainability and testability.

The core workflow involves three main user roles: Sales Executives create requisitions, Logistics users generate delivery challans and manage deliveries, and Accounts users track payments and generate reports. An Admin role provides system configuration and user management capabilities.

## Architecture

### Technology Stack
- **Backend Framework**: Laravel 10.x
- **Database**: MySQL 8.0
- **Authentication**: Laravel Sanctum for API token authentication
- **Validation**: Laravel Form Request validation
- **Testing**: PHPUnit with Laravel testing utilities
- **API Documentation**: Laravel API Resources for consistent response formatting

### Architectural Patterns
- **Repository Pattern**: Data access abstraction for testability and flexibility
- **Service Layer**: Business logic encapsulation separate from controllers
- **Resource Pattern**: Consistent API response formatting using Laravel API Resources
- **Request Validation**: Form Request classes for input validation and authorization
- **Model Relationships**: Eloquent ORM relationships for data integrity

### Directory Structure
```
app/
├── Http/
│   ├── Controllers/Api/
│   ├── Requests/
│   └── Resources/
├── Models/
├── Services/
├── Repositories/
└── Exceptions/
database/
├── migrations/
└── seeders/
tests/
├── Feature/
└── Unit/
```

## Components and Interfaces

### Core Models and Relationships

**User Model**
- Manages employee accounts with role and department assignments
- Relationships: belongsTo Role, belongsTo Department, hasMany Requisitions (for Sales)
- Attributes: email (unique), password, role_id, department_id, status, created_by

**Role Model**
- Defines system roles with JSON permissions for flexible access control
- Relationships: hasMany Users
- Attributes: name, permissions (JSON), description

**Department Model**
- Groups users for organizational reporting
- Relationships: hasMany Users
- Attributes: name, description

**BrickType Model**
- Product master containing brick specifications and pricing
- Relationships: hasMany Requisitions
- Attributes: name, description, current_price, unit, category, status

**Requisition Model**
- Customer orders with auto-generated sequential numbering
- Relationships: belongsTo User, belongsTo BrickType, hasOne DeliveryChallan
- Attributes: order_number, date, quantity, price_per_unit, total_amount, customer details, status

**DeliveryChallan Model**
- Delivery documents with vehicle and logistics information
- Relationships: belongsTo Requisition, hasOne Payment
- Attributes: challan_number, order_number, date, vehicle_info, location, remarks, delivery_status, delivery_date

**Payment Model**
- Financial records tracking payment lifecycle
- Relationships: belongsTo DeliveryChallan
- Attributes: payment_status, total_amount, amount_received, remaining_amount, payment_date, payment_method, reference_number, remarks

### API Controllers

**AuthController**
- POST /api/login - User authentication with role-based token generation
- POST /api/logout - Token revocation
- GET /api/user - Current user profile with role and permissions

**UserController** (Admin only)
- GET /api/users - List all users with filtering by role/department
- POST /api/users - Create new employee account
- PUT /api/users/{id} - Update user details and status
- DELETE /api/users/{id} - Deactivate user account

**BrickTypeController** (Admin only)
- GET /api/brick-types - List active brick types for selection
- POST /api/brick-types - Create new brick type
- PUT /api/brick-types/{id} - Update brick details and pricing
- PATCH /api/brick-types/{id}/status - Activate/deactivate brick type

**RequisitionController**
- GET /api/requisitions - List requisitions (filtered by role: Sales sees own, others see all)
- POST /api/requisitions - Create new requisition (Sales Executive only)
- GET /api/requisitions/{id} - View requisition details
- GET /api/requisitions/pending - Pending orders queue (Logistics only)

**DeliveryChallanController** (Logistics only)
- POST /api/delivery-challans - Create challan from requisition
- GET /api/delivery-challans/{id} - View challan details
- PUT /api/delivery-challans/{id} - Update delivery status
- GET /api/delivery-challans/{id}/print - Generate printable challan

**PaymentController** (Accounts only)
- GET /api/payments - Payment tracking dashboard
- PUT /api/payments/{id} - Update payment status and amounts
- GET /api/payments/reports - Generate financial reports
- GET /api/payments/reports/export - Export reports (PDF/Excel)

### Service Classes

**RequisitionService**
- validateTotalAmount(): Validates frontend-calculated totals against current brick pricing
- validateRequisitionData(): Business rule validation including price and total verification
- createRequisition(): Handles requisition creation with database-generated order numbers
- checkBrickPriceChanges(): Verifies submitted price matches current brick pricing

**ChallanService**
- createChallanFromRequisition(): Creates challan with database-generated sequential numbers
- validateRequisitionForChallan(): Validates requisition eligibility for challan creation
- updateDeliveryStatus(): Manages delivery workflow states
- generatePrintableDocument(): Creates formatted challan for printing

**PaymentService**
- validatePaymentAmount(): Ensures payments don't exceed order totals
- updatePaymentStatus(): Manages payment state transitions
- calculateOutstandingAmounts(): Computes remaining balances
- lockApprovedPayments(): Prevents modification of approved records

**ReportService**
- generateDailyReport(): Creates daily financial summaries
- generateRangeReport(): Creates date range financial analysis
- exportToPDF(): Generates PDF reports
- exportToExcel(): Generates Excel reports

## Data Models

### Database Schema Design

**users table**
```sql
id (primary key)
email (unique)
password
role_id (foreign key to roles)
department_id (foreign key to departments)
status (enum: active, inactive)
created_by (foreign key to users)
created_at, updated_at
```

**roles table**
```sql
id (primary key)
name (unique)
permissions (JSON)
description
created_at, updated_at
```

**departments table**
```sql
id (primary key)
name (unique)
description
created_at, updated_at
```

**brick_types table**
```sql
id (primary key)
name
description
current_price (decimal)
unit
category
status (enum: active, inactive)
created_at, updated_at
```

**requisitions table**
```sql
id (primary key)
order_number (unique, database-generated sequence)
date (auto-filled)
user_id (foreign key to users - Sales Executive)
brick_type_id (foreign key to brick_types)
quantity (decimal)
price_per_unit (decimal, validated against current brick price)
total_amount (decimal, frontend-calculated, backend-validated)
customer_name
customer_phone
customer_address
customer_location
status (enum: submitted, assigned, delivered, paid, complete)
created_at, updated_at
```

**delivery_challans table**
```sql
id (primary key)
challan_number (unique, database-generated sequence)
requisition_id (foreign key to requisitions)
order_number (copied from requisitions table for easy reference)
date (auto-filled)
vehicle_number
driver_name
vehicle_type
location
remarks (text, optional)
delivery_status (enum: pending, assigned, in_transit, delivered, failed)
delivery_date
print_count (integer, default 0)
created_at, updated_at
```

**payments table**
```sql
id (primary key)
delivery_challan_id (foreign key to delivery_challans)
payment_status (enum: pending, partial, paid, approved, overdue)
total_amount (decimal)
amount_received (decimal, default 0)
remaining_amount (decimal, computed)
payment_date
payment_method (enum: cash, cheque, bank_transfer, upi)
reference_number
remarks (text, optional)
approved_by (foreign key to users, nullable)
approved_at (timestamp, nullable)
created_at, updated_at
```

### Data Integrity Constraints
- Foreign key relationships enforce referential integrity
- Unique constraints on email, order_number, challan_number
- Check constraints ensure amount_received <= total_amount
- Enum constraints validate status field values
- NOT NULL constraints on required business fields

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, several properties can be consolidated to eliminate redundancy:

- User creation and role assignment properties (1.1, 1.2) can be combined into comprehensive user management properties
- Authentication and authorization properties (7.1, 7.2, 7.4, 7.5) overlap significantly and can be consolidated
- Data integrity properties (8.1, 8.4) are closely related and can be combined
- Financial calculation properties (3.2, 6.5, 8.3) test similar mathematical accuracy concerns

### Core Properties

**Property 1: User Account Management Integrity**
*For any* user creation or modification operation, the system should maintain unique email constraints, proper role assignments, and accurate audit trails while enforcing status-based access control
**Validates: Requirements 1.1, 1.3, 1.5**

**Property 2: Role-Based Access Control**
*For any* system operation, users should only be able to access endpoints and data appropriate to their assigned role, with proper authentication and authorization enforcement
**Validates: Requirements 1.2, 7.1, 7.2, 7.4, 7.5**

**Property 3: Brick Type Management Consistency**
*For any* brick type operation, the system should maintain proper field storage, enforce active/inactive filtering in selection lists, and apply pricing changes only to future requisitions
**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

**Property 4: Input Validation Completeness**
*For any* data input operation, the system should validate all required fields are present and properly formatted, returning appropriate error messages for invalid data
**Validates: Requirements 2.5, 3.4**

**Property 5: Sequential Number Generation**
*For any* requisition or challan creation, the system should generate unique sequential numbers that maintain proper ordering and prevent duplicates
**Validates: Requirements 3.1**

**Property 6: Frontend-Backend Calculation Validation**
*For any* requisition submission with frontend-calculated totals, the backend should validate that submitted amounts match current brick pricing and correct mathematical calculations
**Validates: Requirements 3.2, 6.5, 8.3**

**Property 7: Record Immutability After State Transitions**
*For any* record that reaches a final state (submitted requisitions, approved payments), the system should prevent further modifications while maintaining data integrity
**Validates: Requirements 3.3, 5.3**

**Property 8: Data Filtering by User Context**
*For any* data retrieval operation, the system should filter results based on user role and ownership, ensuring users see only appropriate data
**Validates: Requirements 3.5, 4.1, 5.1**

**Property 9: Workflow State Management**
*For any* order progressing through workflow stages, the system should maintain consistent status updates across all related records and enforce proper state transitions
**Validates: Requirements 4.5, 5.4, 8.2**

**Property 10: Data Propagation Between Related Records**
*For any* operation that creates related records (challan from requisition, payment from challan), the system should accurately copy all required data while maintaining referential integrity
**Validates: Requirements 4.2, 4.3**

**Property 11: Document Generation Completeness**
*For any* document generation operation (challan printing, report exports), the system should include all required information in the specified format
**Validates: Requirements 4.4, 6.4**

**Property 12: Payment Amount Validation**
*For any* payment operation, the system should enforce business rules that prevent payment amounts from exceeding order totals while maintaining accurate balance calculations
**Validates: Requirements 5.2**

**Property 13: Financial Report Accuracy**
*For any* report generation operation, the system should calculate accurate totals, breakdowns, and aggregations across specified date ranges and payment statuses
**Validates: Requirements 6.1, 6.2, 6.3**

**Property 14: Database Referential Integrity**
*For any* database operation, the system should maintain foreign key relationships and prevent orphaned records while ensuring data consistency
**Validates: Requirements 8.1, 8.4**

**Property 15: Concurrent Operation Safety**
*For any* concurrent system operations, the system should handle multiple users safely without data corruption or race conditions
**Validates: Requirements 9.2**

**Property 16: API Response Consistency**
*For any* API request, the system should return appropriate HTTP status codes, error messages, and response formats according to REST conventions
**Validates: Requirements 9.3**

## Error Handling

### Validation Errors
- **Input Validation**: All API endpoints use Laravel Form Request classes for comprehensive input validation
- **Business Rule Validation**: Service layer enforces business rules like payment limits and status transitions
- **Database Constraints**: Foreign key and unique constraints prevent data integrity violations
- **Authentication Errors**: Proper HTTP 401/403 responses for authentication and authorization failures

### Exception Handling Strategy
- **Custom Exception Classes**: Domain-specific exceptions for business rule violations
- **Global Exception Handler**: Centralized error response formatting and logging
- **Validation Exception Handling**: Structured error responses for form validation failures
- **Database Exception Handling**: Graceful handling of constraint violations and connection issues

### Standardized API Response Format

**Success Response Format:**
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": {
    "resource_name": { ... }
  }
}
```

**Error Response Format:**
```json
{
  "status": "fail",
  "message": "Operation failed",
  "errors": {
    "field_name": ["Specific validation error"]
  }
}
```

**Business Rule Violation Format:**
```json
{
  "status": "fail", 
  "message": "Business rule violation",
  "errors": {
    "total_amount": ["Total amount calculation is incorrect"],
    "brick_price": ["Brick price has changed. Please refresh and try again."]
  }
}
```

## Testing Strategy

### Dual Testing Approach

The system requires both unit testing and property-based testing to ensure comprehensive coverage:

- **Unit tests** verify specific examples, edge cases, and error conditions
- **Property tests** verify universal properties that should hold across all inputs
- Together they provide comprehensive coverage: unit tests catch concrete bugs, property tests verify general correctness

### Unit Testing Requirements

Unit tests will cover:
- Specific examples that demonstrate correct behavior
- Integration points between components  
- Edge cases like empty inputs, boundary values, and error conditions
- Authentication and authorization workflows
- API endpoint responses and status codes

Unit tests should be focused and avoid over-testing since property-based tests handle broad input coverage.

### Property-Based Testing Requirements

**Testing Framework**: PHPUnit with Eris library for property-based testing in PHP
**Test Configuration**: Each property-based test must run a minimum of 100 iterations
**Test Tagging**: Each property-based test must include a comment with the exact format: '**Feature: lgk-brick-management, Property {number}: {property_text}**'
**Property Implementation**: Each correctness property must be implemented by a single property-based test
**Generator Strategy**: Smart generators that constrain to valid input spaces for realistic testing

### Testing Requirements Summary

- Property-based tests must be tagged with comments explicitly referencing the correctness property in the design document
- Each correctness property must be implemented by a single property-based test
- Property-based tests should run a minimum of 100 iterations for thorough random testing
- Unit tests and property tests are complementary and both must be included in the implementation
- Testing should focus on core functional logic without requiring mocks or fake data