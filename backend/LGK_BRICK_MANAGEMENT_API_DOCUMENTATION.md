# LGK Brick Management System - API Documentation

## Overview

The LGK Brick Management System is a Laravel-based REST API that manages brick orders through a complete workflow from initial capture to payment approval. The system implements role-based access control with four distinct user roles managing different stages of the brick order lifecycle.

**Base URL:** `http://localhost:8000/api`

## Authentication

All endpoints (except login) require Bearer token authentication using Laravel Sanctum.

### Headers Required
```
Authorization: Bearer {your-token-here}
Content-Type: application/json
Accept: application/json
```

## User Roles & Permissions

- **Admin**: Full system access, user management, brick type management
- **Sales Executive**: Create requisitions, view own requisitions
- **Logistics**: Manage delivery challans, view pending orders
- **Accounts**: Payment tracking, financial reports, approve payments

---

## Authentication Endpoints

### 1. Login
**POST** `/login`

Login to get authentication token.

**Request Body:**
```json
{
    "email": "admin@lgk.com",
    "password": "password123"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "email": "admin@lgk.com",
            "role": {
                "id": 1,
                "name": "Admin",
                "permissions": ["manage_users", "manage_brick_types", "view_all_data"]
            },
            "department": {
                "id": 1,
                "name": "Administration"
            },
            "status": "active"
        },
        "token": "1|abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"
    }
}
```

**Error Response (401):**
```json
{
    "status": "fail",
    "message": "Invalid credentials"
}
```

### 2. Logout
**POST** `/logout`

Logout and revoke current token.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Logout successful"
}
```

### 3. Get Current User
**GET** `/user`

Get current authenticated user details.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "User retrieved successfully",
    "data": {
        "user": {
            "id": 1,
            "email": "admin@lgk.com",
            "role": {
                "id": 1,
                "name": "Admin",
                "permissions": ["manage_users", "manage_brick_types", "view_all_data"]
            },
            "department": {
                "id": 1,
                "name": "Administration"
            },
            "status": "active",
            "permissions": ["manage_users", "manage_brick_types", "view_all_data"]
        }
    }
}
```

---

## User Management (Admin Only)

### 1. List Users
**GET** `/users`

Get list of all users with optional filtering.

**Query Parameters:**
- `role_id` (optional): Filter by role ID
- `department_id` (optional): Filter by department ID  
- `status` (optional): Filter by status (active/inactive)

**Example:** `/users?role_id=2&status=active`

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Users retrieved successfully",
    "data": {
        "users": [
            {
                "id": 2,
                "name": "John Sales",
                "email": "john@lgk.com",
                "role": {
                    "id": 2,
                    "name": "Sales Executive"
                },
                "department": {
                    "id": 2,
                    "name": "Sales"
                },
                "status": "active",
                "created_at": "2025-12-16T10:00:00.000000Z"
            }
        ],
        "roles": [
            {"id": 1, "name": "Admin"},
            {"id": 2, "name": "Sales Executive"},
            {"id": 3, "name": "Logistics"},
            {"id": 4, "name": "Accounts"}
        ],
        "departments": [
            {"id": 1, "name": "Administration"},
            {"id": 2, "name": "Sales"},
            {"id": 3, "name": "Logistics"},
            {"id": 4, "name": "Accounts"}
        ]
    }
}
```

### 2. Create User
**POST** `/users`

Create a new user account.

**Request Body:**
```json
{
    "name": "Jane Logistics",
    "email": "jane@lgk.com",
    "password": "password123",
    "role_id": 3,
    "department_id": 3,
    "status": "active"
}
```

**Success Response (201):**
```json
{
    "status": "success",
    "message": "User created successfully",
    "data": {
        "user": {
            "id": 5,
            "name": "Jane Logistics",
            "email": "jane@lgk.com",
            "role": {
                "id": 3,
                "name": "Logistics"
            },
            "department": {
                "id": 3,
                "name": "Logistics"
            },
            "status": "active",
            "created_at": "2025-12-16T10:30:00.000000Z"
        }
    }
}
```

### 3. Get User Details
**GET** `/users/{id}`

Get specific user details.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "User retrieved successfully",
    "data": {
        "user": {
            "id": 2,
            "name": "John Sales",
            "email": "john@lgk.com",
            "role": {
                "id": 2,
                "name": "Sales Executive"
            },
            "department": {
                "id": 2,
                "name": "Sales"
            },
            "status": "active",
            "created_at": "2025-12-16T10:00:00.000000Z"
        }
    }
}
```

