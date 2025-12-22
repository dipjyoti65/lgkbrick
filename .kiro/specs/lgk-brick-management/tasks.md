# Implementation Plan

- [x] 1. Set up Laravel project structure and core configuration










  - Initialize Laravel 10.x project with MySQL database configuration
  - Configure Laravel Sanctum for API authentication
  - Set up basic directory structure for repositories, services, and resources
  - Configure PHPUnit testing environment with Eris for property-based testing
  - _Requirements: 7.1, 7.3_

- [x] 2. Create database migrations and core models





  - [x] 2.1 Create migration for roles table with JSON permissions


    - Define roles table structure with name, permissions (JSON), description
    - Create Role model with appropriate fillable fields and casts
    - _Requirements: 1.4_

  - [x] 2.2 Create migration for departments table


    - Define departments table structure with name and description
    - Create Department model with basic configuration
    - _Requirements: 1.1_

  - [x] 2.3 Create migration for users table with role and department relationships


    - Define users table with email, password, role_id, department_id, status, created_by
    - Create User model with relationships to Role and Department
    - Implement unique email constraint and status enum
    - _Requirements: 1.1, 1.3, 1.5_

  - [ ]* 2.4 Write property test for user account management integrity
    - **Property 1: User Account Management Integrity**
    - **Validates: Requirements 1.1, 1.3, 1.5**

  - [x] 2.5 Create migration for brick_types table


    - Define brick_types table with name, description, current_price, unit, category, status
    - Create BrickType model with status enum and price casting
    - _Requirements: 2.1, 2.3_

  - [ ]* 2.6 Write property test for brick type management consistency
    - **Property 3: Brick Type Management Consistency**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4**

- [x] 3. Implement authentication and authorization system




  - [x] 3.1 Create authentication controller and routes


    - Implement login endpoint with credential validation
    - Implement logout endpoint with token revocation
    - Create user profile endpoint with role information
    - _Requirements: 7.1, 7.3_

  - [x] 3.2 Create role-based middleware for API protection


    - Implement middleware to check user roles and permissions
    - Create permission checking logic using JSON permissions
    - Apply middleware to appropriate routes
    - _Requirements: 1.2, 7.2_

  - [ ]* 3.3 Write property test for role-based access control
    - **Property 2: Role-Based Access Control**
    - **Validates: Requirements 1.2, 7.1, 7.2, 7.4, 7.5**

  - [ ]* 3.4 Write unit tests for authentication endpoints
    - Test login with valid/invalid credentials
    - Test logout functionality
    - Test user profile retrieval
    - _Requirements: 7.1, 7.3_

- [x] 4. Create user management system (Admin functionality)





  - [x] 4.1 Implement UserController with CRUD operations


    - Create endpoints for listing, creating, updating, and deactivating users
    - Implement user filtering by role and department
    - Add validation for user creation and updates
    - _Requirements: 1.1, 1.3_

  - [x] 4.2 Create UserService for business logic


    - Implement user creation with audit trail (created_by)
    - Implement user deactivation logic
    - Add role assignment validation
    - _Requirements: 1.1, 1.5_

  - [x] 4.3 Create Form Request classes for user validation


    - Implement CreateUserRequest with validation rules
    - Implement UpdateUserRequest with validation rules
    - Add unique email validation and role existence checks
    - _Requirements: 1.1_

  - [ ]* 4.4 Write property test for input validation completeness
    - **Property 4: Input Validation Completeness**
    - **Validates: Requirements 2.5, 3.4**

