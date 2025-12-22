# LGK Brick Management Flutter Mobile App - Design Document

## Overview

The LGK Brick Management Flutter Mobile App is a cross-platform mobile application that provides a native mobile interface for the existing LGK Brick Management System. Built using Flutter framework with Provider state management, the app connects to the Laravel REST API backend and implements role-based access control with intuitive mobile-first user experience.

The app follows clean architecture principles with clear separation between presentation, business logic, and data layers. It supports offline functionality, push notifications, and responsive design for both phones and tablets while maintaining security and performance standards.

## Architecture

### Technology Stack
- **Mobile Framework**: Flutter 3.10+
- **State Management**: Provider pattern with ChangeNotifier
- **HTTP Client**: Dio for robust API communication
- **Local Storage**: SharedPreferences and FlutterSecureStorage
- **Navigation**: GoRouter for declarative routing
- **Dependency Injection**: GetIt service locator
- **JSON Serialization**: json_annotation with code generation
- **Form Validation**: Formz for structured form validation

### Architectural Patterns
- **Clean Architecture**: Separation of concerns with presentation, business, and data layers
- **Provider Pattern**: Reactive state management with ChangeNotifier providers
- **Repository Pattern**: Data access abstraction for API and local storage
- **Service Layer**: Business logic encapsulation in provider classes
- **MVVM Pattern**: Model-View-ViewModel structure with providers as ViewModels

### Directory Structure
```
lib/
├── core/
│   ├── constants/          # App constants, API endpoints, colors
│   ├── theme/             # App theme and text styles
│   ├── utils/             # Utilities, validators, formatters
│   ├── exceptions/        # Custom exception classes
│   └── di/               # Dependency injection setup
├── data/
│   ├── models/           # Data models with JSON serialization
│   ├── repositories/     # Repository implementations
│   └── services/         # API service, storage service
├── business/
│   ├── providers/        # State management providers
│   └── notifiers/        # Simple state notifiers
└── presentation/
    ├── screens/          # Screen widgets organized by feature
    ├── widgets/          # Reusable UI components
    └── navigation/       # App routing configuration
```

## Components and Interfaces

### Core Models

**User Model**
- Manages user authentication and profile information
- Attributes: id, name, email, role, department, status, permissions
- Methods: hasPermission(), isActive, role-specific getters

**BrickType Model**
- Product master data with pricing information
- Attributes: id, name, description, currentPrice, unit, category, status
- Methods: isActive, priceAsDouble

**Requisition Model**
- Customer order data with auto-calculated totals
- Attributes: id, orderNumber, date, quantity, totalAmount, customerDetails, status
- Relationships: user, brickType, deliveryChallan

**DeliveryChallan Model**
- Delivery document with vehicle and logistics information
- Attributes: id, challanNumber, vehicleInfo, deliveryStatus, deliveryDate
- Relationships: requisition, payment

**Payment Model**
- Financial tracking with payment lifecycle management
- Attributes: id, totalAmount, amountReceived, paymentStatus, paymentMethod
- Methods: remainingAmount, isApproved

### Provider Classes (State Management)

**AuthProvider**
- Manages authentication state and user session
- Methods: login(), logout(), checkAuthStatus(), refreshToken()
- State: currentUser, isAuthenticated, isLoading

**UserManagementProvider** (Admin)
- Handles user CRUD operations and role management
- Methods: getUsers(), createUser(), updateUser(), deactivateUser()
- State: users, roles, departments, isLoading, selectedUser

**BrickTypeProvider** (Admin)
- Manages brick type catalog and pricing
- Methods: getBrickTypes(), createBrickType(), updateBrickType(), updateStatus()
- State: brickTypes, activeBrickTypes, isLoading, selectedBrickType

**RequisitionProvider** (Sales)
- Handles requisition creation and management
- Methods: createRequisition(), getRequisitions(), calculateTotal(), validatePrice()
- State: requisitions, currentRequisition, isLoading, validationErrors