### 4. Update User
**PUT** `/users/{id}`

Update user information.

**Request Body:**
```json
{
    "name": "John Updated Sales",
    "email": "john.updated@lgk.com",
    "role_id": 2,
    "department_id": 2,
    "status": "active"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "User updated successfully",
    "data": {
        "user": {
            "id": 2,
            "name": "John Updated Sales",
            "email": "john.updated@lgk.com",
            "role": {
                "id": 2,
                "name": "Sales Executive"
            },
            "department": {
                "id": 2,
                "name": "Sales"
            },
            "status": "active",
            "updated_at": "2025-12-16T11:00:00.000000Z"
        }
    }
}
```

### 5. Deactivate User
**DELETE** `/users/{id}`

Deactivate a user account (soft delete).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "User deactivated successfully",
    "data": {
        "user": {
            "id": 2,
            "name": "John Sales",
            "email": "john@lgk.com",
            "status": "inactive",
            "updated_at": "2025-12-16T11:15:00.000000Z"
        }
    }
}
```

### 6. Get Form Data
**GET** `/users-form-data`

Get roles and departments for user creation forms.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Form data retrieved successfully",
    "data": {
        "roles": [
            {"id": 1, "name": "Admin"},
            {"id": 2, "name": "Sales Executive"},
            {"id": 3, "name": "Logistics"},
            {"id": 4, "name": "Accounts"}
        ],
        "departments": [
            {"id": 1, "name": "Administration"},
            {"id": 2, "name": "Sales"},
            {"id": 3, "name": "Logistics"},
            {"id": 4, "name": "Accounts"}
        ]
    }
}
```

---

## Brick Type Management

### 1. List Brick Types
**GET** `/brick-types`

Get list of brick types (Admin sees all, Sales Executive sees only active).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick types retrieved successfully",
    "data": {
        "brick_types": [
            {
                "id": 1,
                "name": "Red Clay Brick",
                "description": "Standard red clay brick for construction",
                "current_price": "12.50",
                "unit": "piece",
                "category": "Clay Bricks",
                "status": "active",
                "created_at": "2025-12-16T09:00:00.000000Z"
            },
            {
                "id": 2,
                "name": "Concrete Block",
                "description": "Heavy duty concrete blocks",
                "current_price": "25.00",
                "unit": "piece",
                "category": "Concrete Blocks",
                "status": "active",
                "created_at": "2025-12-16T09:15:00.000000Z"
            }
        ]
    }
}
```

### 2. Get Active Brick Types
**GET** `/brick-types/active`

Get only active brick types (for Sales Executive selection).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Active brick types retrieved successfully",
    "data": {
        "brick_types": [
            {
                "id": 1,
                "name": "Red Clay Brick",
                "description": "Standard red clay brick for construction",
                "current_price": "12.50",
                "unit": "piece",
                "category": "Clay Bricks",
                "status": "active"
            }
        ]
    }
}
```

### 3. Create Brick Type (Admin Only)
**POST** `/brick-types`

Create a new brick type.

**Request Body:**
```json
{
    "name": "Fire Brick",
    "description": "Heat resistant fire bricks for furnaces",
    "current_price": 35.75,
    "unit": "piece",
    "category": "Fire Bricks",
    "status": "active"
}
```

**Success Response (201):**
```json
{
    "status": "success",
    "message": "Brick type created successfully",
    "data": {
        "brick_type": {
            "id": 3,
            "name": "Fire Brick",
            "description": "Heat resistant fire bricks for furnaces",
            "current_price": "35.75",
            "unit": "piece",
            "category": "Fire Bricks",
            "status": "active",
            "created_at": "2025-12-16T12:00:00.000000Z"
        }
    }
}
```

### 4. Get Brick Type Details
**GET** `/brick-types/{id}`

