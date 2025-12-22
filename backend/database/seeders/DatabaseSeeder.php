<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed roles and departments first (required for users)
        $this->call([
            RoleSeeder::class,
            DepartmentSeeder::class,
            AdminUserSeeder::class,
            UpdatedBrickTypesSeeder::class,
            SampleUserSeeder::class,
            // Note: SampleRequisitionSeeder removed as we're clearing all requisitions
        ]);
    }
}