**DeliveryChallanProvider** (Logistics)
- Manages delivery operations and status updates
- Methods: createChallan(), updateDeliveryStatus(), getPendingOrders()
- State: challans, pendingOrders, isLoading, selectedChallan

**PaymentProvider** (Accounts)
- Handles payment tracking and approval workflows
- Methods: updatePayment(), approvePayment(), generateReports()
- State: payments, reports, isLoading, selectedPayment

### Repository Classes

**AuthRepository**
- Handles authentication API calls and token management
- Methods: login(), logout(), getCurrentUser(), refreshToken()
- Integrates with StorageService for secure token storage

**UserRepository**
- Manages user-related API operations
- Methods: getUsers(), createUser(), updateUser(), getUserFormData()
- Handles filtering, pagination, and search functionality

**BrickTypeRepository**
- Handles brick type API operations
- Methods: getBrickTypes(), getActiveBrickTypes(), createBrickType(), updateBrickType()
- Manages pricing validation and status updates

**RequisitionRepository**
- Manages requisition API operations
- Methods: createRequisition(), getRequisitions(), getPendingRequisitions()
- Handles price validation and order number generation

**DeliveryChallanRepository**
- Handles delivery challan API operations
- Methods: createChallan(), updateDeliveryStatus(), getPendingOrders()
- Manages vehicle assignment and delivery tracking

**PaymentRepository**
- Manages payment API operations
- Methods: getPayments(), updatePayment(), approvePayment(), generateReports()
- Handles financial calculations and report generation

### Service Classes

**ApiService**
- Generic HTTP client with interceptors for authentication and error handling
- Methods: get(), post(), put(), patch(), delete(), downloadFile(), uploadFile()
- Features: automatic token injection, retry logic, error transformation

**StorageService**
- Local data persistence with secure storage for sensitive data
- Methods: saveToken(), getToken(), saveUser(), getUser(), cacheData()
- Features: encryption for sensitive data, cache management, offline support

**NetworkService**
- Network connectivity monitoring and management
- Methods: isConnected(), onConnectivityChanged(), retryFailedRequests()
- Features: connectivity detection, offline queue management

## Data Models

### Authentication Flow
```dart
class LoginRequest {
  final String email;
  final String password;
}

class LoginResponse {
  final User user;
  final String token;
}

class AuthState {
  final User? currentUser;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
}
```

### API Response Structure
```dart
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
}

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
}
```