Get specific brick type details.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick type retrieved successfully",
    "data": {
        "brick_type": {
            "id": 1,
            "name": "Red Clay Brick",
            "description": "Standard red clay brick for construction",
            "current_price": "12.50",
            "unit": "piece",
            "category": "Clay Bricks",
            "status": "active",
            "created_at": "2025-12-16T09:00:00.000000Z"
        }
    }
}
```

### 5. Update Brick Type (Admin Only)
**PUT** `/brick-types/{id}`

Update brick type information.

**Request Body:**
```json
{
    "name": "Premium Red Clay Brick",
    "description": "Premium quality red clay brick for construction",
    "current_price": 15.00,
    "unit": "piece",
    "category": "Premium Clay Bricks",
    "status": "active"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick type updated successfully",
    "data": {
        "brick_type": {
            "id": 1,
            "name": "Premium Red Clay Brick",
            "description": "Premium quality red clay brick for construction",
            "current_price": "15.00",
            "unit": "piece",
            "category": "Premium Clay Bricks",
            "status": "active",
            "updated_at": "2025-12-16T12:30:00.000000Z"
        }
    }
}
```

### 6. Update Brick Type Status (Admin Only)
**PATCH** `/brick-types/{id}/status`

Update brick type status (activate/deactivate).

**Request Body:**
```json
{
    "status": "inactive"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick type status updated successfully",
    "data": {
        "brick_type": {
            "id": 1,
            "name": "Red Clay Brick",
            "status": "inactive",
            "updated_at": "2025-12-16T13:00:00.000000Z"
        }
    }
}
```

### 7. Deactivate Brick Type (Admin Only)
**DELETE** `/brick-types/{id}`

Deactivate a brick type (soft delete).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick type deactivated successfully"
}
```

---

## Requisition Management

### 1. List Requisitions
**GET** `/requisitions`

Get list of requisitions (Sales Executive sees only their own, others see all).

**Query Parameters:**
- `status` (optional): Filter by status (submitted, assigned, delivered, paid, complete)
- `date` (optional): Filter by specific date (YYYY-MM-DD)

**Example:** `/requisitions?status=submitted&date=2025-12-16`

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Requisitions retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "order_number": "ORD000001",
                "date": "2025-12-16",
                "quantity": "100.00",
                "price_per_unit": "12.50",
                "total_amount": "1250.00",
                "customer_name": "ABC Construction Ltd",
                "customer_phone": "+91-9876543210",
                "customer_address": "123 Construction Street, Building City",
                "customer_location": "Mumbai, Maharashtra",
                "status": "submitted",
                "user": {
                    "id": 2,
                    "name": "John Sales",
                    "email": "john@lgk.com"
                },
                "brickType": {
                    "id": 1,
                    "name": "Red Clay Brick",
                    "unit": "piece",
                    "current_price": "12.50"
                },
                "created_at": "2025-12-16T10:00:00.000000Z"
            }
        ],
        "per_page": 15,
        "total": 1
    }
}
```

### 2. Create Requisition
**POST** `/requisitions`

Create a new brick requisition.

**Request Body:**
```json
{
    "brick_type_id": 1,
    "quantity": 100,
    "price_per_unit": 12.50,
    "total_amount": 1250.00,
    "customer_name": "ABC Construction Ltd",
    "customer_phone": "+91-9876543210",
    "customer_address": "123 Construction Street, Building City, Mumbai",
    "customer_location": "Mumbai, Maharashtra"
}
```

**Success Response (201):**
```json
{
    "status": "success",
    "message": "Requisition created successfully",
    "data": {
        "id": 2,
        "order_number": "ORD000002",
        "date": "2025-12-16",
        "quantity": "100.00",
        "price_per_unit": "12.50",
        "total_amount": "1250.00",
        "customer_name": "ABC Construction Ltd",
        "customer_phone": "+91-9876543210",
        "customer_address": "123 Construction Street, Building City, Mumbai",
        "customer_location": "Mumbai, Maharashtra",
        "status": "submitted",
        "user": {
            "id": 2,
            "name": "John Sales",
            "email": "john@lgk.com"
        },
        "brickType": {
            "id": 1,
            "name": "Red Clay Brick",
            "unit": "piece",
            "current_price": "12.50"
        },
        "created_at": "2025-12-16T14:00:00.000000Z"
    }
}
```

### 3. Get Requisition Details
**GET** `/requisitions/{id}`

Get specific requisition details.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Requisition retrieved successfully",
    "data": {
        "id": 1,
        "order_number": "ORD000001",
        "date": "2025-12-16",
        "quantity": "100.00",
        "price_per_unit": "12.50",
        "total_amount": "1250.00",
        "customer_name": "ABC Construction Ltd",
        "customer_phone": "+91-9876543210",
        "customer_address": "123 Construction Street, Building City",
        "customer_location": "Mumbai, Maharashtra",
        "status": "submitted",
        "user": {
            "id": 2,
            "name": "John Sales",
            "email": "john@lgk.com"
        },
        "brickType": {
            "id": 1,
            "name": "Red Clay Brick",
            "unit": "piece",
            "current_price": "12.50"
        },
        "created_at": "2025-12-16T10:00:00.000000Z"
    }
}
```

