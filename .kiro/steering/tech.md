# Technology Stack & Development Guide

## Core Framework
- **Laravel 10.x** - PHP framework providing MVC architecture, ORM, and API capabilities
- **PHP 8.1+** - Required for modern PHP features and Laravel compatibility
- **MySQL 8.0** - Primary database (SQLite for testing)

## Key Dependencies

### Authentication & Security
- **Laravel Sanctum** - API token authentication for all endpoints
- Role-based middleware for access control

### Document Generation
- **DomPDF** - PDF generation for delivery challans and reports
- **Maatwebsite Excel** - Excel export functionality for financial reports

### Testing Framework
- **PHPUnit** - Standard unit and feature testing
- **Eris** - Property-based testing for comprehensive business logic validation
- **Faker** - Test data generation

## Common Commands

### Development Setup
```bash
# Install dependencies
composer install

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate
php artisan db:seed
```

### Development Server
```bash
# Start development server
php artisan serve
# API available at http://localhost:8000/api/
```

### Testing
```bash
# Run all tests
php artisan test

# Run specific test suites
php artisan test --testsuite=Unit
php artisan test --testsuite=Feature

# Run with coverage
php artisan test --coverage
```

### Code Quality
```bash
# Fix code style
./vendor/bin/pint

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## Build System
- **Vite** - Modern build tool for frontend assets
- **Laravel Vite Plugin** - Laravel integration for asset compilation

### Frontend Commands
```bash
# Install frontend dependencies
npm install

# Development build
npm run dev

# Production build
npm run build
```