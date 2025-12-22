# Database Seeders

This directory contains seeders for the LGK Brick Management System that populate the database with initial and sample data.

## Available Seeders

### Core Data Seeders

1. **RoleSeeder** - Creates the four main system roles:
   - Admin (full system access)
   - Sales Executive (order creation)
   - Logistics (delivery management)
   - Accounts (payment processing)

2. **DepartmentSeeder** - Creates organizational departments:
   - Sales
   - Logistics
   - Accounts
   - Administration

3. **AdminUserSeeder** - Creates the default system administrator:
   - Email: admin@lgk.com
   - Password: admin123

### Sample Data Seeders

4. **BrickTypeSeeder** - Creates sample brick types for testing:
   - 6 active brick types with different categories and pricing
   - 1 inactive brick type for testing status filtering

5. **SampleUserSeeder** - Creates sample users for each role:
   - 3 Sales Executive users
   - 2 Logistics users
   - 2 Accounts users
   - 1 additional Admin user
   - 1 inactive user for testing

6. **SampleRequisitionSeeder** - Creates complete workflow sample data:
   - 15 requisitions with different statuses
   - Associated delivery challans for appropriate statuses
   - Payment records for delivered orders
   - Realistic customer and vehicle data

## Usage

### Run All Seeders
```bash
php artisan db:seed
```

### Run Individual Seeders
```bash
php artisan db:seed --class=RoleSeeder
php artisan db:seed --class=DepartmentSeeder
php artisan db:seed --class=AdminUserSeeder
php artisan db:seed --class=BrickTypeSeeder
php artisan db:seed --class=SampleUserSeeder
php artisan db:seed --class=SampleRequisitionSeeder
```

### Fresh Migration with Seeding
```bash
php artisan migrate:fresh --seed
```

## Default Login Credentials

After running the seeders, you can use these credentials for testing:

**Admin User:**
- Email: admin@lgk.com
- Password: admin123

**Sample Users:**
- Sales: rajesh.sales@lgk.com / sales123
- Logistics: suresh.logistics@lgk.com / logistics123
- Accounts: deepak.accounts@lgk.com / accounts123

## Notes

- Seeders use `firstOrCreate()` to prevent duplicate entries when run multiple times
- Order numbers and challan numbers are generated to avoid conflicts with existing data
- Sample data includes realistic Indian names, phone numbers, and locations
- Payment records demonstrate different payment statuses and methods
- All monetary amounts use proper decimal precision for financial accuracy