### 4. Get Pending Requisitions (Logistics Only)
**GET** `/requisitions/pending`

Get pending requisitions for logistics assignment.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Pending requisitions retrieved successfully",
    "data": [
        {
            "id": 1,
            "order_number": "ORD000001",
            "date": "2025-12-16",
            "quantity": "100.00",
            "total_amount": "1250.00",
            "customer_name": "ABC Construction Ltd",
            "customer_location": "Mumbai, Maharashtra",
            "status": "submitted",
            "user": {
                "id": 2,
                "name": "John Sales"
            },
            "brickType": {
                "id": 1,
                "name": "Red Clay Brick"
            },
            "created_at": "2025-12-16T10:00:00.000000Z"
        }
    ]
}
```

### 5. Get Brick Price
**GET** `/brick-types/{id}/price`

Get current price for a specific brick type (for frontend validation).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Brick price retrieved successfully",
    "data": {
        "brick_type_id": 1,
        "name": "Red Clay Brick",
        "current_price": "12.50",
        "unit": "piece"
    }
}
```

### 6. Update Requisition (Not Allowed)
**PUT** `/requisitions/{id}`

Requisitions are immutable after submission.

**Error Response (403):**
```json
{
    "status": "fail",
    "message": "Requisitions cannot be modified after submission",
    "errors": {
        "general": ["Requisitions are immutable once submitted"]
    }
}
```

### 7. Delete Requisition (Not Allowed)
**DELETE** `/requisitions/{id}`

Requisitions cannot be deleted after submission.

**Error Response (403):**
```json
{
    "status": "fail",
    "message": "Requisitions cannot be deleted after submission",
    "errors": {
        "general": ["Requisitions are immutable once submitted"]
    }
}
```

---

## Delivery Challan Management (Logistics Only)

### 1. List Delivery Challans
**GET** `/delivery-challans`

Get list of delivery challans.

**Query Parameters:**
- `delivery_status` (optional): Filter by delivery status (assigned, in_transit, delivered)
- `date` (optional): Filter by specific date (YYYY-MM-DD)

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Delivery challans retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "challan_number": "CH000001",
                "date": "2025-12-16",
                "vehicle_number": "MH01AB1234",
                "driver_name": "Ramesh Kumar",
                "vehicle_type": "Truck",
                "location": "Mumbai Warehouse",
                "delivery_status": "assigned",
                "remarks": null,
                "requisition": {
                    "id": 1,
                    "order_number": "ORD000001",
                    "customer_name": "ABC Construction Ltd",
                    "customer_location": "Mumbai, Maharashtra",
                    "total_amount": "1250.00",
                    "user": {
                        "id": 2,
                        "name": "John Sales"
                    },
                    "brickType": {
                        "id": 1,
                        "name": "Red Clay Brick",
                        "unit": "piece"
                    }
                },
                "created_at": "2025-12-16T11:00:00.000000Z"
            }
        ],
        "per_page": 15,
        "total": 1
    }
}
```

### 2. Create Delivery Challan
**POST** `/delivery-challans`

Create a delivery challan from a requisition.

**Request Body:**
```json
{
    "requisition_id": 1,
    "vehicle_number": "MH01AB1234",
    "driver_name": "Ramesh Kumar",
    "vehicle_type": "Truck",
    "location": "Mumbai Warehouse",
    "remarks": "Handle with care"
}
```

**Success Response (201):**
```json
{
    "status": "success",
    "message": "Delivery challan created successfully",
    "data": {
        "id": 1,
        "challan_number": "CH000001",
        "date": "2025-12-16",
        "vehicle_number": "MH01AB1234",
        "driver_name": "Ramesh Kumar",
        "vehicle_type": "Truck",
        "location": "Mumbai Warehouse",
        "delivery_status": "assigned",
        "remarks": "Handle with care",
        "requisition": {
            "id": 1,
            "order_number": "ORD000001",
            "customer_name": "ABC Construction Ltd",
            "total_amount": "1250.00",
            "user": {
                "id": 2,
                "name": "John Sales"
            },
            "brickType": {
                "id": 1,
                "name": "Red Clay Brick"
            }
        },
        "created_at": "2025-12-16T11:00:00.000000Z"
    }
}
```

### 3. Get Delivery Challan Details
**GET** `/delivery-challans/{id}`

Get specific delivery challan details.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Delivery challan retrieved successfully",
    "data": {
        "id": 1,
        "challan_number": "CH000001",
        "date": "2025-12-16",
        "vehicle_number": "MH01AB1234",
        "driver_name": "Ramesh Kumar",
        "vehicle_type": "Truck",
        "location": "Mumbai Warehouse",
        "delivery_status": "assigned",
        "delivery_date": null,
        "print_count": 0,
        "remarks": "Handle with care",
        "requisition": {
            "id": 1,
            "order_number": "ORD000001",
            "customer_name": "ABC Construction Ltd",
            "customer_phone": "+91-9876543210",
            "customer_address": "123 Construction Street, Building City",
            "customer_location": "Mumbai, Maharashtra",
            "quantity": "100.00",
            "total_amount": "1250.00",
            "user": {
                "id": 2,
                "name": "John Sales"
            },
            "brickType": {
                "id": 1,
                "name": "Red Clay Brick",
                "unit": "piece"
            }
        },
        "created_at": "2025-12-16T11:00:00.000000Z"
    }
}
```

