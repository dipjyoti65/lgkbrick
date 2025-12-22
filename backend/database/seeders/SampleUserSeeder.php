<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SampleUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get roles and departments
        $adminRole = Role::where('name', 'Admin')->first();
        $salesRole = Role::where('name', 'Sales Executive')->first();
        $logisticsRole = Role::where('name', 'Logistics')->first();
        $accountsRole = Role::where('name', 'Accounts')->first();

        $salesDept = Department::where('name', 'Sales')->first();
        $logisticsDept = Department::where('name', 'Logistics')->first();
        $accountsDept = Department::where('name', 'Accounts')->first();
        $adminDept = Department::where('name', 'Administration')->first();

        // Get admin user for created_by field
        $adminUser = User::where('email', 'admin@lgk.com')->first();

        if (!$adminUser) {
            $this->command->error('Admin user not found. Please run AdminUserSeeder first.');
            return;
        }

        $sampleUsers = [
            // Sales Executive users
            [
                'name' => 'Rajesh Kumar',
                'email' => 'rajesh.sales@lgk.com',
                'password' => Hash::make('sales123'),
                'role_id' => $salesRole->id,
                'department_id' => $salesDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],
            [
                'name' => 'Priya Sharma',
                'email' => 'priya.sales@lgk.com',
                'password' => Hash::make('sales123'),
                'role_id' => $salesRole->id,
                'department_id' => $salesDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],
            [
                'name' => 'Amit Patel',
                'email' => 'amit.sales@lgk.com',
                'password' => Hash::make('sales123'),
                'role_id' => $salesRole->id,
                'department_id' => $salesDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],

            // Logistics users
            [
                'name' => 'Suresh Logistics',
                'email' => 'suresh.logistics@lgk.com',
                'password' => Hash::make('logistics123'),
                'role_id' => $logisticsRole->id,
                'department_id' => $logisticsDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],
            [
                'name' => 'Kavita Transport',
                'email' => 'kavita.logistics@lgk.com',
                'password' => Hash::make('logistics123'),
                'role_id' => $logisticsRole->id,
                'department_id' => $logisticsDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],

            // Accounts users
            [
                'name' => 'Deepak Accounts',
                'email' => 'deepak.accounts@lgk.com',
                'password' => Hash::make('accounts123'),
                'role_id' => $accountsRole->id,
                'department_id' => $accountsDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],
            [
                'name' => 'Meera Finance',
                'email' => 'meera.accounts@lgk.com',
                'password' => Hash::make('accounts123'),
                'role_id' => $accountsRole->id,
                'department_id' => $accountsDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],

            // Additional Admin user
            [
                'name' => 'Vikram Admin',
                'email' => 'vikram.admin@lgk.com',
                'password' => Hash::make('admin123'),
                'role_id' => $adminRole->id,
                'department_id' => $adminDept->id,
                'status' => 'active',
                'created_by' => $adminUser->id,
            ],

            // Inactive user for testing
            [
                'name' => 'Inactive User',
                'email' => 'inactive@lgk.com',
                'password' => Hash::make('inactive123'),
                'role_id' => $salesRole->id,
                'department_id' => $salesDept->id,
                'status' => 'inactive',
                'created_by' => $adminUser->id,
            ],
        ];

        foreach ($sampleUsers as $userData) {
            User::firstOrCreate(
                ['email' => $userData['email']],
                $userData
            );
        }

        $this->command->info('Sample users created for testing purposes.');
    }
}