- [x] 5. Implement brick type management (Admin functionality)





  - [x] 5.1 Create BrickTypeController with CRUD operations


    - Implement endpoints for managing brick types
    - Add filtering for active brick types in selection lists
    - Create status update endpoint for activation/deactivation
    - _Requirements: 2.1, 2.3, 2.4_

  - [x] 5.2 Create BrickTypeService for pricing and status management


    - Implement brick type creation and updates
    - Add logic for price change handling
    - Implement active/inactive filtering for Sales Executive dropdowns
    - _Requirements: 2.2, 2.3, 2.4_

  - [ ]* 5.3 Write unit tests for brick type management
    - Test brick type CRUD operations
    - Test active/inactive filtering
    - Test price update functionality
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 6. Create requisition system (Sales Executive functionality)





  - [x] 6.1 Create migration for requisitions table


    - Define requisitions table with order_number, date, user_id, brick_type_id
    - Add quantity, price_per_unit, total_amount, customer details, status fields
    - Implement unique order_number constraint and foreign key relationships
    - _Requirements: 3.1, 3.2_



  - [x] 6.2 Create Requisition model with relationships and calculations





    - Implement relationships to User and BrickType
    - Add automatic total_amount calculation


    - Implement status enum for workflow tracking
    - _Requirements: 3.1, 3.2, 8.2_

  - [x] 6.3 Implement RequisitionController for order creation





    - Create endpoint for requisition creation with frontend total validation


    - Implement requisition listing with user-based filtering
    - Add requisition detail view endpoint
    - Add brick price checking endpoint for frontend validation
    - _Requirements: 3.1, 3.2, 3.5_

  - [x] 6.4 Create RequisitionService for business logic





    - Implement database-level order number generation (approach 2)
    - Add frontend total amount validation against current brick pricing
    - Implement price change detection and validation
    - Implement requisition creation with immutability enforcement
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ]* 6.5 Write property test for database-level sequential number generation
    - **Property 5: Sequential Number Generation**
    - **Validates: Requirements 3.1**

  - [ ]* 6.6 Write property test for frontend-backend calculation validation
    - **Property 6: Frontend-Backend Calculation Validation**
    - **Validates: Requirements 3.2, 6.5, 8.3**

  - [ ]* 6.7 Write property test for record immutability after state transitions
    - **Property 7: Record Immutability After State Transitions**
    - **Validates: Requirements 3.3, 5.3**

  - [ ]* 6.8 Write property test for data filtering by user context
    - **Property 8: Data Filtering by User Context**
    - **Validates: Requirements 3.5, 4.1, 5.1**

- [x] 7. Checkpoint - Ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement delivery challan system (Logistics functionality)





  - [x] 8.1 Create migration for delivery_challans table


    - Define delivery_challans table with database-generated challan_number, requisition_id, order_number, date
    - Add vehicle_number, driver_name, vehicle_type, location, remarks fields
    - Add delivery_status, delivery_date, print_count fields
    - Copy order_number from requisitions table for easy reference and reporting
    - Implement unique challan_number constraint and foreign key relationships
    - _Requirements: 4.2, 4.3_

  - [x] 8.2 Create DeliveryChallan model with relationships


    - Implement relationship to Requisition
    - Add delivery status enum and date handling
    - Implement print tracking functionality
    - _Requirements: 4.2, 4.4_

  - [x] 8.3 Implement DeliveryChallanController for logistics operations


    - Create endpoint for challan creation from requisition
    - Implement pending orders queue for Logistics users
    - Add challan detail view and delivery status updates
    - Create printable challan generation endpoint
    - _Requirements: 4.1, 4.2, 4.4, 4.5_

  - [x] 8.4 Create ChallanService for workflow management

    - Implement database-level challan number generation (approach 2)
    - Add auto-fill functionality from requisition data with validation
    - Implement delivery status management and workflow transitions
    - Create printable document generation logic
    - _Requirements: 4.2, 4.4, 4.5_

  - [ ]* 8.5 Write property test for workflow state management
    - **Property 9: Workflow State Management**
    - **Validates: Requirements 4.5, 5.4, 8.2**

  - [ ]* 8.6 Write property test for data propagation between related records
    - **Property 10: Data Propagation Between Related Records**
    - **Validates: Requirements 4.2, 4.3**

  - [ ]* 8.7 Write property test for document generation completeness
    - **Property 11: Document Generation Completeness**
    - **Validates: Requirements 4.4, 6.4**