### 4. Update Delivery Status
**PATCH** `/delivery-challans/{id}/status`

Update delivery status of a challan.

**Request Body:**
```json
{
    "delivery_status": "in_transit",
    "remarks": "Left warehouse at 2:00 PM"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Delivery status updated successfully",
    "data": {
        "id": 1,
        "challan_number": "CH000001",
        "delivery_status": "in_transit",
        "remarks": "Left warehouse at 2:00 PM",
        "updated_at": "2025-12-16T14:00:00.000000Z"
    }
}
```

### 5. Get Pending Orders
**GET** `/delivery-challans/pending-orders`

Get pending orders queue for logistics assignment.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Pending orders retrieved successfully",
    "data": [
        {
            "id": 2,
            "order_number": "ORD000002",
            "date": "2025-12-16",
            "customer_name": "XYZ Builders",
            "customer_location": "Delhi, NCR",
            "quantity": "200.00",
            "total_amount": "2500.00",
            "status": "submitted",
            "user": {
                "id": 2,
                "name": "John Sales"
            },
            "brickType": {
                "id": 1,
                "name": "Red Clay Brick"
            }
        }
    ]
}
```

### 6. Print Delivery Challan
**GET** `/delivery-challans/{id}/print`

Generate printable delivery challan document.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Printable challan generated successfully",
    "data": {
        "challan_number": "CH000001",
        "date": "2025-12-16",
        "customer_details": {
            "name": "ABC Construction Ltd",
            "phone": "+91-9876543210",
            "address": "123 Construction Street, Building City",
            "location": "Mumbai, Maharashtra"
        },
        "order_details": {
            "order_number": "ORD000001",
            "brick_type": "Red Clay Brick",
            "quantity": "100.00 pieces",
            "price_per_unit": "12.50",
            "total_amount": "1250.00"
        },
        "delivery_details": {
            "vehicle_number": "MH01AB1234",
            "driver_name": "Ramesh Kumar",
            "vehicle_type": "Truck",
            "location": "Mumbai Warehouse"
        },
        "print_count": 1
    }
}
```

### 7. Update Delivery Challan
**PUT** `/delivery-challans/{id}`

Update delivery challan information (only if not delivered).

**Request Body:**
```json
{
    "vehicle_number": "MH01AB5678",
    "driver_name": "Suresh Patel",
    "vehicle_type": "Mini Truck",
    "location": "Mumbai Warehouse",
    "remarks": "Updated vehicle details"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Delivery challan updated successfully",
    "data": {
        "id": 1,
        "vehicle_number": "MH01AB5678",
        "driver_name": "Suresh Patel",
        "vehicle_type": "Mini Truck",
        "updated_at": "2025-12-16T15:00:00.000000Z"
    }
}
```

