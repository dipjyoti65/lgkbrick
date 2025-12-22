# LGK Brick Management System

A Laravel-based REST API system for managing brick orders from initial capture through delivery and payment approval.

## Project Setup

This project is built with Laravel 10.x and includes the following key components:

### Technology Stack
- **Backend Framework**: Laravel 10.x
- **Database**: MySQL 8.0 (SQLite for testing)
- **Authentication**: Laravel Sanctum for API token authentication
- **Testing**: PHPUnit with Eris for property-based testing

### Directory Structure
```
app/
├── Http/
│   ├── Controllers/Api/     # API Controllers
│   ├── Requests/           # Form Request validation classes
│   └── Resources/          # API Resource classes
├── Models/                 # Eloquent models
├── Services/              # Business logic services
├── Repositories/          # Data access layer
└── Exceptions/           # Custom exception classes
```

### Installation

1. **Clone and Install Dependencies**
   ```bash
   composer install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

3. **Database Configuration**
   Update your `.env` file with MySQL database credentials:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=lgk_brick_management
   DB_USERNAME=root
   DB_PASSWORD=your_password
   ```

4. **Run Migrations**
   ```bash
   php artisan migrate
   ```

### Testing

The project includes both unit tests and property-based tests using Eris:

```bash
# Run all tests
php artisan test

# Run only unit tests
php artisan test --testsuite=Unit

# Run only feature tests
php artisan test --testsuite=Feature
```

### API Authentication

The system uses Laravel Sanctum for API authentication:

- **Login**: `POST /api/login`
- **Logout**: `POST /api/logout` (requires authentication)
- **User Profile**: `GET /api/user` (requires authentication)

### Development

Start the development server:
```bash
php artisan serve
```

The API will be available at `http://localhost:8000/api/`

## Project Structure

This project follows Laravel best practices with:
- Repository pattern for data access
- Service layer for business logic
- API Resources for consistent response formatting
- Form Request classes for validation
- Property-based testing for comprehensive coverage