### Form Validation Models
```dart
class RequisitionForm {
  final BrickTypeInput brickType;
  final QuantityInput quantity;
  final CustomerNameInput customerName;
  final CustomerPhoneInput customerPhone;
  final CustomerAddressInput customerAddress;
}

class ValidationState {
  final bool isValid;
  final Map<String, String> errors;
  final bool isSubmitting;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, several properties can be consolidated to eliminate redundancy:

- Authentication properties (1.1, 1.2, 1.3, 1.5) can be combined into comprehensive authentication flow properties
- Role-based UI properties (2.1, 2.2, 2.3, 2.4) are similar examples that can be tested with a single property
- Form validation properties (3.2, 4.2, 4.3, 6.2) test similar validation concerns and can be consolidated
- Data synchronization properties (3.5, 7.2, 7.3) overlap in sync behavior testing
- Notification properties (8.1, 8.2, 8.3) test similar notification logic

### Core Properties

**Property 1: Authentication Token Management**
*For any* valid user credentials, the authentication flow should securely store tokens, enable auto-login with valid tokens, handle token expiration gracefully, and clear all sensitive data on logout
**Validates: Requirements 1.1, 1.2, 1.3, 1.5**

**Property 2: Role-Based Dashboard Display**
*For any* authenticated user, the dashboard should display content and navigation options appropriate to their assigned role while hiding unauthorized features
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

**Property 3: Form Validation and Submission**
*For any* form input operation, the app should validate data according to business rules, display appropriate error messages, and prevent submission of invalid data
**Validates: Requirements 3.2, 4.2, 4.3, 4.4, 6.2**

**Property 4: Data Filtering by User Context**
*For any* data retrieval operation, users should only see data appropriate to their role and ownership, with proper filtering applied at the UI level
**Validates: Requirements 4.5, 2.5**

**Property 5: Real-time Data Synchronization**
*For any* data modification operation, changes should be immediately reflected in the UI and synchronized with the backend API while maintaining data consistency
**Validates: Requirements 3.5, 7.2, 7.3**

**Property 6: Error Handling and User Feedback**
*For any* error condition or loading state, the app should provide clear user feedback, appropriate error messages, and recovery options
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

**Property 7: Dropdown Data Freshness**
*For any* dropdown interaction, the app should fetch fresh data from the API to ensure users see the most current available options
**Validates: Requirements 8.3**

**Property 8: Responsive Layout Adaptation**
*For any* screen size or device type, the app should adapt layouts appropriately while maintaining usability and visual consistency
**Validates: Requirements 8.1, 8.2**

**Property 9: Form Input Validation and UX**
*For any* form input operation, the app should provide appropriate keyboard types, prevent duplicate submissions, and validate data before submission
**Validates: Requirements 8.4, 8.5**

**Property 10: Secure Token Storage**
*For any* authentication token, the app should store it securely using device security features and clear it appropriately during logout
**Validates: Requirements 9.1, 9.3, 9.4, 9.5**

**Property 11: Secure API Communication**
*For any* API communication, the app should use secure HTTPS connections and handle authentication failures appropriately
**Validates: Requirements 9.2, 9.5**

## Error Handling

### Exception Hierarchy
- **ApiException**: Base class for all API-related errors
- **NetworkException**: Network connectivity and timeout errors
- **AuthenticationException**: Authentication and authorization failures
- **ValidationException**: Form validation and business rule violations
- **StorageException**: Local storage and cache errors

### Error Recovery Strategies
- **Retry Logic**: Exponential backoff for transient network errors
- **Offline Fallback**: Display cached data when network is unavailable
- **User Feedback**: Clear error messages with actionable recovery steps
- **Graceful Degradation**: Disable features rather than crash the app

### Logging and Monitoring
- **Error Tracking**: Comprehensive error logging with context information
- **Performance Monitoring**: Track app performance and resource usage
- **User Analytics**: Privacy-compliant usage analytics with opt-out options
- **Security Monitoring**: Log security events and potential threats

## Testing Strategy

### Dual Testing Approach

The mobile app requires both unit testing and widget testing to ensure comprehensive coverage:

- **Unit tests** verify business logic, data models, and service classes
- **Widget tests** verify UI behavior, user interactions, and navigation flows
- **Integration tests** verify end-to-end workflows and API integration
- Together they provide comprehensive coverage: unit tests catch logic bugs, widget tests verify UI behavior, integration tests ensure system coherence

### Unit Testing Requirements

Unit tests will cover:
- Provider state management and business logic
- Repository API integration and error handling
- Service class functionality and data transformation
- Model serialization and validation logic
- Utility functions and helper methods

### Widget Testing Requirements

**Testing Framework**: Flutter's built-in testing framework with flutter_test
**Test Configuration**: Each widget test must verify UI behavior and user interactions
**Test Coverage**: All screens, forms, and interactive widgets must have corresponding tests
**Mock Strategy**: Use mockito for mocking dependencies and API responses

### Integration Testing Requirements

**Testing Framework**: Flutter integration tests with flutter_driver
**Test Scenarios**: End-to-end user workflows for each role
**API Integration**: Test real API communication with test backend
**Device Testing**: Test on multiple device sizes and orientations

### Testing Requirements Summary

- Widget tests must verify UI behavior and user interaction flows
- Unit tests must cover business logic and data transformation
- Integration tests must verify complete user workflows
- All tests should use appropriate mocking to isolate components under test
- Testing should focus on user-facing functionality and critical business logic