---

## Payment Management (Accounts Only)

### 1. Payment Dashboard
**GET** `/payments`

Get payment tracking dashboard with delivered challans.

**Query Parameters:**
- `status` (optional): Filter by payment status (pending, partial, paid, approved)
- `from_date` (optional): Filter from date (YYYY-MM-DD)
- `to_date` (optional): Filter to date (YYYY-MM-DD)

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Payment dashboard data retrieved successfully",
    "data": {
        "payments": [
            {
                "id": 1,
                "total_amount": "1250.00",
                "amount_received": "1250.00",
                "payment_status": "paid",
                "payment_date": "2025-12-16",
                "payment_method": "bank_transfer",
                "reference_number": "TXN123456789",
                "deliveryChallan": {
                    "id": 1,
                    "challan_number": "CH000001",
                    "requisition": {
                        "id": 1,
                        "order_number": "ORD000001",
                        "customer_name": "ABC Construction Ltd",
                        "brickType": {
                            "name": "Red Clay Brick"
                        }
                    }
                },
                "approvedBy": null,
                "created_at": "2025-12-16T16:00:00.000000Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 1,
            "per_page": 15,
            "total": 1
        },
        "summary": {
            "total_pending": 2,
            "total_paid": 5,
            "total_amount_pending": "5000.00",
            "total_amount_received": "12500.00"
        }
    }
}
```

### 2. Get Delivered Challans
**GET** `/payments/delivered-challans`

Get delivered challans that need payment tracking.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Delivered challans retrieved successfully",
    "data": {
        "challans": [
            {
                "id": 2,
                "challan_number": "CH000002",
                "date": "2025-12-16",
                "delivery_status": "delivered",
                "delivery_date": "2025-12-16",
                "requisition": {
                    "id": 2,
                    "order_number": "ORD000002",
                    "customer_name": "XYZ Builders",
                    "total_amount": "2500.00",
                    "brickType": {
                        "name": "Red Clay Brick"
                    },
                    "user": {
                        "name": "John Sales"
                    }
                }
            }
        ]
    }
}
```

### 3. Create Payment Record
**POST** `/payments`

Create payment record for a delivered challan.

**Request Body:**
```json
{
    "delivery_challan_id": 2,
    "total_amount": 2500.00,
    "amount_received": 2500.00,
    "payment_date": "2025-12-16",
    "payment_method": "cash",
    "reference_number": "CASH123",
    "remarks": "Full payment received in cash"
}
```

**Success Response (201):**
```json
{
    "status": "success",
    "message": "Payment record created successfully",
    "data": {
        "payment": {
            "id": 2,
            "total_amount": "2500.00",
            "amount_received": "2500.00",
            "payment_status": "paid",
            "payment_date": "2025-12-16",
            "payment_method": "cash",
            "reference_number": "CASH123",
            "remarks": "Full payment received in cash",
            "deliveryChallan": {
                "id": 2,
                "challan_number": "CH000002",
                "requisition": {
                    "id": 2,
                    "order_number": "ORD000002",
                    "customer_name": "XYZ Builders"
                }
            },
            "approvedBy": null,
            "created_at": "2025-12-16T17:00:00.000000Z"
        }
    }
}
```

### 4. Get Payment Details
**GET** `/payments/{id}`

Get specific payment details and history.

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Payment details retrieved successfully",
    "data": {
        "payment": {
            "id": 1,
            "total_amount": "1250.00",
            "amount_received": "1250.00",
            "payment_status": "paid",
            "payment_date": "2025-12-16",
            "payment_method": "bank_transfer",
            "reference_number": "TXN123456789",
            "remarks": "Payment received via bank transfer",
            "deliveryChallan": {
                "id": 1,
                "challan_number": "CH000001",
                "requisition": {
                    "id": 1,
                    "order_number": "ORD000001",
                    "customer_name": "ABC Construction Ltd",
                    "brickType": {
                        "name": "Red Clay Brick"
                    },
                    "user": {
                        "name": "John Sales"
                    }
                }
            },
            "approvedBy": null,
            "created_at": "2025-12-16T16:00:00.000000Z"
        },
        "history": [
            {
                "action": "created",
                "timestamp": "2025-12-16T16:00:00.000000Z",
                "user": "accounts@lgk.com"
            }
        ]
    }
}
```

### 5. Update Payment
**PUT** `/payments/{id}`

Update payment status and amounts.

**Request Body:**
```json
{
    "payment_status": "paid",
    "amount_received": 1250.00,
    "payment_date": "2025-12-16",
    "payment_method": "bank_transfer",
    "reference_number": "TXN987654321",
    "remarks": "Updated payment details"
}
```

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Payment updated successfully",
    "data": {
        "payment": {
            "id": 1,
            "payment_status": "paid",
            "amount_received": "1250.00",
            "payment_method": "bank_transfer",
            "reference_number": "TXN987654321",
            "remarks": "Updated payment details",
            "updated_at": "2025-12-16T18:00:00.000000Z"
        }
    }
}
```

