# Requirements Document

## Introduction

The LGK Brick Management System is a modular, role-based workflow platform that digitizes the complete brick order flow from order capture to delivery and payment approval. The system uses a single shared database to provide real-time visibility across Sales, Logistics, and Accounts departments while maintaining a reliable audit trail for all transactions.

## Glossary

- **LGK_System**: The complete brick management platform including all modules and user interfaces
- **Sales_Executive**: User role responsible for capturing customer orders and monitoring order progression
- **Logistics_User**: User role handling order assignment, vehicle allocation, and delivery completion
- **Accounts_User**: User role managing payment lifecycle and generating financial reports
- **Admin_User**: Super user with full access across all modules and configuration capabilities
- **Requisition**: A customer order captured by Sales Executive containing brick type, quantity, and customer details
- **Delivery_Challan**: Physical delivery document created by Logistics with vehicle and delivery information
- **Payment_Record**: Financial record attached to a challan tracking payment status and amounts
- **Brick_Type**: Product master record containing brick specifications, pricing, and availability status
- **Order_Number**: Auto-generated sequential identifier for requisitions
- **Challan_Number**: Auto-generated sequential identifier for delivery challans

## Requirements

### Requirement 1

**User Story:** As an Admin, I want to manage system users and their access permissions, so that I can control who can access different parts of the system and maintain security.

#### Acceptance Criteria

1. WHEN an Admin creates a new employee account, THE LGK_System SHALL generate a unique user record with email, role, department, and active status
2. WHEN an Admin assigns a role to a user, THE LGK_System SHALL enforce role-based permissions for all system access
3. WHEN an Admin deactivates a user account, THE LGK_System SHALL prevent that user from logging into the system
4. WHERE role permissions are configured, THE LGK_System SHALL store permissions as JSON data for flexible access control
5. WHEN viewing user records, THE LGK_System SHALL display who created each employee account for audit purposes

### Requirement 2

**User Story:** As an Admin, I want to manage the brick catalog and pricing, so that Sales Executives can select from current products with accurate pricing.

#### Acceptance Criteria

1. WHEN an Admin creates a brick type, THE LGK_System SHALL store brick name, description, current price, unit, category, and status
2. WHEN an Admin updates brick pricing, THE LGK_System SHALL apply the new price to all future requisitions
3. WHEN an Admin deactivates a brick type, THE LGK_System SHALL remove it from Sales Executive selection options
4. WHILE a brick type is active, THE LGK_System SHALL display it in the Sales Executive brick dropdown
5. WHEN storing brick information, THE LGK_System SHALL validate that all required fields are present and properly formatted

### Requirement 3

**User Story:** As a Sales Executive, I want to create customer requisitions with auto-calculated totals, so that I can efficiently capture orders without manual calculations.

#### Acceptance Criteria

1. WHEN a Sales Executive creates a requisition, THE LGK_System SHALL auto-generate a sequential order number and current date
2. WHEN a Sales Executive selects brick type and enters quantity, THE LGK_System SHALL auto-calculate the total amount using current brick pricing
3. WHEN a Sales Executive submits a requisition, THE LGK_System SHALL prevent further modifications to that order
4. WHILE entering requisition details, THE LGK_System SHALL validate that all required customer information is provided
5. WHEN viewing requisitions, THE LGK_System SHALL show only orders created by the current Sales Executive

### Requirement 4

**User Story:** As a Logistics User, I want to view pending orders and create delivery challans, so that I can efficiently manage order fulfillment and vehicle assignments.

#### Acceptance Criteria

1. WHEN a Logistics User accesses the pending orders queue, THE LGK_System SHALL display all submitted requisitions not yet assigned to delivery
2. WHEN a Logistics User creates a delivery challan, THE LGK_System SHALL auto-fill order and customer details from the selected requisition
3. WHEN a Logistics User enters vehicle information, THE LGK_System SHALL store vehicle details and optional remarks with the challan
4. WHEN a delivery challan is printed, THE LGK_System SHALL generate a formatted delivery document with all required information
5. WHEN a delivery is completed, THE LGK_System SHALL move the order to Accounts for payment processing

### Requirement 5

**User Story:** As an Accounts User, I want to track payment status for delivered orders, so that I can manage cash flow and ensure proper payment collection.

#### Acceptance Criteria

1. WHEN an Accounts User views the payment dashboard, THE LGK_System SHALL display all delivered challans with payment status and key details
2. WHEN an Accounts User updates payment status, THE LGK_System SHALL validate that payment amounts do not exceed the total order amount
3. WHEN a payment record is approved, THE LGK_System SHALL lock the record to prevent further modifications
4. WHILE tracking payments, THE LGK_System SHALL maintain payment states of Pending, Partially Paid, Paid, and Approved
5. WHEN payment information is updated, THE LGK_System SHALL store payment method, reference number, and optional remarks

### Requirement 6

**User Story:** As an Accounts User, I want to generate financial reports with export capabilities, so that I can analyze business performance and share data with stakeholders.

#### Acceptance Criteria

1. WHEN an Accounts User generates a daily report, THE LGK_System SHALL calculate total delivered orders, expected amounts, and received amounts for that date
2. WHEN an Accounts User generates a date range report, THE LGK_System SHALL aggregate financial data across the specified period
3. WHEN displaying report data, THE LGK_System SHALL show breakdown by payment status and outstanding amounts
4. WHERE export functionality is requested, THE LGK_System SHALL generate reports in both PDF and Excel formats
5. WHEN calculating financial totals, THE LGK_System SHALL ensure accuracy across all payment status categories

### Requirement 7

**User Story:** As a system user, I want secure authentication and role-based access, so that I can only access features appropriate to my role and department.

#### Acceptance Criteria

1. WHEN a user attempts to log in, THE LGK_System SHALL validate credentials against stored user accounts with active status
2. WHEN a user accesses system features, THE LGK_System SHALL enforce permissions based on their assigned role
3. WHEN user sessions are established, THE LGK_System SHALL maintain session security throughout system usage
4. WHERE unauthorized access is attempted, THE LGK_System SHALL deny access and maintain system security
5. WHEN users interact with data, THE LGK_System SHALL ensure they can only view and modify data appropriate to their role

### Requirement 8

**User Story:** As a system administrator, I want reliable data integrity and audit trails, so that all transactions are properly tracked and the system maintains accurate records.

#### Acceptance Criteria

1. WHEN any data modification occurs, THE LGK_System SHALL maintain referential integrity across all related tables
2. WHEN orders progress through workflow stages, THE LGK_System SHALL update status fields consistently across all related records
3. WHEN financial calculations are performed, THE LGK_System SHALL ensure mathematical accuracy in all amount computations
4. WHERE data relationships exist, THE LGK_System SHALL enforce foreign key constraints to prevent orphaned records
5. WHEN system operations complete, THE LGK_System SHALL maintain complete audit trails for all user actions

### Requirement 9

**User Story:** As a system user, I want responsive API endpoints for all operations, so that the system can handle the expected transaction volume efficiently.

#### Acceptance Criteria

1. WHEN processing up to 5000 orders per month, THE LGK_System SHALL maintain acceptable response times for all API operations
2. WHEN multiple users access the system concurrently, THE LGK_System SHALL handle concurrent operations without data corruption
3. WHEN API requests are made, THE LGK_System SHALL return appropriate HTTP status codes and error messages
4. WHERE database operations are performed, THE LGK_System SHALL optimize queries for performance at expected load levels
5. WHEN system resources are utilized, THE LGK_System SHALL operate efficiently without requiring advanced caching or WebSocket features