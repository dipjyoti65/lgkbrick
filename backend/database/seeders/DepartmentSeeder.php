<?php

namespace Database\Seeders;

use App\Models\Department;
use Illuminate\Database\Seeder;

class DepartmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $departments = [
            [
                'name' => 'Sales',
                'description' => 'Sales department responsible for customer order capture and management'
            ],
            [
                'name' => 'Logistics',
                'description' => 'Logistics department handling order fulfillment, delivery, and vehicle management'
            ],
            [
                'name' => 'Accounts',
                'description' => 'Accounts department managing payment processing and financial reporting'
            ],
            [
                'name' => 'Administration',
                'description' => 'Administration department for system management and user administration'
            ],
        ];

        foreach ($departments as $departmentData) {
            Department::firstOrCreate(
                ['name' => $departmentData['name']],
                $departmentData
            );
        }
    }
}