### 6. Approve Payment
**POST** `/payments/{id}/approve`

Approve payment (locks the record).

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Payment approved successfully",
    "data": {
        "payment": {
            "id": 1,
            "payment_status": "approved",
            "approved_by": 4,
            "approved_at": "2025-12-16T18:30:00.000000Z",
            "approvedBy": {
                "id": 4,
                "name": "Accounts Manager",
                "email": "accounts@lgk.com"
            }
        }
    }
}
```

### 7. Payment Reports
**GET** `/payments/reports`

Get payment reports.

**Query Parameters:**
- `type` (required): Report type (daily, range)
- `date` (required if type=daily): Date for daily report (YYYY-MM-DD)
- `from_date` (required if type=range): Start date for range report (YYYY-MM-DD)
- `to_date` (required if type=range): End date for range report (YYYY-MM-DD)

**Example:** `/payments/reports?type=daily&date=2025-12-16`

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Payment report generated successfully",
    "data": {
        "report": {
            "date": "2025-12-16",
            "total_orders": 5,
            "total_amount": "15000.00",
            "total_received": "12500.00",
            "pending_amount": "2500.00",
            "payment_methods": {
                "cash": "5000.00",
                "bank_transfer": "7500.00"
            },
            "orders": [
                {
                    "order_number": "ORD000001",
                    "customer_name": "ABC Construction Ltd",
                    "amount": "1250.00",
                    "status": "paid"
                }
            ]
        }
    }
}
```

---

## Financial Reports (Accounts Only)

### 1. Daily Financial Report
**GET** `/reports/daily`

Generate daily financial report.

**Query Parameters:**
- `date` (required): Date for report (YYYY-MM-DD)

**Example:** `/reports/daily?date=2025-12-16`

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Daily financial report generated successfully",
    "data": {
        "report": {
            "date": "2025-12-16",
            "summary": {
                "total_orders": 5,
                "total_deliveries": 3,
                "total_payments": 2,
                "total_order_value": "15000.00",
                "total_payments_received": "7500.00",
                "pending_payments": "7500.00"
            },
            "orders": [
                {
                    "order_number": "ORD000001",
                    "customer_name": "ABC Construction Ltd",
                    "brick_type": "Red Clay Brick",
                    "quantity": "100.00",
                    "amount": "1250.00",
                    "status": "delivered"
                }
            ],
            "payments": [
                {
                    "order_number": "ORD000001",
                    "customer_name": "ABC Construction Ltd",
                    "amount_due": "1250.00",
                    "amount_received": "1250.00",
                    "payment_method": "bank_transfer",
                    "status": "paid"
                }
            ]
        }
    }
}
```

### 2. Date Range Financial Report
**GET** `/reports/range`

Generate date range financial report.

**Query Parameters:**
- `from_date` (required): Start date (YYYY-MM-DD)
- `to_date` (required): End date (YYYY-MM-DD)

**Example:** `/reports/range?from_date=2025-12-01&to_date=2025-12-16`

**Success Response (200):**
```json
{
    "status": "success",
    "message": "Date range financial report generated successfully",
    "data": {
        "report": {
            "from_date": "2025-12-01",
            "to_date": "2025-12-16",
            "summary": {
                "total_orders": 25,
                "total_deliveries": 20,
                "total_payments": 15,
                "total_order_value": "75000.00",
                "total_payments_received": "60000.00",
                "pending_payments": "15000.00"
            },
            "daily_breakdown": [
                {
                    "date": "2025-12-16",
                    "orders": 5,
                    "deliveries": 3,
                    "payments": 2,
                    "order_value": "15000.00",
                    "payments_received": "7500.00"
                }
            ],
            "brick_type_breakdown": [
                {
                    "brick_type": "Red Clay Brick",
                    "total_quantity": "2000.00",
                    "total_value": "25000.00"
                }
            ]
        }
    }
}
```

### 3. Export Daily Report as PDF
**GET** `/reports/daily/export/pdf`

Export daily report as PDF file.

**Query Parameters:**
- `date` (required): Date for report (YYYY-MM-DD)

**Example:** `/reports/daily/export/pdf?date=2025-12-16`

**Success Response (200):**
Returns PDF file with headers:
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="daily-report-2025-12-16.pdf"
```

