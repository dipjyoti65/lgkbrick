<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $roles = [
            [
                'name' => 'Admin',
                'description' => 'System administrator with full access to all modules and user management',
                'permissions' => [
                    'users.create',
                    'users.read',
                    'users.update',
                    'users.delete',
                    'brick_types.create',
                    'brick_types.read',
                    'brick_types.update',
                    'brick_types.delete',
                    'requisitions.read',
                    'delivery_challans.read',
                    'payments.read',
                    'reports.read',
                    'audit.read',
                ]
            ],
            [
                'name' => 'Sales Executive',
                'description' => 'Sales team member responsible for capturing customer orders',
                'permissions' => [
                    'requisitions.create',
                    'requisitions.read_own',
                    'brick_types.read_active',
                ]
            ],
            [
                'name' => 'Logistics',
                'description' => 'Logistics team member handling order fulfillment and delivery management',
                'permissions' => [
                    'requisitions.read',
                    'delivery_challans.create',
                    'delivery_challans.read',
                    'delivery_challans.update',
                    'delivery_challans.print',
                ]
            ],
            [
                'name' => 'Accounts',
                'description' => 'Accounts team member managing payment lifecycle and financial reporting',
                'permissions' => [
                    'payments.read',
                    'payments.update',
                    'reports.create',
                    'reports.export',
                    'delivery_challans.read',
                ]
            ],
        ];

        foreach ($roles as $roleData) {
            Role::firstOrCreate(
                ['name' => $roleData['name']],
                $roleData
            );
        }
    }
}