- [x] 9. Create payment tracking system (Accounts functionality)





  - [x] 9.1 Create migration for payments table


    - Define payments table with delivery_challan_id, payment_status
    - Add total_amount, amount_received, remaining_amount fields
    - Add payment_date, payment_method, reference_number, remarks fields
    - Add approved_by, approved_at fields for approval workflow
    - _Requirements: 5.1, 5.2, 5.5_

  - [x] 9.2 Create Payment model with business logic


    - Implement relationship to DeliveryChallan
    - Add payment status enum and amount validation
    - Implement approval workflow with locking mechanism
    - _Requirements: 5.2, 5.3, 5.4_

  - [x] 9.3 Implement PaymentController for accounts operations


    - Create payment dashboard endpoint with delivered challans
    - Implement payment status update endpoint with validation
    - Add payment detail view and history tracking
    - _Requirements: 5.1, 5.2, 5.4_

  - [x] 9.4 Create PaymentService for financial logic


    - Implement payment amount validation against order totals
    - Add payment status transition management
    - Implement approval workflow with record locking
    - Create outstanding amount calculations
    - _Requirements: 5.2, 5.3, 5.4_

  - [ ]* 9.5 Write property test for payment amount validation
    - **Property 12: Payment Amount Validation**
    - **Validates: Requirements 5.2**

- [x] 10. Implement financial reporting system





  - [x] 10.1 Create ReportController for financial reports


    - Implement daily report generation endpoint
    - Create date range report generation endpoint
    - Add report export endpoints for PDF and Excel formats
    - _Requirements: 6.1, 6.2, 6.4_

  - [x] 10.2 Create ReportService for report calculations


    - Implement daily financial summary calculations
    - Add date range aggregation logic
    - Create payment status breakdown calculations
    - Implement PDF and Excel export functionality
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ]* 10.3 Write property test for financial report accuracy
    - **Property 13: Financial Report Accuracy**
    - **Validates: Requirements 6.1, 6.2, 6.3**

- [-] 11. Implement data integrity and audit features



  - [x] 11.1 Add database constraints and foreign key relationships


    - Implement foreign key constraints across all tables
    - Add check constraints for amount validations
    - Create database indexes for performance optimization
    - _Requirements: 8.1, 8.4_

  - [x] 11.2 Create audit trail functionality


    - Implement audit logging for all user actions
    - Add created_by tracking across all models
    - Create audit trail viewing capabilities for Admin users
    - _Requirements: 8.5_

  - [ ]* 11.3 Write property test for database referential integrity
    - **Property 14: Database Referential Integrity**
    - **Validates: Requirements 8.1, 8.4**

- [x] 12. Add standardized API response formatting and error handling




  - [x] 12.1 Create standardized API response structure


    - Implement BaseApiResponse class with status, message, data format
    - Create API Resource classes with standardized response wrapper
    - Implement UserResource, BrickTypeResource, RequisitionResource
    - Create DeliveryChallanResource, PaymentResource, ReportResource
    - _Requirements: 9.3_



  - [x] 12.2 Implement global exception handling with standardized responses





    - Create custom exception classes for business rule violations
    - Implement global exception handler returning standardized error format
    - Add validation exception formatting with status/message/errors structure
    - Create specific exceptions for price changes and calculation mismatches
    - _Requirements: 9.3_

  - [ ]* 12.3 Write property test for concurrent operation safety
    - **Property 15: Concurrent Operation Safety**
    - **Validates: Requirements 9.2**

  - [ ]* 12.4 Write property test for API response consistency
    - **Property 16: API Response Consistency**
    - **Validates: Requirements 9.3**

- [x] 13. Create database seeders for initial data





  - [x] 13.1 Create role and department seeders


    - Implement seeder for default roles (Admin, Sales Executive, Logistics, Accounts)
    - Create seeder for departments (Sales, Logistics, Accounts)
    - Add default Admin user creation
    - _Requirements: 1.1, 1.2_

  - [x] 13.2 Create sample data seeders for testing


    - Implement brick type sample data seeder
    - Create sample user accounts for each role
    - Add sample requisitions and challans for testing
    - _Requirements: 2.1_

- [x] 14. Final checkpoint - Complete system integration





  - Ensure all tests pass, ask the user if questions arise.