### 4. Export Range Report as PDF
**GET** `/reports/range/export/pdf`

Export date range report as PDF file.

**Query Parameters:**
- `from_date` (required): Start date (YYYY-MM-DD)
- `to_date` (required): End date (YYYY-MM-DD)

**Example:** `/reports/range/export/pdf?from_date=2025-12-01&to_date=2025-12-16`

**Success Response (200):**
Returns PDF file with headers:
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="range-report-2025-12-01-to-2025-12-16.pdf"
```

### 5. Export Daily Report as Excel
**GET** `/reports/daily/export/excel`

Export daily report as Excel file.

**Query Parameters:**
- `date` (required): Date for report (YYYY-MM-DD)

**Example:** `/reports/daily/export/excel?date=2025-12-16`

**Success Response (200):**
Returns Excel file with headers:
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="daily-report-2025-12-16.xlsx"
```

### 6. Export Range Report as Excel
**GET** `/reports/range/export/excel`

Export date range report as Excel file.

**Query Parameters:**
- `from_date` (required): Start date (YYYY-MM-DD)
- `to_date` (required): End date (YYYY-MM-DD)

**Example:** `/reports/range/export/excel?from_date=2025-12-01&to_date=2025-12-16`

**Success Response (200):**
Returns Excel file with headers:
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="range-report-2025-12-01-to-2025-12-16.xlsx"
```

---

## Error Responses

### Common Error Formats

**Validation Error (422):**
```json
{
    "status": "fail",
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": ["The password must be at least 8 characters."]
    }
}
```

**Authentication Error (401):**
```json
{
    "status": "fail",
    "message": "Unauthenticated"
}
```

**Authorization Error (403):**
```json
{
    "status": "fail",
    "message": "This action is unauthorized"
}
```

**Not Found Error (404):**
```json
{
    "status": "fail",
    "message": "Resource not found"
}
```

**Server Error (500):**
```json
{
    "status": "fail",
    "message": "Internal server error",
    "errors": {
        "general": ["An unexpected error occurred"]
    }
}
```

---

## Status Values Reference

### Requisition Status
- `submitted` - Initial status when created
- `assigned` - Assigned to logistics for delivery
- `delivered` - Successfully delivered to customer
- `paid` - Payment received
- `complete` - Order fully completed

### Delivery Status
- `assigned` - Challan created, ready for delivery
- `in_transit` - Out for delivery
- `delivered` - Successfully delivered

### Payment Status
- `pending` - Payment not yet received
- `partial` - Partial payment received
- `paid` - Full payment received
- `approved` - Payment approved by accounts

### Payment Methods
- `cash` - Cash payment
- `bank_transfer` - Bank transfer
- `cheque` - Cheque payment
- `online` - Online payment
- `upi` - UPI payment

### User Status
- `active` - Active user account
- `inactive` - Deactivated user account

### Brick Type Status
- `active` - Available for orders
- `inactive` - Not available for orders

---

## Postman Collection Setup

### Environment Variables
Create a Postman environment with these variables:

```
base_url: http://localhost:8000/api
token: (will be set after login)
```

### Pre-request Script for Authentication
Add this to requests that require authentication:

```javascript
pm.request.headers.add({
    key: 'Authorization',
    value: 'Bearer ' + pm.environment.get('token')
});
```

### Login Test Script
Add this to the login request to save the token:

```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set('token', response.data.token);
}
```

This comprehensive API documentation provides all the endpoints, request/response formats, and dummy data needed to test the LGK Brick Management System API in Postman.