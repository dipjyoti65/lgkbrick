# LGK Brick Management System

## Product Overview

The LGK Brick Management System is a Laravel-based REST API that manages brick orders through a complete workflow from initial capture to payment approval. The system implements role-based access control with four distinct user roles managing different stages of the brick order lifecycle.

## Core Workflow

1. **Sales Executives** create requisitions for brick orders with customer details
2. **Logistics** users generate delivery challans and manage deliveries  
3. **Accounts** users track payments and approve financial transactions
4. **Admin** users manage system configuration, users, and brick types

## Key Business Rules

- **Immutability**: Requisitions cannot be modified after submission
- **Price Validation**: Frontend calculations are validated against current brick pricing
- **Sequential Numbering**: Order numbers are generated sequentially (ORD000001, ORD000002, etc.)
- **Role-Based Access**: Each role has specific permissions and can only access relevant data
- **Status Workflow**: Orders progress through defined statuses: submitted → assigned → delivered → paid → complete

## Document Generation

The system generates printable delivery challans (PDF) and financial reports in both PDF and Excel formats for comprehensive business documentation.