<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get the Admin role and Administration department
        $adminRole = Role::where('name', 'Admin')->first();
        $adminDepartment = Department::where('name', 'Administration')->first();

        if (!$adminRole || !$adminDepartment) {
            $this->command->error('Admin role or Administration department not found. Please run RoleSeeder and DepartmentSeeder first.');
            return;
        }

        // Create default admin user
        User::firstOrCreate(
            ['email' => 'admin@lgk.com'],
            [
                'name' => 'System Administrator',
                'email' => 'admin@lgk.com',
                'password' => Hash::make('admin123'),
                'role_id' => $adminRole->id,
                'department_id' => $adminDepartment->id,
                'status' => 'active',
                'created_by' => null, // Self-created
            ]
        );

        $this->command->info('Default admin user created: admin@lgk.com / admin123');
    }
}